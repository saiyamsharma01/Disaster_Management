// lib/pages/fcm_test_page.dart
import 'package:flutter/material.dart';
import 'package:sahaaya/services/fcm_test_service.dart';
import 'package:sahaaya/services/notification_service.dart';
import 'package:go_router/go_router.dart';

class FCMTestPage extends StatefulWidget {
  const FCMTestPage({super.key});

  @override
  State<FCMTestPage> createState() => _FCMTestPageState();
}

class _FCMTestPageState extends State<FCMTestPage> {
  final FCMTestService _fcmTestService = FCMTestService();
  final NotificationService _notificationService = NotificationService();
  
  String? _fcmToken;
  final List<String> _testLog = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFCMToken();
  }

  Future<void> _loadFCMToken() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final token = await _notificationService.getFCMToken();
      setState(() {
        _fcmToken = token;
        _isLoading = false;
      });
      
      if (token != null) {
        _addToLog('✅ FCM Token loaded: ${token.substring(0, 15)}...');
      } else {
        _addToLog('⚠️ FCM Token is null. Check Firebase setup.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _addToLog('❌ Error loading FCM token: $e');
    }
  }

  void _addToLog(String message) {
    setState(() {
      _testLog.insert(0, '${DateTime.now().toString().substring(11, 19)}: $message');
      if (_testLog.length > 15) {
        _testLog.removeLast();
      }
    });
  }

  Future<void> _testFloodAlert() async {
    _addToLog('🌊 Testing Flood Alert...');
    
    final success = await _fcmTestService.sendTestFloodAlert();
    
    if (success) {
      _addToLog('✅ Flood Alert sent successfully!');
    } else {
      _addToLog('❌ Flood Alert failed');
    }
  }

  Future<void> _testEvacuationAlert() async {
    _addToLog('🚨 Testing Evacuation Alert...');
    
    final success = await _fcmTestService.sendTestEvacuationAlert();
    
    if (success) {
      _addToLog('✅ Evacuation Alert sent successfully!');
    } else {
      _addToLog('❌ Evacuation Alert failed');
    }
  }

  Future<void> _testWeatherWarning() async {
    _addToLog('⚠️ Testing Weather Warning...');
    
    final success = await _fcmTestService.sendTestWeatherWarning();
    
    if (success) {
      _addToLog('✅ Weather Warning sent successfully!');
    } else {
      _addToLog('❌ Weather Warning failed');
    }
  }

  Future<void> _refreshToken() async {
    _addToLog('🔄 Refreshing FCM token...');
    await _loadFCMToken();
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
        title: const Text('FCM Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FCM Token Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '🔑 Your FCM Token:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.blue),
                        onPressed: _refreshToken,
                        tooltip: 'Refresh FCM Token',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _fcmToken ?? 'No FCM token available',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                  const SizedBox(height: 8),
                  Text(
                    'Server Key: ${_fcmTestService.serverKeyStatus}',
                    style: TextStyle(
                      color: _fcmTestService.isServerKeyConfigured ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test Buttons
            const Text(
              'Test FCM Notifications:',
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
            
            // Test Log
            const Text(
              'Test Log:',
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
                child: _testLog.isEmpty
                    ? const Center(
                        child: Text(
                          'No tests run yet.\nClick the buttons above to test FCM!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _testLog.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              _testLog[index],
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
          ],
        ),
      ),
    );
  }
}
