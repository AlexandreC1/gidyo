import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../notification_service.dart';
import '../notification_repository.dart';
import '../deep_link_service.dart';
import '../models/notification_payload.dart';

/// Provider for NotificationService singleton
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

/// Provider for DeepLinkService singleton
final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  return DeepLinkService.instance;
});

/// Provider for NotificationRepository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final supabase = Supabase.instance.client;
  return NotificationRepository(supabase);
});

/// Provider for FCM token
final fcmTokenProvider = Provider<String?>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.fcmToken;
});

/// Provider for notification tap stream
final notificationTapStreamProvider =
    StreamProvider<NotificationPayload>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.onNotificationTap;
});

/// Provider for unread notification count
final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getUnreadNotificationCount();
});

/// Provider for notification preferences
final notificationPreferencesProvider =
    FutureProvider<Map<String, bool>>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getNotificationPreferences();
});

/// Provider for notification history
final notificationHistoryProvider = FutureProvider.family<
    List<Map<String, dynamic>>,
    NotificationHistoryParams>((ref, params) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getNotificationHistory(
    limit: params.limit,
    offset: params.offset,
  );
});

/// Provider for realtime notifications stream
final notificationStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.watchNotifications();
});

/// State notifier for managing notification preferences
final notificationPreferencesNotifierProvider = StateNotifierProvider<
    NotificationPreferencesNotifier, AsyncValue<Map<String, bool>>>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationPreferencesNotifier(repository);
});

/// Parameters for notification history
class NotificationHistoryParams {
  final int limit;
  final int offset;

  const NotificationHistoryParams({
    this.limit = 50,
    this.offset = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationHistoryParams &&
          runtimeType == other.runtimeType &&
          limit == other.limit &&
          offset == other.offset;

  @override
  int get hashCode => limit.hashCode ^ offset.hashCode;
}

/// State notifier for notification preferences
class NotificationPreferencesNotifier
    extends StateNotifier<AsyncValue<Map<String, bool>>> {
  final NotificationRepository _repository;

  NotificationPreferencesNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    state = const AsyncValue.loading();
    try {
      final preferences = await _repository.getNotificationPreferences();
      state = AsyncValue.data(preferences);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updatePreferences({
    required bool bookingNotifications,
    required bool messageNotifications,
    required bool paymentNotifications,
    required bool marketingNotifications,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateNotificationPreferences(
        bookingNotifications: bookingNotifications,
        messageNotifications: messageNotifications,
        paymentNotifications: paymentNotifications,
        marketingNotifications: marketingNotifications,
      );

      // Update state with new preferences
      state = AsyncValue.data({
        'booking_notifications': bookingNotifications,
        'message_notifications': messageNotifications,
        'payment_notifications': paymentNotifications,
        'marketing_notifications': marketingNotifications,
      });
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void refresh() {
    _loadPreferences();
  }
}
