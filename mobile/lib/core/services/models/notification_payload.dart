import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_payload.freezed.dart';
part 'notification_payload.g.dart';

/// Notification types that the app can handle
enum NotificationType {
  bookingRequest('booking_request'),
  bookingConfirmed('booking_confirmed'),
  bookingCancelled('booking_cancelled'),
  newMessage('new_message'),
  paymentReceived('payment_received'),
  reviewReceived('review_received'),
  guideApproved('guide_approved'),
  unknown('unknown');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String? value) {
    if (value == null || value.isEmpty) return NotificationType.unknown;

    try {
      return NotificationType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => NotificationType.unknown,
      );
    } catch (e) {
      return NotificationType.unknown;
    }
  }
}

/// Notification payload data model with security validation
@freezed
class NotificationPayload with _$NotificationPayload {
  const NotificationPayload._();

  const factory NotificationPayload({
    required String title,
    required String body,
    required NotificationType type,
    String? bookingId,
    String? messageId,
    String? userId,
    String? screen,
    Map<String, dynamic>? additionalData,
  }) = _NotificationPayload;

  factory NotificationPayload.fromJson(Map<String, dynamic> json) =>
      _$NotificationPayloadFromJson(json);

  /// Create from FCM RemoteMessage data with validation
  factory NotificationPayload.fromRemoteMessage(
    Map<String, dynamic> data,
    String? title,
    String? body,
  ) {
    // Validate and sanitize inputs
    final sanitizedTitle = _sanitizeString(title) ?? 'Notification';
    final sanitizedBody = _sanitizeString(body) ?? '';

    // Parse notification type with fallback
    final typeString = _sanitizeString(data['type']);
    final notificationType = NotificationType.fromString(typeString);

    // Validate and sanitize IDs (must be alphanumeric, dashes, underscores only)
    final bookingId = _validateId(data['booking_id']);
    final messageId = _validateId(data['message_id']);
    final userId = _validateId(data['user_id']);

    // Validate screen path (must start with / and contain only safe characters)
    final screen = _validateScreenPath(data['screen']);

    return NotificationPayload(
      title: sanitizedTitle,
      body: sanitizedBody,
      type: notificationType,
      bookingId: bookingId,
      messageId: messageId,
      userId: userId,
      screen: screen,
      additionalData: data,
    );
  }

  /// Sanitize string input to prevent XSS
  static String? _sanitizeString(dynamic value) {
    if (value == null) return null;
    if (value is! String) return null;

    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    // Remove any HTML tags and suspicious characters
    final sanitized = trimmed
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'''[<>&"']'''), '') // Remove special chars
        .substring(0, trimmed.length > 500 ? 500 : trimmed.length); // Limit length

    return sanitized.isEmpty ? null : sanitized;
  }

  /// Validate ID format (alphanumeric, dashes, underscores only)
  static String? _validateId(dynamic value) {
    if (value == null) return null;
    if (value is! String) return null;

    final trimmed = value.trim();

    // Must be alphanumeric with dashes/underscores only
    final idRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!idRegex.hasMatch(trimmed)) return null;

    // Reasonable length limit
    if (trimmed.length > 100) return null;

    return trimmed;
  }

  /// Validate screen path format
  static String? _validateScreenPath(dynamic value) {
    if (value == null) return null;
    if (value is! String) return null;

    final trimmed = value.trim();

    // Must start with /
    if (!trimmed.startsWith('/')) return null;

    // Safe path characters only: alphanumeric, /, -, _
    final pathRegex = RegExp(r'^/[a-zA-Z0-9/_-]*$');
    if (!pathRegex.hasMatch(trimmed)) return null;

    // Reasonable length limit
    if (trimmed.length > 200) return null;

    return trimmed;
  }

  /// Check if notification has valid data for navigation
  bool get canNavigate {
    return screen != null && screen!.isNotEmpty;
  }

  /// Check if notification is valid
  bool get isValid {
    return type != NotificationType.unknown &&
           title.isNotEmpty &&
           body.isNotEmpty;
  }
}

/// Notification display data
@freezed
class NotificationDisplay with _$NotificationDisplay {
  const factory NotificationDisplay({
    required int id,
    required String title,
    required String body,
    String? imageUrl,
    String? channelId,
    String? channelName,
    @Default(true) bool showBadge,
    @Default(true) bool playSound,
    @Default(true) bool enableVibration,
  }) = _NotificationDisplay;

  factory NotificationDisplay.fromJson(Map<String, dynamic> json) =>
      _$NotificationDisplayFromJson(json);
}
