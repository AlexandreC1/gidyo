import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/logger.dart';

/// Repository for managing notification tokens and preferences
class NotificationRepository {
  final SupabaseClient _supabase;

  NotificationRepository(this._supabase);

  /// Save FCM token to user profile
  /// This allows the backend to send push notifications to this device
  Future<void> saveFCMToken(String token) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        Logger.warning('Cannot save FCM token: user not authenticated');
        return;
      }

      // Validate token format
      if (!_isValidToken(token)) {
        Logger.warning('Invalid FCM token format');
        return;
      }

      // Store in user_devices table (recommended approach)
      // This allows multiple devices per user
      await _supabase.from('user_devices').upsert({
        'user_id': userId,
        'fcm_token': token,
        'platform': _getPlatform(),
        'last_active': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'fcm_token');

      Logger.info('FCM token saved successfully');
    } catch (e, stackTrace) {
      Logger.error('Error saving FCM token', e, stackTrace);
      rethrow;
    }
  }

  /// Remove FCM token (e.g., on logout)
  Future<void> removeFCMToken(String token) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        Logger.warning('Cannot remove FCM token: user not authenticated');
        return;
      }

      await _supabase
          .from('user_devices')
          .delete()
          .eq('user_id', userId)
          .eq('fcm_token', token);

      Logger.info('FCM token removed successfully');
    } catch (e, stackTrace) {
      Logger.error('Error removing FCM token', e, stackTrace);
      rethrow;
    }
  }

  /// Update notification preferences
  Future<void> updateNotificationPreferences({
    required bool bookingNotifications,
    required bool messageNotifications,
    required bool paymentNotifications,
    required bool marketingNotifications,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        Logger.warning('Cannot update preferences: user not authenticated');
        return;
      }

      await _supabase.from('notification_preferences').upsert({
        'user_id': userId,
        'booking_notifications': bookingNotifications,
        'message_notifications': messageNotifications,
        'payment_notifications': paymentNotifications,
        'marketing_notifications': marketingNotifications,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      Logger.info('Notification preferences updated');
    } catch (e, stackTrace) {
      Logger.error('Error updating notification preferences', e, stackTrace);
      rethrow;
    }
  }

  /// Get notification preferences
  Future<Map<String, bool>> getNotificationPreferences() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        Logger.warning('Cannot get preferences: user not authenticated');
        return _getDefaultPreferences();
      }

      final response = await _supabase
          .from('notification_preferences')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return _getDefaultPreferences();
      }

      return {
        'booking_notifications': response['booking_notifications'] ?? true,
        'message_notifications': response['message_notifications'] ?? true,
        'payment_notifications': response['payment_notifications'] ?? true,
        'marketing_notifications': response['marketing_notifications'] ?? false,
      };
    } catch (e, stackTrace) {
      Logger.error('Error getting notification preferences', e, stackTrace);
      return _getDefaultPreferences();
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        Logger.warning('Cannot mark notification: user not authenticated');
        return;
      }

      // Validate notification ID
      if (!_isValidId(notificationId)) {
        Logger.warning('Invalid notification ID');
        return;
      }

      await _supabase
          .from('notifications')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('id', notificationId)
          .eq('user_id', userId); // Security: ensure user owns the notification

      Logger.info('Notification marked as read: $notificationId');
    } catch (e, stackTrace) {
      Logger.error('Error marking notification as read', e, stackTrace);
    }
  }

  /// Get unread notification count
  Future<int> getUnreadNotificationCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return 0;
      }

      final response = await _supabase
          .from('notifications')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('user_id', userId)
          .isFilter('read_at', null);

      return response.count ?? 0;
    } catch (e, stackTrace) {
      Logger.error('Error getting unread notification count', e, stackTrace);
      return 0;
    }
  }

  /// Get notification history
  Future<List<Map<String, dynamic>>> getNotificationHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }

      // Validate pagination parameters
      if (limit < 1 || limit > 100) {
        limit = 50;
      }
      if (offset < 0) {
        offset = 0;
      }

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e, stackTrace) {
      Logger.error('Error getting notification history', e, stackTrace);
      return [];
    }
  }

  /// Subscribe to notification updates via realtime
  Stream<List<Map<String, dynamic>>> watchNotifications() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      Logger.warning('Cannot watch notifications: user not authenticated');
      return Stream.value([]);
    }

    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);
  }

  /// Delete old notifications (cleanup)
  Future<void> deleteOldNotifications({int daysToKeep = 30}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return;
      }

      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', userId)
          .lt('created_at', cutoffDate.toIso8601String());

      Logger.info('Old notifications deleted (older than $daysToKeep days)');
    } catch (e, stackTrace) {
      Logger.error('Error deleting old notifications', e, stackTrace);
    }
  }

  // Helper methods

  Map<String, bool> _getDefaultPreferences() {
    return {
      'booking_notifications': true,
      'message_notifications': true,
      'payment_notifications': true,
      'marketing_notifications': false,
    };
  }

  String _getPlatform() {
    // You could use Platform.isAndroid, Platform.isIOS here
    // For now, return a placeholder
    return 'mobile';
  }

  bool _isValidToken(String token) {
    if (token.isEmpty) return false;
    if (token.length < 10 || token.length > 500) return false;
    // FCM tokens are typically alphanumeric with some special chars
    return true;
  }

  bool _isValidId(String id) {
    if (id.isEmpty) return false;
    final idRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    return idRegex.hasMatch(id) && id.length <= 100;
  }
}
