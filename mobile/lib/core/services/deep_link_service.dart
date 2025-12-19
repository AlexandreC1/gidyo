import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/logger.dart';
import 'models/notification_payload.dart';
import 'notification_service.dart';

/// Service for handling deep links from notifications
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  bool _initialized = false;

  /// Initialize deep link handling
  void initialize(BuildContext context) {
    if (_initialized) {
      Logger.warning('DeepLinkService already initialized');
      return;
    }

    // Listen to notification taps
    NotificationService.instance.onNotificationTap.listen((payload) {
      _handleNotificationTap(context, payload);
    });

    _initialized = true;
    Logger.info('DeepLinkService initialized');
  }

  /// Handle notification tap and navigate to appropriate screen
  void _handleNotificationTap(
    BuildContext context,
    NotificationPayload payload,
  ) {
    try {
      Logger.info('Handling notification tap: ${payload.type.value}');

      // Validate payload
      if (!payload.isValid) {
        Logger.warning('Invalid notification payload, cannot navigate');
        return;
      }

      // Get the route based on notification type
      final route = _getRouteForNotification(payload);

      if (route == null) {
        Logger.warning('No route found for notification type: ${payload.type.value}');
        return;
      }

      // Validate the route is safe
      if (!_isRouteSafe(route)) {
        Logger.warning('Unsafe route detected: $route');
        return;
      }

      // Navigate using GoRouter
      if (context.mounted) {
        context.go(route);
        Logger.info('Navigated to: $route');
      }
    } catch (e, stackTrace) {
      Logger.error('Error handling notification tap', e, stackTrace);
    }
  }

  /// Get route path for notification type
  String? _getRouteForNotification(NotificationPayload payload) {
    // If notification has explicit screen path, use it (after validation)
    if (payload.screen != null && payload.screen!.isNotEmpty) {
      return payload.screen;
    }

    // Otherwise, determine route based on notification type and data
    switch (payload.type) {
      case NotificationType.bookingRequest:
        // Guide receives booking request -> go to bookings
        return '/guide/bookings';

      case NotificationType.bookingConfirmed:
        // Visitor receives confirmation -> go to specific booking or bookings list
        if (payload.bookingId != null) {
          return '/visitor/bookings'; // Or booking detail if we add that route
        }
        return '/visitor/bookings';

      case NotificationType.bookingCancelled:
        // Both can receive cancellation -> go to bookings
        // The route will be determined by user type authentication
        if (payload.bookingId != null) {
          // Could navigate to specific booking detail
          return null; // Let default redirect logic handle it
        }
        return null;

      case NotificationType.newMessage:
        // Navigate to messages screen
        // Route determined by user type
        if (payload.messageId != null || payload.userId != null) {
          return null; // Let default redirect handle based on user type
        }
        return null;

      case NotificationType.paymentReceived:
        // Guide receives payment notification
        if (payload.bookingId != null) {
          return '/guide/bookings';
        }
        return '/guide/dashboard';

      case NotificationType.reviewReceived:
        // Guide receives review
        return '/guide/profile';

      case NotificationType.guideApproved:
        // Guide account approved
        return '/guide/dashboard';

      case NotificationType.unknown:
        Logger.warning('Unknown notification type');
        return null;
    }
  }

  /// Validate that route is safe to navigate to
  bool _isRouteSafe(String route) {
    // Route must start with /
    if (!route.startsWith('/')) {
      return false;
    }

    // Whitelist of allowed route prefixes
    final allowedPrefixes = [
      '/visitor/',
      '/guide/',
      '/booking/',
      '/guide-profile/',
      '/auth/',
    ];

    // Check if route starts with any allowed prefix
    final isAllowed = allowedPrefixes.any(
      (prefix) => route.startsWith(prefix),
    );

    if (!isAllowed) {
      Logger.warning('Route not in whitelist: $route');
      return false;
    }

    // Additional validation: only safe characters
    final safeRouteRegex = RegExp(r'^/[a-zA-Z0-9/_-]+$');
    if (!safeRouteRegex.hasMatch(route)) {
      Logger.warning('Route contains unsafe characters: $route');
      return false;
    }

    return true;
  }

  /// Navigate to specific booking detail
  void navigateToBooking(BuildContext context, String bookingId) {
    if (!_isValidId(bookingId)) {
      Logger.warning('Invalid booking ID: $bookingId');
      return;
    }

    // Note: Add booking detail route if not exists
    final route = '/booking/confirmation/$bookingId';

    if (_isRouteSafe(route) && context.mounted) {
      context.go(route);
    }
  }

  /// Navigate to chat with specific user
  void navigateToChat(BuildContext context, String userId) {
    if (!_isValidId(userId)) {
      Logger.warning('Invalid user ID: $userId');
      return;
    }

    // Determine route based on current user type
    // This would need user context
    Logger.info('Navigate to chat with user: $userId');
    // Implementation depends on your chat routing structure
  }

  /// Navigate to specific guide profile
  void navigateToGuideProfile(BuildContext context, String guideId) {
    if (!_isValidId(guideId)) {
      Logger.warning('Invalid guide ID: $guideId');
      return;
    }

    final route = '/guide-profile/$guideId';

    if (_isRouteSafe(route) && context.mounted) {
      context.go(route);
    }
  }

  /// Validate ID format
  bool _isValidId(String id) {
    if (id.isEmpty) return false;

    // Must be alphanumeric with dashes/underscores only
    final idRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!idRegex.hasMatch(id)) return false;

    // Reasonable length limit
    if (id.length > 100) return false;

    return true;
  }

  /// Handle deep link from external source (e.g., email, SMS)
  Future<void> handleDeepLink(BuildContext context, Uri deepLink) async {
    try {
      Logger.info('Handling deep link: ${deepLink.toString()}');

      // Validate deep link host (should be your domain)
      if (!_isValidDeepLinkHost(deepLink.host)) {
        Logger.warning('Invalid deep link host: ${deepLink.host}');
        return;
      }

      final path = deepLink.path;

      // Validate and navigate
      if (_isRouteSafe(path) && context.mounted) {
        context.go(path);
      }
    } catch (e, stackTrace) {
      Logger.error('Error handling deep link', e, stackTrace);
    }
  }

  /// Validate deep link host
  bool _isValidDeepLinkHost(String host) {
    // Whitelist your app's domains
    const allowedHosts = [
      'gidyo.app',
      'www.gidyo.app',
      'app.gidyo.com',
    ];

    return allowedHosts.contains(host.toLowerCase());
  }
}
