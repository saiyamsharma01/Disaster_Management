// lib/pages/notification_test_page.dart
import 'package:flutter/material.dart';
import 'package:sahaaya/services/fcm_test_service.dart';
import 'package:sahaaya/services/web_notification_service.dart';
import 'package:go_router/go_router.dart';

class NotificationTestPage extends StatefulWidget {
  const NotificationTestPage({super.key});

  @override
  State<NotificationTestPage> createState() => _NotificationTestPageState();
}

class _NotificationTestPageState extends State<NotificationTestPage> {
  final FCMTestService _fcmTestService = FCMTestService();
  final WebNotificationService _webNotificationService = WebNotificationService();
  
  final List<String> _notificationLog = [];

  void _addToLog(String message) {
    setState(() {
      _notificationLog.insert(0, '${DateTime.now().toString().substring(11, 19)}: $message');
      if (_notificationLog.length > 10) {
        _notificationLog.removeLast();
      }
    });
  }

  Future<void> _testFloodAlert() async {
    _addToLog('🌊 Testing Flood Alert...');
    
    // Test local notification
    await _fcmTestService.sendTestFloodAlert();
    
    // Test web notification
    await _webNotificationService.showFloodAlert(
      location: 'Amritsar Central',
      severity: 'HIGH',
      additionalInfo: 'Water level rising rapidly. Evacuation recommended.',
    );
    
    _addToLog('✅ Flood Alert sent (Local + Web)');
  }

  Future<void> _testEvacuationAlert() async {
    _addToLog('🚨 Testing Evacuation Alert...');
    
    // Test local notification
    await _fcmTestService.sendTestEvacuationAlert();
    
    // Test web notification
    await _webNotificationService.showEvacuationAlert(
      location: 'Amritsar Central',
      evacuationCenter: 'Guru Nanak Dev University',
    );
    
    _addToLog('✅ Evacuation Alert sent (Local + Web)');
  }

  Future<void> _testWeatherWarning() async {
    _addToLog('⚠️ Testing Weather Warning...');
    
    // Test local notification
    await _fcmTestService.sendTestWeatherWarning();
    
    // Test web notification
    await _webNotificationService.showWeatherWarning(
      warningType: 'Heavy Rainfall',
      location: 'Amritsar District',
      duration: 'Next 6 hours',
    );
    
    _addToLog('✅ Weather Warning sent (Local + Web)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
          tooltip: 'Back',
        ),
        title: const Text('Notification Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Buttons
            const Text(
              'Test Notifications:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testFloodAlert,
                    icon: const Icon(Icons.water),
                    label: const Text('Flood Alert'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testEvacuationAlert,
                    icon: const Icon(Icons.warning),
                    label: const Text('Evacuation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _testWeatherWarning,
                icon: const Icon(Icons.cloud),
                label: const Text('Weather Warning'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Notification Log
            const Text(
              'Notification Log:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _notificationLog.isEmpty
                    ? const Center(
                        child: Text(
                          'No notifications sent yet.\nClick the buttons above to test!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _notificationLog.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              _notificationLog[index],
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ℹ️ How it works:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Local notifications appear in your app\n'
                    '• Web notifications appear in browser\n'
                    '• No server keys required\n'
                    '• Works on all platforms',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
