import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/providers.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/group/create_group_screen.dart';
import '../screens/group/group_screen.dart';
import '../screens/group/join_group_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/movement/movement_detail_screen.dart';
import '../screens/movement/movement_form_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/welcome',
    refreshListenable: _AuthRefresh(ref),
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/welcome' ||
          state.matchedLocation == '/onboarding';

      final user = authState.value;
      final isLoading = authState.isLoading;

      if (isLoading) return null;

      if (user == null && !loggingIn) {
        return '/welcome';
      }

      if (user != null &&
          (state.matchedLocation == '/welcome' ||
              state.matchedLocation == '/login' ||
              state.matchedLocation == '/signup')) {
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
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
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
            path: 'movements/new',
            builder: (context, state) {
              final groupId = state.pathParameters['groupId']!;
              return MovementFormScreen(groupId: groupId);
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
