import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/logger.dart';
import 'models/notification_payload.dart';

/// Top-level function for handling background messages
/// Must be top-level or static
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Don't call Firebase.initializeApp() here - it's already initialized
  Logger.info('Handling background message: ${message.messageId}');

  // Validate message data
  final payload = NotificationPayload.fromRemoteMessage(
    message.data,
    message.notification?.title,
    message.notification?.body,
  );

  // Only process valid notifications
  if (!payload.isValid) {
    Logger.warning('Invalid notification payload in background: ${message.data}');
    return;
  }

  Logger.info('Background message processed: ${payload.type.value}');
}

/// Service for handling Firebase Cloud Messaging and local notifications
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Stream controller for notification taps
  final StreamController<NotificationPayload> _notificationTapController =
      StreamController<NotificationPayload>.broadcast();

  Stream<NotificationPayload> get onNotificationTap =>
      _notificationTapController.stream;

  bool _initialized = false;
  String? _fcmToken;

  /// Get the current FCM token
  String? get fcmToken => _fcmToken;

  /// Initialize notification service
  Future<void> initialize({
    required Function(NotificationPayload) onForegroundMessage,
  }) async {
    if (_initialized) {
      Logger.warning('NotificationService already initialized');
      return;
    }

    try {
      Logger.info('Initializing NotificationService...');

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permissions
      final granted = await requestPermissions();
      if (!granted) {
        Logger.warning('Notification permissions not granted');
        _initialized = true;
        return;
      }

      // Get FCM token
      await _getFCMToken();

      // Set up message handlers
      _setupMessageHandlers(onForegroundMessage);

      // Handle notification taps when app is terminated
      await _handleInitialMessage();

      _initialized = true;
      Logger.info('NotificationService initialized successfully');
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize NotificationService', e, stackTrace);
      rethrow;
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // We'll request this separately
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    // Create Android notification channels
    if (Platform.isAndroid) {
      await _createAndroidNotificationChannels();
    }
  }

  /// Create Android notification channels
  Future<void> _createAndroidNotificationChannels() async {
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // High importance channel for booking-related notifications
    const bookingChannel = AndroidNotificationChannel(
      'booking_notifications',
      'Booking Notifications',
      description: 'Notifications about bookings and reservations',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    // Default importance channel for messages
    const messageChannel = AndroidNotificationChannel(
      'message_notifications',
      'Message Notifications',
      description: 'Notifications about new messages',
      importance: Importance.defaultImportance,
      enableVibration: true,
      playSound: true,
    );

    // Default channel for other notifications
    const generalChannel = AndroidNotificationChannel(
      'general_notifications',
      'General Notifications',
      description: 'General app notifications',
      importance: Importance.defaultImportance,
      enableVibration: true,
      playSound: true,
    );

    await androidPlugin.createNotificationChannel(bookingChannel);
    await androidPlugin.createNotificationChannel(messageChannel);
    await androidPlugin.createNotificationChannel(generalChannel);
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      // Request Firebase Messaging permissions (iOS)
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        Logger.warning('User denied notification permissions');
        return false;
      }

      // Request system notification permissions (Android 13+)
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        if (!status.isGranted) {
          Logger.warning('Android notification permission not granted');
          return false;
        }
      }

      Logger.info('Notification permissions granted');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Error requesting notification permissions', e, stackTrace);
      return false;
    }
  }

  /// Get and store FCM token
  Future<void> _getFCMToken() async {
    try {
      // Get APNs token first for iOS
      if (Platform.isIOS) {
        final apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken == null) {
          Logger.warning('APNs token not available yet');
          // Set up listener for when it becomes available
          _firebaseMessaging.onTokenRefresh.listen((token) {
            _fcmToken = token;
            Logger.info('FCM token refreshed: ${token.substring(0, 20)}...');
          });
          return;
        }
      }

      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        Logger.info('FCM token obtained: ${_fcmToken!.substring(0, 20)}...');
        // TODO: Send token to backend to store in database
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((token) {
        _fcmToken = token;
        Logger.info('FCM token refreshed: ${token.substring(0, 20)}...');
        // TODO: Update token in backend
      });
    } catch (e, stackTrace) {
      Logger.error('Error getting FCM token', e, stackTrace);
    }
  }

  /// Set up message handlers for different app states
  void _setupMessageHandlers(
    Function(NotificationPayload) onForegroundMessage,
  ) {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Logger.info('Received foreground message: ${message.messageId}');

      // Validate and parse message
      final payload = NotificationPayload.fromRemoteMessage(
        message.data,
        message.notification?.title,
        message.notification?.body,
      );

      // Security check: only process valid notifications
      if (!payload.isValid) {
        Logger.warning('Invalid notification payload: ${message.data}');
        return;
      }

      // Show local notification
      _showLocalNotification(message, payload);

      // Notify app about foreground message
      onForegroundMessage(payload);
    });

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Logger.info('Notification tapped (background): ${message.messageId}');
      _handleMessageTap(message);
    });
  }

  /// Handle notification tap from local notifications
  void _handleNotificationTap(NotificationResponse response) {
    Logger.info('Local notification tapped: ${response.payload}');

    if (response.payload == null) return;

    try {
      // Parse the stored payload
      final data = Map<String, dynamic>.from(
        response.payload as Map? ?? {},
      );

      final payload = NotificationPayload.fromRemoteMessage(data, null, null);

      if (payload.isValid) {
        _notificationTapController.add(payload);
      }
    } catch (e, stackTrace) {
      Logger.error('Error handling notification tap', e, stackTrace);
    }
  }

  /// Handle message tap from FCM
  void _handleMessageTap(RemoteMessage message) {
    final payload = NotificationPayload.fromRemoteMessage(
      message.data,
      message.notification?.title,
      message.notification?.body,
    );

    if (payload.isValid) {
      _notificationTapController.add(payload);
    }
  }

  /// Handle initial message when app is opened from terminated state
  Future<void> _handleInitialMessage() async {
    final initialMessage = await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      Logger.info('App opened from notification: ${initialMessage.messageId}');
      _handleMessageTap(initialMessage);
    }
  }

  /// Show local notification for foreground messages
  Future<void> _showLocalNotification(
    RemoteMessage message,
    NotificationPayload payload,
  ) async {
    try {
      final notification = message.notification;
      if (notification == null) return;

      // Determine channel based on notification type
      final channelId = _getChannelId(payload.type);

      // Android notification details
      final androidDetails = AndroidNotificationDetails(
        channelId,
        _getChannelName(channelId),
        channelDescription: _getChannelDescription(channelId),
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      // iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        message.hashCode, // Use message hashCode as unique ID
        notification.title,
        notification.body,
        notificationDetails,
        payload: message.data.toString(), // Store data for tap handling
      );
    } catch (e, stackTrace) {
      Logger.error('Error showing local notification', e, stackTrace);
    }
  }

  /// Get Android channel ID based on notification type
  String _getChannelId(NotificationType type) {
    switch (type) {
      case NotificationType.bookingRequest:
      case NotificationType.bookingConfirmed:
      case NotificationType.bookingCancelled:
        return 'booking_notifications';
      case NotificationType.newMessage:
        return 'message_notifications';
      default:
        return 'general_notifications';
    }
  }

  /// Get channel name
  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'booking_notifications':
        return 'Booking Notifications';
      case 'message_notifications':
        return 'Message Notifications';
      default:
        return 'General Notifications';
    }
  }

  /// Get channel description
  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'booking_notifications':
        return 'Notifications about bookings and reservations';
      case 'message_notifications':
        return 'Notifications about new messages';
      default:
        return 'General app notifications';
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      // Validate topic name (alphanumeric, dashes, underscores only)
      final topicRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
      if (!topicRegex.hasMatch(topic)) {
        Logger.warning('Invalid topic name: $topic');
        return;
      }

      await _firebaseMessaging.subscribeToTopic(topic);
      Logger.info('Subscribed to topic: $topic');
    } catch (e, stackTrace) {
      Logger.error('Error subscribing to topic', e, stackTrace);
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      Logger.info('Unsubscribed from topic: $topic');
    } catch (e, stackTrace) {
      Logger.error('Error unsubscribing from topic', e, stackTrace);
    }
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      Logger.info('FCM token deleted');
    } catch (e, stackTrace) {
      Logger.error('Error deleting FCM token', e, stackTrace);
    }
  }

  /// Dispose resources
  void dispose() {
    _notificationTapController.close();
  }
}
