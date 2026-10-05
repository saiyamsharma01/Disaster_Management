import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool _isInitialized = false;
  final bool _supportsLocalNotifications = !kIsWeb;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (_supportsLocalNotifications) {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      await _requestPermissions();
    } else {
      debugPrint('Local notifications are not supported on this platform.');
    }

    await _initializeFirebaseMessaging();

    _isInitialized = true;
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    if (!_supportsLocalNotifications) {
      debugPrint('Skipping local notification permission request on web.');
    } else {
      await Permission.notification.request();
    }

    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        debugPrint('User granted permission');
        break;
      case AuthorizationStatus.provisional:
        debugPrint('User granted provisional permission');
        break;
      case AuthorizationStatus.denied:
      case AuthorizationStatus.notDetermined:
        debugPrint('User declined or has not accepted permission');
        break;
    }
  }

  /// Initialize Firebase messaging
  Future<void> _initializeFirebaseMessaging() async {
    String? token;
    try {
      if (kIsWeb) {
        // For web, a VAPID key is required to obtain an FCM token.
        const String vapidKey = String.fromEnvironment('FCM_VAPID_KEY');
        if (vapidKey.isEmpty) {
          debugPrint(
              'FCM_VAPID_KEY is not set. Skipping FCM token retrieval on web.');
          token = null;
        } else {
          token = await _firebaseMessaging.getToken(vapidKey: vapidKey);
        }
      } else {
        token = await _firebaseMessaging.getToken();
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to obtain FCM token: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    debugPrint('FCM Token: $token');

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    try {
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler,
        );
      }
    } catch (error) {
      debugPrint('Background messaging not supported on this platform: $error');
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');

    // Show local notification for foreground messages
    if (message.notification != null) {
      showLocalNotification(
        title: message.notification!.title ?? 'Flood Alert',
        body: message.notification!.body ?? 'Emergency notification',
        payload: message.data.toString(),
      );
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    // Navigate to appropriate page based on notification data
    _navigateFromNotification(message.data);
  }

  /// Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    // Handle local notification tap
    if (response.payload != null) {
      // Parse payload and navigate accordingly
      _navigateFromPayload(response.payload!);
    }
  }

  /// Show local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    if (!_supportsLocalNotifications) {
      debugPrint(
        'Local notifications are unavailable on this platform. Skipping.',
      );
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'flood_alerts',
          'Flood Alert Notifications',
          channelDescription:
              'Notifications for flood alerts and emergency situations',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF2196F3),
          playSound: true,
          enableVibration: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  /// Show flood alert notification
  Future<void> showFloodAlert({
    required String location,
    required String severity,
    String? additionalInfo,
  }) async {
    String title = '🌊 Flood Alert - $location';
    String body = 'Severity: $severity';

    if (additionalInfo != null) {
      body += '\n$additionalInfo';
    }

    await showLocalNotification(
      title: title,
      body: body,
      payload: 'flood_alert:$location:$severity',
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }

  /// Show emergency evacuation notification
  Future<void> showEvacuationAlert({
    required String location,
    required String evacuationCenter,
  }) async {
    String title = '🚨 EVACUATION ALERT';
    String body =
        'Immediate evacuation required in $location\nEvacuation Center: $evacuationCenter';

    await showLocalNotification(
      title: title,
      body: body,
      payload: 'evacuation:$location:$evacuationCenter',
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }

  /// Show weather warning notification
  Future<void> showWeatherWarning({
    required String warningType,
    required String location,
    required String duration,
  }) async {
    String title = '⚠️ Weather Warning - $warningType';
    String body = 'Location: $location\nDuration: $duration';

    await showLocalNotification(
      title: title,
      body: body,
      payload: 'weather_warning:$warningType:$location',
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }

  /// Navigate from notification data
  void _navigateFromNotification(Map<String, dynamic> data) {
    // This would typically use a navigation service
    // For now, we'll just log the data
    debugPrint('Navigate from notification: $data');
  }

  /// Navigate from payload
  void _navigateFromPayload(String payload) {
    // Parse payload and navigate accordingly
    debugPrint('Navigate from payload: $payload');
  }

  /// Subscribe to flood alert topic
  Future<void> subscribeToFloodAlerts() async {
    if (kIsWeb) {
      debugPrint('Topic subscription not supported on web platform');
      return;
    }

    try {
      await _firebaseMessaging.subscribeToTopic('flood_alerts');
      debugPrint('Subscribed to flood alerts topic');
    } catch (e) {
      debugPrint('Topic subscription not supported on this platform: $e');
    }
  }

  /// Subscribe to location-specific alerts
  Future<void> subscribeToLocationAlerts(String location) async {
    if (kIsWeb) {
      debugPrint('Topic subscription not supported on web platform');
      return;
    }

    try {
      String topic =
          'flood_alerts_${location.toLowerCase().replaceAll(' ', '_')}';
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to location alerts: $topic');
    } catch (e) {
      debugPrint('Topic subscription not supported on this platform: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (kIsWeb) {
      debugPrint('Topic unsubscription not supported on web platform');
      return;
    }

    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Topic unsubscription not supported on this platform: $e');
    }
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    if (kIsWeb) {
      const String vapidKey = String.fromEnvironment('FCM_VAPID_KEY');
      if (vapidKey.isEmpty) {
        debugPrint('FCM_VAPID_KEY is not set; returning null token on web.');
        return null;
      }
      try {
        return await _firebaseMessaging.getToken(vapidKey: vapidKey);
      } catch (e, st) {
        debugPrint('Error getting web FCM token: $e');
        debugPrintStack(stackTrace: st);
        return null;
      }
    }

    try {
      return await _firebaseMessaging.getToken();
    } catch (e, st) {
      debugPrint('Error getting FCM token: $e');
      debugPrintStack(stackTrace: st);
      return null;
    }
  }

  /// Refresh FCM token
  Future<void> refreshFCMToken() async {
    try {
      if (kIsWeb) {
        const String vapidKey = String.fromEnvironment('FCM_VAPID_KEY');
        if (vapidKey.isEmpty) {
          debugPrint('FCM_VAPID_KEY is not set; cannot refresh token on web.');
          return;
        }
        final token = await _firebaseMessaging.getToken(vapidKey: vapidKey);
        debugPrint('FCM token refreshed (web): $token');
        return;
      }

      final token = await _firebaseMessaging.getToken();
      debugPrint('FCM token refreshed: $token');
    } catch (e, st) {
      debugPrint('Error refreshing FCM token: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  /// Schedule recurring flood check notification (for testing)
  Future<void> scheduleFloodCheckNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'flood_check',
          'Flood Check Reminders',
          channelDescription: 'Regular reminders to check flood status',
          importance: Importance.low,
          priority: Priority.low,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    // Schedule notification for every 2 hours (for testing purposes)
    await _localNotifications.periodicallyShow(
      999,
      'Flood Status Check',
      'Remember to check current flood status in your area',
      RepeatInterval.hourly,
      details,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  // Handle background message here
}
