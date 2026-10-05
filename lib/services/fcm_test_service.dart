// lib/services/fcm_test_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:sahaaya/services/notification_service.dart';
import 'package:sahaaya/utils/server_key_generator.dart';

class FCMTestService {
  static final FCMTestService _instance = FCMTestService._internal();
  factory FCMTestService() => _instance;
  FCMTestService._internal();

  final NotificationService _notificationService = NotificationService();
  
  // FCM Server Key - Generated for your project
  static const String _serverKey = 'AAAA1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234';
  
  /// Initialize and print server key info
  static void initialize() {
    ServerKeyGenerator.printInstructions();
    debugPrint('🔑 Using Server Key: ${_serverKey.substring(0, 20)}...');
  }
  
  // FCM endpoint
  static const String _fcmUrl = 'https://fcm.googleapis.com/fcm/send';
  
  // Proxy server endpoint (to avoid CORS issues)
  static const String _proxyUrl = 'http://localhost:3001';

  /// Send test flood alert notification via FCM
  Future<bool> sendTestFloodAlert() async {
    try {
      // Send local notification first
      await _notificationService.showFloodAlert(
        location: 'Amritsar Central',
        severity: 'HIGH',
        additionalInfo: 'Water level rising rapidly. Evacuation recommended.',
      );

      // Get the FCM token
      final fcmToken = await _notificationService.getFCMToken();
      if (fcmToken == null) {
        debugPrint('⚠️ FCM Token is null. Cannot send FCM notification.');
        return false;
      }

      // Send FCM notification
      final success = await _sendFCMNotification(
        token: fcmToken,
        title: '🌊 Flood Alert - Amritsar Central',
        body: 'Severity: HIGH | Water level rising rapidly. Evacuation recommended.',
        data: {
          'type': 'flood_alert',
          'location': 'Amritsar Central',
          'severity': 'HIGH',
          'waterLevel': '2.5m',
          'status': 'Evacuation Recommended',
        },
      );

      if (success) {
        debugPrint('✅ Flood alert sent successfully (Local + FCM)');
      } else {
        debugPrint('⚠️ Local notification sent, FCM failed (check server key)');
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ Error sending flood alert: $e');
      return false;
    }
  }

  /// Send test evacuation alert notification via FCM
  Future<bool> sendTestEvacuationAlert() async {
    try {
      // Send local notification first
      await _notificationService.showEvacuationAlert(
        location: 'Amritsar Central',
        evacuationCenter: 'Guru Nanak Dev University',
      );

      // Get the FCM token
      final fcmToken = await _notificationService.getFCMToken();
      if (fcmToken == null) {
        debugPrint('⚠️ FCM Token is null. Cannot send FCM notification.');
        return false;
      }

      // Send FCM notification
      final success = await _sendFCMNotification(
        token: fcmToken,
        title: '🚨 EVACUATION ALERT',
        body: 'Immediate evacuation required in Amritsar Central\nEvacuation Center: Guru Nanak Dev University',
        data: {
          'type': 'evacuation',
          'location': 'Amritsar Central',
          'evacuationCenter': 'Guru Nanak Dev University',
        },
      );

      if (success) {
        debugPrint('✅ Evacuation alert sent successfully (Local + FCM)');
      } else {
        debugPrint('⚠️ Local notification sent, FCM failed (check server key)');
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ Error sending evacuation alert: $e');
      return false;
    }
  }

  /// Send test weather warning notification via FCM
  Future<bool> sendTestWeatherWarning() async {
    try {
      // Send local notification first
      await _notificationService.showWeatherWarning(
        warningType: 'Heavy Rainfall',
        location: 'Amritsar District',
        duration: 'Next 6 hours',
      );

      // Get the FCM token
      final fcmToken = await _notificationService.getFCMToken();
      if (fcmToken == null) {
        debugPrint('⚠️ FCM Token is null. Cannot send FCM notification.');
        return false;
      }

      // Send FCM notification
      final success = await _sendFCMNotification(
        token: fcmToken,
        title: '⚠️ Weather Warning - Heavy Rainfall',
        body: 'Location: Amritsar District | Duration: Next 6 hours',
        data: {
          'type': 'weather_warning',
          'warningType': 'Heavy Rainfall',
          'location': 'Amritsar District',
          'duration': 'Next 6 hours',
        },
      );

      if (success) {
        debugPrint('✅ Weather warning sent successfully (Local + FCM)');
      } else {
        debugPrint('⚠️ Local notification sent, FCM failed (check server key)');
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ Error sending weather warning: $e');
      return false;
    }
  }

  /// Send FCM notification to your device
  Future<bool> _sendFCMNotification({
    required String token,
    required String title,
    required String body,
    required Map<String, String> data,
  }) async {
    try {
      // Try proxy server first (for web CORS issues)
      if (kIsWeb) {
        return await _sendViaProxy(token, title, body, data);
      }

      // Direct FCM call for mobile platforms
      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',  // Using 'key=' for Firebase Server Key
        },
        body: jsonEncode({
          'to': token,
          'notification': {
            'title': title,
            'body': body,
            'icon': 'ic_launcher',
            'sound': 'default',
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
          'data': data,
          'priority': 'high',
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == 1) {
          debugPrint('✅ FCM notification sent successfully');
          return true;
        } else {
          debugPrint('❌ FCM failed: ${response.body}');
          return false;
        }
      } else {
        debugPrint('❌ FCM failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ FCM error: $e');
      return false;
    }
  }

  /// Send notification via proxy server (for web CORS issues)
  Future<bool> _sendViaProxy(String token, String title, String body, Map<String, String> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_proxyUrl/send-notification'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          'title': title,
          'body': body,
          'data': data,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ FCM notification sent via proxy server');
        return true;
      } else {
        debugPrint('❌ Proxy server failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Proxy server error: $e');
      debugPrint('💡 Make sure to run: npm install && npm start');
      return false;
    }
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    return await _notificationService.getFCMToken();
  }

  /// Check if server key is configured
  bool get isServerKeyConfigured => _serverKey.isNotEmpty && _serverKey.length > 20;

  /// Get server key status
  String get serverKeyStatus => isServerKeyConfigured ? 'Configured' : 'Not configured';
}
