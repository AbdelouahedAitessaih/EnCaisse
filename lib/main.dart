import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'providers/providers.dart';
import 'providers/settings_provider.dart';
import 'router/app_router.dart';
import 'services/device_region.dart';
import 'services/notification_service.dart';
import 'widgets/app_lock_gate.dart';
import 'widgets/force_update_gate.dart';
import 'widgets/offline_banner.dart';

void _enableAndroidPhotoPicker() {
  final impl = ImagePickerPlatform.instance;
  if (impl is ImagePickerAndroid) {
    impl.useAndroidPhotoPicker = true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _enableAndroidPhotoPicker();

  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey(kOnboardingCompletedKey)) {
    final upgrading =
        prefs.containsKey('auth_remembered_email') ||
        prefs.containsKey('settings_theme_mode') ||
        prefs.containsKey('movement_success_count') ||
        prefs.containsKey('review_asked');
    if (upgrading) {
      await prefs.setBool(kOnboardingCompletedKey, true);
    }
  }

  var firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    if (!kIsWeb) {
      final crashlytics = FirebaseCrashlytics.instance;
      await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
      FlutterError.onError = crashlytics.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        crashlytics.recordError(error, stack, fatal: true);
        return true;
      };
    }
  } catch (e, st) {
    debugPrint(
      '${FirebaseSetupNotes.placeholderNotice}\nFirebase init error: $e\n$st',
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        firebaseReadyProvider.overrideWithValue(firebaseReady),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const EncaisseApp(),
    ),
  );
}

class EncaisseApp extends ConsumerStatefulWidget {
  const EncaisseApp({super.key});

  @override
  ConsumerState<EncaisseApp> createState() => _EncaisseAppState();
}

class _EncaisseAppState extends ConsumerState<EncaisseApp>
    with WidgetsBindingObserver {
  String? _notifUid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await DeviceRegion.preload();
      if (!ref.read(firebaseReadyProvider)) return;
      if (!kIsWeb) {
        await ref.read(adServiceProvider).initialize();
      }
      await _syncNotifications(ref.read(authStateProvider).asData?.value?.uid);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _notifUid != null) {
      ref.read(notificationServiceProvider).recordAppActivity(_notifUid!);
    }
  }

  Future<void> _syncNotifications(String? uid) async {
    if (!kIsWeb && ref.read(firebaseReadyProvider)) {
      FirebaseCrashlytics.instance.setUserIdentifier(uid ?? '').ignore();
    }
    final service = ref.read(notificationServiceProvider);
    if (uid == null) {
      ref.read(homeWidgetServiceProvider).clear().ignore();
      await service.stopListening();
      _notifUid = null;
      return;
    }
    if (_notifUid == uid) return;
    _notifUid = uid;
    // Ensure users/{uid} exists with name/email before FCM token merge.
    await ref.read(authServiceProvider).repairCurrentProfile();
    service.onOpenGroup = (groupId) {
      if (!mounted) return;
      ref.read(routerProvider).go('/groups/$groupId');
    };
    try {
      await service.initialize(uid: uid);
    } catch (e) {
      debugPrint(
        'Notification service init failed (FCM may be unavailable): $e',
      );
    }
    final pending = service.takePendingGroupId();
    if (pending != null && pending.isNotEmpty && mounted) {
      ref.read(routerProvider).go('/groups/$pending');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);
    ref.listen(authStateProvider, (prev, next) {
      final uid = next.asData?.value?.uid;
      _syncNotifications(uid);
    });

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      locale: settings.locale,
      // Flutter passes `[locale]` here when a language is forced, and the
      // phone languages otherwise; the latter result is cached, so returning
      // the forced language would stick after switching back to the phone's.
      localeListResolutionCallback: (locales, supported) =>
          resolveDeviceLocale(locales),
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        return AppLockGate(
          child: ForceUpdateGate(
            child: OfflineBanner(child: child ?? const SizedBox.shrink()),
          ),
        );
      },
    );
  }
}
