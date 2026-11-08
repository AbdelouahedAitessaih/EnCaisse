import 'package:encaisse/core/constants/app_constants.dart';
import 'package:encaisse/core/theme/app_theme.dart';
import 'package:encaisse/l10n/app_localizations.dart';
import 'package:encaisse/models/models.dart';
import 'package:encaisse/providers/providers.dart';
import 'package:encaisse/providers/settings_provider.dart';
import 'package:encaisse/screens/auth/login_screen.dart';
import 'package:encaisse/screens/auth/signup_screen.dart';
import 'package:encaisse/screens/auth/verify_email_screen.dart';
import 'package:encaisse/screens/group/create_group_screen.dart';
import 'package:encaisse/screens/group/group_insights_screen.dart';
import 'package:encaisse/screens/group/group_screen.dart';
import 'package:encaisse/screens/group/join_group_screen.dart';
import 'package:encaisse/screens/home/home_screen.dart';
import 'package:encaisse/screens/movement/movement_detail_screen.dart';
import 'package:encaisse/screens/movement/movement_form_screen.dart';
import 'package:encaisse/screens/notifications/notifications_screen.dart';
import 'package:encaisse/screens/onboarding/onboarding_screen.dart';
import 'package:encaisse/screens/profile/profile_screen.dart';
import 'package:encaisse/screens/settings/settings_screen.dart';
import 'package:encaisse/screens/onboarding/welcome_screen.dart';
import 'package:encaisse/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockUser extends Mock implements User {}

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockSharedPreferences prefs;
  late MockUser mockUser;
  late MockAuthService mockAuthService;

  setUp(() {
    prefs = MockSharedPreferences();
    when(() => prefs.getBool(any())).thenReturn(false);
    when(() => prefs.getString(any())).thenReturn(null);
    when(() => prefs.getDouble(any())).thenReturn(null);
    when(() => prefs.getInt(any())).thenReturn(null);
    when(() => prefs.getStringList(any())).thenReturn(null);

    mockUser = MockUser();
    when(() => mockUser.uid).thenReturn('test-uid');
    when(() => mockUser.displayName).thenReturn('Test User');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockUser.photoURL).thenReturn(null);

    mockAuthService = MockAuthService();
    when(
      () => mockAuthService.repairCurrentProfile(),
    ).thenAnswer((_) async => null);
  });

  Widget wrapWithProviders(
    Widget child, {
    User? user,
    List<Override> overrides = const [],
    AuthService? authService,
  }) {
    return ProviderScope(
      overrides: [
        firebaseReadyProvider.overrideWithValue(true),
        sharedPreferencesProvider.overrideWithValue(prefs),
        authStateProvider.overrideWith((ref) => Stream.value(user)),
        authServiceProvider.overrideWithValue(authService ?? mockAuthService),
        currentUserProfileProvider.overrideWith(
          (ref) => Stream.value(
            user == null
                ? null
                : UserProfile(
                    uid: user.uid,
                    displayName: user.displayName ?? 'User',
                    email: user.email ?? '',
                    createdAt: DateTime(2025, 1, 1),
                  ),
          ),
        ),
        ...overrides,
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final themeMode = ref.watch(settingsProvider).themeMode;
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: supportedLocales.toList(),
            home: child,
          );
        },
      ),
    );
  }

  group('WelcomeScreen', () {
    testWidgets('renders app name, tagline, and action buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrapWithProviders(const WelcomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('EnCaisse'), findsOneWidget);
      expect(find.text('EnCaisse, ensemble.'), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);
      expect(find.text('I already have an account'), findsOneWidget);
    });

    testWidgets('does not throw rendering errors', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithProviders(const WelcomeScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('OnboardingScreen', () {
    testWidgets('renders three pages with navigation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrapWithProviders(const OnboardingScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('shows create account button on last page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrapWithProviders(const OnboardingScreen()));
      await tester.pumpAndSettle();

      // Navigate to last page
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Create account'), findsOneWidget);
      expect(find.text('I already have an account'), findsWidgets);
    });
  });

  group('LoginScreen', () {
    testWidgets('renders email, password, and sign-in elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrapWithProviders(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign in'), findsWidgets);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Remember me'), findsOneWidget);
    });

    testWidgets('shows password visibility toggle', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrapWithProviders(const LoginScreen()));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
    });
  });

  group('SignupScreen', () {
    testWidgets('renders name, email, password, and sign-up elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrapWithProviders(const SignupScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Join EnCaisse'), findsOneWidget);
      expect(find.text('Display name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Create account'), findsWidgets);
      expect(find.text('Continue with Google'), findsOneWidget);
    });
  });

  group('VerifyEmailScreen', () {
    testWidgets('gracefully handles non-initialized Firebase', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrapWithProviders(const VerifyEmailScreen()));
      final exception = tester.takeException();
      expect(exception, isNotNull);
      expect(exception.toString(), contains('no-app'));
    });
  });

  group('CreateGroupScreen', () {
    testWidgets('renders form fields and currency selector', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProviders(const CreateGroupScreen(), user: mockUser),
      );
      await tester.pumpAndSettle();

      expect(find.text('Name your caisse'), findsOneWidget);
      expect(find.text('Group name'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
      expect(find.text('Starting amount (optional)'), findsOneWidget);
      expect(find.text('Create group'), findsOneWidget);
    });
  });

  group('JoinGroupScreen', () {
    testWidgets('renders invite code input form', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithProviders(const JoinGroupScreen(), user: mockUser),
      );
      await tester.pumpAndSettle();

      expect(find.text('Enter invite code'), findsOneWidget);
      expect(find.text('Invite code'), findsOneWidget);
      expect(find.text('Join group'), findsOneWidget);
    });
  });

  group('HomeScreen', () {
    testWidgets('shows empty state when no groups', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProviders(
          const HomeScreen(),
          user: mockUser,
          overrides: [
            userGroupsProvider.overrideWith((ref) => Stream.value([])),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No groups yet'), findsOneWidget);
      expect(find.text('Create a group'), findsOneWidget);
      expect(find.text('Join with invite code'), findsOneWidget);
    });

    testWidgets('shows group cards when groups exist', (
      WidgetTester tester,
    ) async {
      final now = DateTime(2025, 6, 15);
      final groups = [
        Group(
          id: 'g1',
          name: 'Test Group',
          createdBy: 'test-uid',
          createdAt: now,
          inviteCode: 'ABC123',
          currency: 'MAD',
        ),
      ];
      await tester.pumpWidget(
        wrapWithProviders(
          const HomeScreen(),
          user: mockUser,
          overrides: [
            userGroupsProvider.overrideWith((ref) => Stream.value(groups)),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Group'), findsWidgets);
      // The card is a summary: name, balance, member count and the caller's
      // position. The invite code lives on the group screen, where it can be
      // copied or shared.
      expect(find.text('MAD 0.00'), findsOneWidget);
      expect(find.textContaining('ABC123'), findsNothing);
      expect(find.text('Create a group'), findsOneWidget);
      expect(find.text('Join with invite code'), findsOneWidget);
    });

    Group group(
      String id,
      String currency, {
      String name = 'G',
      bool personal = false,
    }) => Group(
      id: id,
      name: name,
      createdBy: 'test-uid',
      createdAt: DateTime(2025, 6, 15),
      inviteCode: 'ABC123',
      currency: currency,
      isPersonal: personal,
    );

    BalanceSummary balance(double total) => BalanceSummary(
      total: total,
      deposits: total,
      expenses: 0,
      byCategory: const {},
    );

    testWidgets('never totals balances held in different currencies', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProviders(
          const HomeScreen(),
          user: mockUser,
          overrides: [
            userGroupsProvider.overrideWith(
              (ref) => Stream.value([
                group('mad', 'MAD', name: 'Morocco trip'),
                group('eur', 'EUR', name: 'Europe trip'),
              ]),
            ),
            balanceProvider.overrideWith(
              (ref, id) => balance(id == 'mad' ? 1200 : 300),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // No cross-currency figure may appear, and the reason is stated.
      expect(find.textContaining('Total across'), findsNothing);
      expect(find.textContaining('never added together'), findsOneWidget);
      // Each caisse still shows its own context.
      expect(find.text('Morocco trip'), findsOneWidget);
      expect(find.text('Europe trip'), findsOneWidget);
    });

    testWidgets(
      'labels the aggregate explicitly when every caisse shares a currency',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          wrapWithProviders(
            const HomeScreen(),
            user: mockUser,
            overrides: [
              userGroupsProvider.overrideWith(
                (ref) => Stream.value([
                  group('a', 'MAD', name: 'Flat A'),
                  group('b', 'MAD', name: 'Flat B'),
                ]),
              ),
              balanceProvider.overrideWith(
                (ref, id) => balance(id == 'a' ? 1200 : -500),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Total across 2 caisses'), findsOneWidget);
      },
    );

    testWidgets(
      'gives the personal caisse its own section instead of the shared list',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          wrapWithProviders(
            const HomeScreen(),
            user: mockUser,
            overrides: [
              userGroupsProvider.overrideWith(
                (ref) => Stream.value([
                  group('shared', 'MAD', name: 'Shared trip'),
                  group('mine', 'MAD', name: 'My caisse', personal: true),
                ]),
              ),
              balanceProvider.overrideWith((ref, id) => balance(100)),
            ],
          ),
        );
        await tester.pumpAndSettle();

        // Two sections. The personal caisse is not counted as shared, and a
        // single shared caisse gets no aggregate: it would repeat its card.
        expect(find.textContaining('Total across'), findsNothing);
        expect(find.text('Shared trip'), findsOneWidget);
        expect(find.text('My caisse'), findsOneWidget);
        // AppSectionHeader upper-cases its label, so the two sections are
        // distinguishable from the "Personal caisse" action button below.
        expect(find.text('YOUR CAISSES'), findsOneWidget);
        expect(find.text('PERSONAL CAISSE'), findsOneWidget);
      },
    );
  });

  group('GroupScreen', () {
    testWidgets('shows group header and balance', (WidgetTester tester) async {
      final now = DateTime(2025, 6, 15);
      final group = Group(
        id: 'g1',
        name: 'Test Group',
        createdBy: 'test-uid',
        createdAt: now,
        inviteCode: 'ABC123',
        currency: 'MAD',
      );
      final movements = [
        Movement(
          id: 'm1',
          type: MovementType.deposit,
          amount: 100,
          title: 'Initial deposit',
          category: 'Other',
          createdBy: 'test-uid',
          createdByName: 'Test User',
          createdAt: now,
          updatedAt: now,
          updatedBy: 'test-uid',
        ),
      ];

      await tester.pumpWidget(
        wrapWithProviders(
          const GroupScreen(groupId: 'g1'),
          user: mockUser,
          overrides: [
            groupProvider.overrideWith((ref, id) => Stream.value(group)),
            movementsProvider.overrideWith(
              (ref, id) => Stream.value(movements),
            ),
            groupMembersProvider.overrideWith(
              (ref, id) => Stream.value([
                GroupMember(
                  uid: 'test-uid',
                  displayName: 'Test User',
                  joinedAt: now,
                ),
              ]),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Group'), findsOneWidget);
      expect(find.textContaining('100.00'), findsWidgets);
      expect(find.text('Insights'), findsOneWidget);
    });

    testWidgets('shows invite code for non-personal groups', (
      WidgetTester tester,
    ) async {
      final now = DateTime(2025, 6, 15);
      final group = Group(
        id: 'g1',
        name: 'Shared Group',
        createdBy: 'test-uid',
        createdAt: now,
        inviteCode: 'XYZ789',
        currency: 'USD',
        isPersonal: false,
      );

      await tester.pumpWidget(
        wrapWithProviders(
          const GroupScreen(groupId: 'g1'),
          user: mockUser,
          overrides: [
            groupProvider.overrideWith((ref, id) => Stream.value(group)),
            movementsProvider.overrideWith(
              (ref, id) => Stream.value(<Movement>[]),
            ),
            groupMembersProvider.overrideWith(
              (ref, id) => Stream.value([
                GroupMember(
                  uid: 'test-uid',
                  displayName: 'Test User',
                  joinedAt: now,
                ),
              ]),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('XYZ789'), findsOneWidget);
      expect(find.text('Invite code'), findsOneWidget);
    });
  });

  group('GroupInsightsScreen', () {
    testWidgets('shows settle section with transfer info', (
      WidgetTester tester,
    ) async {
      final now = DateTime(2025, 6, 15);
      final group = Group(
        id: 'g1',
        name: 'Test Group',
        createdBy: 'test-uid',
        createdAt: now,
        inviteCode: 'ABC123',
        currency: 'USD',
        isPersonal: false,
      );
      final members = [
        GroupMember(uid: 'a', displayName: 'Alice', joinedAt: now),
        GroupMember(uid: 'b', displayName: 'Bob', joinedAt: now),
      ];
      final movements = [
        Movement(
          id: 'm1',
          type: MovementType.deposit,
          amount: 100,
          title: 'Alice pays',
          category: 'Other',
          createdBy: 'a',
          createdByName: 'Alice',
          createdAt: now,
          updatedAt: now,
          updatedBy: 'a',
        ),
        Movement(
          id: 'm2',
          type: MovementType.expense,
          amount: 60,
          title: 'Bob pays',
          category: 'Food',
          createdBy: 'b',
          createdByName: 'Bob',
          createdAt: now,
          updatedAt: now,
          updatedBy: 'b',
        ),
      ];
      await tester.pumpWidget(
        wrapWithProviders(
          const GroupInsightsScreen(groupId: 'g1'),
          user: mockUser,
          overrides: [
            groupProvider.overrideWith((ref, id) => Stream.value(group)),
            movementsProvider.overrideWith(
              (ref, id) => Stream.value(movements),
            ),
            groupMembersProvider.overrideWith(
              (ref, id) => Stream.value(members),
            ),
            settlementsProvider.overrideWith((ref, id) => const Stream.empty()),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Insights'), findsOneWidget);
      expect(find.text('Who owes whom'), findsOneWidget);
    });
  });

  group('MovementFormScreen', () {
    testWidgets('renders form fields for new deposit', (
      WidgetTester tester,
    ) async {
      final now = DateTime(2025, 6, 15);
      final group = Group(
        id: 'g1',
        name: 'Test Group',
        createdBy: 'test-uid',
        createdAt: now,
        inviteCode: 'ABC123',
        currency: 'MAD',
      );

      await tester.pumpWidget(
        wrapWithProviders(
          const MovementFormScreen(groupId: 'g1'),
          user: mockUser,
          overrides: [
            groupProvider.overrideWith((ref, id) => Stream.value(group)),
            movementsProvider.overrideWith(
              (ref, id) => Stream.value(<Movement>[]),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add movement'), findsWidgets);
      expect(find.text('Deposit'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
    });
  });

  group('MovementDetailScreen', () {
    testWidgets('renders movement details', (WidgetTester tester) async {
      final now = DateTime(2025, 6, 15);
      final group = Group(
        id: 'g1',
        name: 'Test Group',
        createdBy: 'test-uid',
        createdAt: now,
        inviteCode: 'ABC123',
        currency: 'USD',
      );
      final movement = Movement(
        id: 'm1',
        type: MovementType.expense,
        amount: 50.0,
        title: 'Dinner',
        category: 'Food',
        createdBy: 'test-uid',
        createdByName: 'Test User',
        createdAt: now,
        updatedAt: now,
        updatedBy: 'test-uid',
      );

      await tester.pumpWidget(
        wrapWithProviders(
          const MovementDetailScreen(groupId: 'g1', movementId: 'm1'),
          user: mockUser,
          overrides: [
            groupProvider.overrideWith((ref, id) => Stream.value(group)),
            movementsProvider.overrideWith(
              (ref, id) => Stream.value([movement]),
            ),
            movementAuditProvider.overrideWith(
              (ref, args) => Stream.value(<AuditEntry>[]),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dinner'), findsOneWidget);
      expect(find.textContaining('50.00'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
    });
  });

  group('NotificationsScreen', () {
    testWidgets('shows empty state when no notifications', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProviders(
          const NotificationsScreen(),
          user: mockUser,
          overrides: [
            inboxNotificationsProvider.overrideWith(
              (ref) => Stream.value(<AppNotification>[]),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No notifications yet'), findsOneWidget);
      expect(find.text('Mark all read'), findsOneWidget);
    });
  });

  group('SettingsScreen', () {
    testWidgets('renders profile, appearance, and language sections', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));
      await tester.pumpWidget(
        wrapWithProviders(const SettingsScreen(), user: mockUser),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsWidgets);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('How to use EnCaisse'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Group activity'), findsOneWidget);
      expect(find.text('Helpful reminders'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);

      await tester.binding.setSurfaceSize(Size.zero);
    });

    testWidgets('renders language tiles for all supported languages', (
      WidgetTester tester,
    ) async {
      // Use a large screen size so the ListView renders all children without
      // needing to scroll (the language tiles extend below the fold on
      // default 800x600 test screens).
      await tester.binding.setSurfaceSize(const Size(1080, 2400));

      await tester.pumpWidget(
        wrapWithProviders(const SettingsScreen(), user: mockUser),
      );
      await tester.pumpAndSettle();

      // SegmentedButton renders theme options
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);

      // One row shows the current choice; the full list opens in a sheet,
      // each language under its own name with the translated name below.
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Phone language'), findsOneWidget);
      await tester.tap(find.text('Phone language'));
      await tester.pumpAndSettle();

      expect(find.text('Phone language'), findsNWidgets(2));
      expect(find.text('English'), findsOneWidget);
      for (final (native, english) in [
        ('Français', 'French'),
        ('العربية', 'Arabic'),
        ('Español', 'Spanish'),
        ('Português', 'Portuguese'),
        ('中文', 'Chinese'),
        ('हिन्दी', 'Hindi'),
        ('Русский', 'Russian'),
        ('日本語', 'Japanese'),
      ]) {
        expect(find.text(native), findsOneWidget);
        expect(find.text(english), findsOneWidget);
      }

      // Reset surface size for subsequent tests
      await tester.binding.setSurfaceSize(Size.zero);
    });
  });

  group('ProfileScreen', () {
    testWidgets('renders edit profile form', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithProviders(const ProfileScreen(), user: mockUser),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit profile'), findsOneWidget);
      expect(find.text('Display name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });
  });

  group('RTL (Arabic) layout', () {
    testWidgets('renders screens in Arabic without rendering errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firebaseReadyProvider.overrideWithValue(true),
            sharedPreferencesProvider.overrideWithValue(prefs),
            authStateProvider.overrideWith((ref) => Stream.value(null)),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
          child: MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: supportedLocales.toList(),
            locale: const Locale('ar'),
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('مرحبًا بعودتك'), findsOneWidget);
    });
  });

  group('Dark theme', () {
    testWidgets('renders WelcomeScreen in dark mode without rendering errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firebaseReadyProvider.overrideWithValue(true),
            sharedPreferencesProvider.overrideWithValue(prefs),
            authStateProvider.overrideWith((ref) => Stream.value(null)),
            authServiceProvider.overrideWithValue(mockAuthService),
            settingsProvider.overrideWithBuild(
              (ref, notifier) => const AppSettings(themeMode: ThemeMode.dark),
            ),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              final themeMode = ref.watch(settingsProvider).themeMode;
              return MaterialApp(
                title: AppConstants.appName,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeMode,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: supportedLocales.toList(),
                home: const WelcomeScreen(),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('EnCaisse'), findsOneWidget);
    });
  });
}
