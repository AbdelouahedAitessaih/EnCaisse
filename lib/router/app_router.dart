import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/providers.dart';
import '../providers/settings_provider.dart';
import '../models/models.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/group/create_group_screen.dart';
import '../screens/group/group_insights_screen.dart';
import '../screens/group/group_screen.dart';
import '../screens/group/join_group_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/movement/movement_detail_screen.dart';
import '../screens/movement/movement_form_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';

const kOnboardingCompletedKey = 'onboarding_completed';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/welcome',
    refreshListenable: _AuthRefresh(ref),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final loggingIn =
          loc == '/login' ||
          loc == '/signup' ||
          loc == '/welcome' ||
          loc == '/onboarding';
      final verifying = loc == '/verify-email';

      // Read auth state, never watch it. Watching would rebuild this GoRouter on
      // every userChanges() emission (display name, photo URL, reload) and reset
      // navigation back to initialLocation, bouncing the user out of the screen
      // they are on. [_AuthRefresh] still re-runs this redirect on auth changes.
      final authState = ref.read(authStateProvider);
      final streamUser = authState.value;
      // Live user after reload — auth stream can briefly lag.
      final user = ref.read(authServiceProvider).currentUser ?? streamUser;
      final isLoading = authState.isLoading;
      final onboardingDone = prefs.getBool(kOnboardingCompletedKey) ?? false;

      if (isLoading) return null;

      if (user == null) {
        if (!onboardingDone && loc != '/onboarding') {
          return '/onboarding';
        }
        if (onboardingDone && loc == '/onboarding') {
          return '/welcome';
        }
        if (!loggingIn && !verifying) {
          return onboardingDone ? '/welcome' : '/onboarding';
        }
        return null;
      }

      final auth = ref.read(authServiceProvider);
      if (auth.needsEmailVerification(user) && !verifying) {
        return '/verify-email';
      }
      if (!auth.needsEmailVerification(user) && verifying) {
        return '/home';
      }

      if (loc == '/welcome' || loc == '/login' || loc == '/signup') {
        return '/home';
      }
      if (loc == '/onboarding') {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/groups/create',
        builder: (context, state) => const CreateGroupScreen(),
      ),
      GoRoute(
        path: '/groups/join',
        builder: (context, state) => const JoinGroupScreen(),
      ),
      GoRoute(
        path: '/groups/:groupId',
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return GroupScreen(groupId: groupId);
        },
        routes: [
          GoRoute(
            path: 'insights',
            builder: (context, state) {
              final groupId = state.pathParameters['groupId']!;
              return GroupInsightsScreen(groupId: groupId);
            },
          ),
          GoRoute(
            path: 'movements/new',
            builder: (context, state) {
              final groupId = state.pathParameters['groupId']!;
              return MovementFormScreen(
                groupId: groupId,
                initialType: state.extra is MovementType
                    ? state.extra as MovementType
                    : null,
              );
            },
          ),
          GoRoute(
            path: 'movements/:movementId',
            builder: (context, state) {
              final groupId = state.pathParameters['groupId']!;
              final movementId = state.pathParameters['movementId']!;
              return MovementDetailScreen(
                groupId: groupId,
                movementId: movementId,
              );
            },
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  final groupId = state.pathParameters['groupId']!;
                  final movementId = state.pathParameters['movementId']!;
                  return MovementFormScreen(
                    groupId: groupId,
                    movementId: movementId,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(this._ref) {
    _ref.listen(authStateProvider, (previous, next) => notifyListeners());
  }

  final Ref _ref;
}

Future<void> markOnboardingCompleted(SharedPreferences prefs) async {
  await prefs.setBool(kOnboardingCompletedKey, true);
}
