import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/pages/user_type_selection_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/visitor/home/presentation/pages/visitor_home_screen.dart';
import '../../features/visitor/search/presentation/pages/visitor_search_screen.dart';
import '../../features/visitor/bookings/presentation/pages/visitor_bookings_screen.dart';
import '../../features/visitor/messages/presentation/pages/visitor_messages_screen.dart';
import '../../features/visitor/profile/presentation/pages/visitor_profile_screen.dart';
import '../../features/guide/dashboard/presentation/pages/guide_dashboard_screen.dart';
import '../../features/guide/calendar/presentation/pages/guide_calendar_screen.dart';
import '../../features/guide/bookings/presentation/pages/guide_bookings_screen.dart';
import '../../features/guide/messages/presentation/pages/guide_messages_screen.dart';
import '../../features/guide/profile/presentation/pages/guide_profile_screen.dart';
import '../../features/guide/onboarding/presentation/pages/guide_onboarding_screen.dart';
import '../../features/guide_profile/presentation/pages/guide_profile_screen.dart' as guide_profile;
import '../../features/booking/presentation/pages/service_selection_screen.dart';
import '../../features/booking/presentation/pages/datetime_selection_screen.dart';
import '../../features/booking/presentation/pages/trip_details_screen.dart';
import '../../features/booking/presentation/pages/booking_review_screen.dart';
import '../../features/booking/presentation/pages/payment_screen.dart';
import '../../features/booking/presentation/pages/booking_confirmation_screen.dart';
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
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VisitorSearchScreen(),
            ),
          ),
          GoRoute(
            path: '/visitor/bookings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VisitorBookingsScreen(),
            ),
          ),
          GoRoute(
            path: '/visitor/messages',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VisitorMessagesScreen(),
            ),
          ),
          GoRoute(
            path: '/visitor/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VisitorProfileScreen(),
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
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GuideCalendarScreen(),
            ),
          ),
          GoRoute(
            path: '/guide/bookings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GuideBookingsScreen(),
            ),
          ),
          GoRoute(
            path: '/guide/messages',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GuideMessagesScreen(),
            ),
          ),
          GoRoute(
            path: '/guide/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GuideProfileScreen(),
            ),
          ),
        ],
      ),

      // Guide Onboarding (separate from shell)
      GoRoute(
        path: '/guide/onboarding',
        builder: (context, state) => const GuideOnboardingScreen(),
      ),

      // Guide Profile (public - accessible to visitors)
      GoRoute(
        path: '/guide-profile/:guideId',
        builder: (context, state) {
          final guideId = state.pathParameters['guideId']!;
          return guide_profile.GuideProfileScreen(guideId: guideId);
        },
      ),

      // Booking Flow Routes
      GoRoute(
        path: '/booking/service/:guideId',
        builder: (context, state) {
          final guideId = state.pathParameters['guideId']!;
          return ServiceSelectionScreen(guideId: guideId);
        },
      ),
      GoRoute(
        path: '/booking/datetime/:guideId',
        builder: (context, state) {
          final guideId = state.pathParameters['guideId']!;
          return DateTimeSelectionScreen(guideId: guideId);
        },
      ),
      GoRoute(
        path: '/booking/trip-details',
        builder: (context, state) => const TripDetailsScreen(),
      ),
      GoRoute(
        path: '/booking/review',
        builder: (context, state) => const BookingReviewScreen(),
      ),
      GoRoute(
        path: '/booking/payment',
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: '/booking/confirmation/:bookingId',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return BookingConfirmationScreen(bookingId: bookingId);
        },
      ),
    ],
  );
});
