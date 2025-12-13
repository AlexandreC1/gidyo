import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/pages/user_type_selection_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/visitor/home/presentation/pages/visitor_home_screen.dart';
import '../../features/guide/dashboard/presentation/pages/guide_dashboard_screen.dart';
import '../../features/guide/onboarding/presentation/pages/guide_onboarding_screen.dart';
import '../navigation/visitor_navigation_shell.dart';
import '../navigation/guide_navigation_shell.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      return authState.when(
        data: (user) {
          final isAuthenticated = user != null;
          final isOnAuthScreen = state.matchedLocation.startsWith('/auth');

          // Not authenticated - redirect to auth
          if (!isAuthenticated && !isOnAuthScreen) {
            return '/auth/user-type-selection';
          }

          // Authenticated but on auth screen - redirect based on user type
          if (isAuthenticated && isOnAuthScreen) {
            // Get user profile to determine type
            final currentUser = ref.read(currentUserProvider);
            return currentUser.when(
              data: (userData) {
                if (userData == null) return null;

                if (userData.userType == UserType.visitor) {
                  return '/visitor/home';
                } else if (userData.userType == UserType.guide) {
                  // Check if guide is verified
                  // For now, go to dashboard
                  return '/guide/dashboard';
                }
                return null;
              },
              loading: () => null,
              error: (_, __) => null,
            );
          }

          return null;
        },
        loading: () => null,
        error: (_, __) => null,
      );
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/auth/user-type-selection',
        builder: (context, state) => const UserTypeSelectionScreen(),
      ),

      // Visitor Routes with Shell
      ShellRoute(
        builder: (context, state, child) {
          return VisitorNavigationShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/visitor/home',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const VisitorHomeScreen(),
            ),
          ),
          GoRoute(
            path: '/visitor/search',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const Placeholder(), // TODO: SearchScreen
            ),
          ),
          GoRoute(
            path: '/visitor/bookings',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const Placeholder(), // TODO: VisitorBookingsScreen
            ),
          ),
          GoRoute(
            path: '/visitor/messages',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const Placeholder(), // TODO: VisitorMessagesScreen
            ),
          ),
          GoRoute(
            path: '/visitor/profile',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const Placeholder(), // TODO: VisitorProfileScreen
            ),
          ),
        ],
      ),

      // Guide Routes with Shell
      ShellRoute(
        builder: (context, state, child) {
          return GuideNavigationShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/guide/dashboard',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const GuideDashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/guide/calendar',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const Placeholder(), // TODO: GuideCalendarScreen
            ),
          ),
          GoRoute(
            path: '/guide/bookings',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const Placeholder(), // TODO: GuideBookingsScreen
            ),
          ),
          GoRoute(
            path: '/guide/messages',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const Placeholder(), // TODO: GuideMessagesScreen
            ),
          ),
          GoRoute(
            path: '/guide/profile',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const Placeholder(), // TODO: GuideProfileScreen
            ),
          ),
        ],
      ),

      // Guide Onboarding (separate from shell)
      GoRoute(
        path: '/guide/onboarding',
        builder: (context, state) => const GuideOnboardingScreen(),
      ),
    ],
  );
});
