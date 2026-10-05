// lib/services/web_notification_service.dart
import 'package:flutter/foundation.dart';

class WebNotificationService {
  static final WebNotificationService _instance = WebNotificationService._internal();
  factory WebNotificationService() => _instance;
  WebNotificationService._internal();

  /// Show browser notification (Web only)
  Future<void> showNotification(String title, String body) async {
    if (kIsWeb) {
      try {
        // Request notification permission first
        if (await _requestNotificationPermission()) {
          await _showWebNotification(title, body);
        } else {
          debugPrint('Notification permission denied');
        }
      } catch (e) {
        debugPrint('Browser notification not supported: $e');
      }
    }
  }

  /// Request notification permission
  Future<bool> _requestNotificationPermission() async {
    try {
      // This would be implemented with web-specific code
      // For now, we'll simulate permission granted
      debugPrint('Notification permission requested');
      return true;
    } catch (e) {
      debugPrint('Permission request failed: $e');
      return false;
    }
  }

  /// Show web notification
  Future<void> _showWebNotification(String title, String body) async {
    try {
      // This would be implemented with web-specific notification API
      // For now, we'll just log it and show a snackbar
      debugPrint('Web Notification: $title - $body');
      
      // You could also show a dialog or snackbar here
      // This is a fallback for when browser notifications aren't available
    } catch (e) {
      debugPrint('Web notification failed: $e');
    }
  }

  /// Show flood alert notification
  Future<void> showFloodAlert({
    required String location,
    required String severity,
    String? additionalInfo,
  }) async {
    final title = '🌊 Flood Alert - $location';
    final body = 'Severity: $severity${additionalInfo != null ? '\n$additionalInfo' : ''}';
    
    await showNotification(title, body);
  }

  /// Show evacuation alert notification
  Future<void> showEvacuationAlert({
    required String location,
    required String evacuationCenter,
  }) async {
    final title = '🚨 EVACUATION ALERT';
    final body = 'Immediate evacuation required in $location\nEvacuation Center: $evacuationCenter';
    
    await showNotification(title, body);
  }

  /// Show weather warning notification
  Future<void> showWeatherWarning({
    required String warningType,
    required String location,
    required String duration,
  }) async {
    final title = '⚠️ Weather Warning - $warningType';
    final body = 'Location: $location | Duration: $duration';
    
    await showNotification(title, body);
  }
}
