import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sahaaya/services/notification_service.dart';
import 'package:sahaaya/services/fcm_test_service.dart';
import 'package:go_router/go_router.dart';

class FloodAlertPage extends StatefulWidget {
  const FloodAlertPage({super.key});

  @override
  State<FloodAlertPage> createState() => _FloodAlertPageState();
}

class _FloodAlertPageState extends State<FloodAlertPage> {
  final NotificationService _notificationService = NotificationService();
  final FCMTestService _fcmTestService = FCMTestService();
  
  // Sample flood alert data
  final List<Map<String, dynamic>> _floodAlerts = [
    {
      'id': '1',
      'location': 'Amritsar Central',
      'severity': 'HIGH',
      'waterLevel': 2.5,
      'status': 'Evacuation Recommended',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      'color': Colors.red,
    },
    {
      'id': '2',
      'location': 'Golden Temple Area',
      'severity': 'MEDIUM',
      'waterLevel': 1.2,
      'status': 'Stay Alert',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'color': Colors.orange,
    },
    {
      'id': '3',
      'location': 'Railway Station',
      'severity': 'LOW',
      'waterLevel': 0.5,
      'status': 'Monitor Situation',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      'color': Colors.yellow,
    },
  ];

  @override
  void initState() {
    super.initState();
    _subscribeToAlerts();
  }

  Future<void> _subscribeToAlerts() async {
    // Note: Topic subscription is not supported on web
    // Only local notifications are used for web platform
    debugPrint('Local notifications initialized for flood alerts');
  }

  Future<void> _sendTestFloodAlert() async {
    await _notificationService.showFloodAlert(
      location: 'Amritsar Central',
      severity: 'HIGH',
      additionalInfo: 'Water level rising rapidly. Evacuation recommended.',
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test flood alert sent!'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Future<void> _sendTestEvacuationAlert() async {
    await _notificationService.showEvacuationAlert(
      location: 'Amritsar Central',
      evacuationCenter: 'Guru Nanak Dev University',
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test evacuation alert sent!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendTestWeatherWarning() async {
    await _notificationService.showWeatherWarning(
      warningType: 'Heavy Rainfall',
      location: 'Amritsar District',
      duration: 'Next 6 hours',
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test weather warning sent!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // Real-time Test Methods (Local + Web)
  Future<void> _sendFCMFloodAlert() async {
    final success = await _fcmTestService.sendTestFloodAlert();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '🌊 Flood Alert sent (Local + Web)!' : 'Failed to send alert'),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _sendFCMEvacuationAlert() async {
    final success = await _fcmTestService.sendTestEvacuationAlert();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '🚨 Evacuation Alert sent (Local + Web)!' : 'Failed to send alert'),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _sendFCMWeatherWarning() async {
    final success = await _fcmTestService.sendTestWeatherWarning();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '⚠️ Weather Warning sent (Local + Web)!' : 'Failed to send alert'),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
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
        title: const Row(
          children: [
            Icon(FontAwesomeIcons.water, color: Colors.blue),
            SizedBox(width: 10),
            Text('Flood Alerts'),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: _showNotificationSettings,
            tooltip: 'Notification Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Alert Status Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(FontAwesomeIcons.triangleExclamation, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text(
                      'Current Alert Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Active Alerts: ${_floodAlerts.length}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last Updated: ${DateTime.now().toString().substring(11, 16)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Test Notifications Section
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Test Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Local Notifications
                const Text(
                  'Local Notifications:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _sendTestFloodAlert,
                        icon: const Icon(Icons.water, size: 16),
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
                        onPressed: _sendTestEvacuationAlert,
                        icon: const Icon(Icons.warning, size: 16),
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
                    onPressed: _sendTestWeatherWarning,
                    icon: const Icon(Icons.cloud, size: 16),
                    label: const Text('Weather Warning'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                
                // Real-time Notifications (Local + Web)
                const Text(
                  'Real-time Notifications (Local + Web):',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _sendFCMFloodAlert,
                        icon: const Icon(Icons.cloud_upload, size: 16),
                        label: const Text('Real-time Flood'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _sendFCMEvacuationAlert,
                        icon: const Icon(Icons.cloud_upload, size: 16),
                        label: const Text('Real-time Evacuation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
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
                    onPressed: _sendFCMWeatherWarning,
                    icon: const Icon(Icons.cloud_upload, size: 16),
                    label: const Text('Real-time Weather Warning'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Active Alerts List
          Expanded(
            child: ListView.builder(
              itemCount: _floodAlerts.length,
              itemBuilder: (context, index) {
                final alert = _floodAlerts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: alert['color'],
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      alert['location'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Severity: ${alert['severity']}'),
                        Text('Water Level: ${alert['waterLevel']}m'),
                        Text('Status: ${alert['status']}'),
                        Text(
                          'Updated: ${alert['timestamp'].toString().substring(11, 16)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () => _sendSpecificAlert(alert),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendSpecificAlert(Map<String, dynamic> alert) async {
    await _notificationService.showFloodAlert(
      location: alert['location'],
      severity: alert['severity'],
      additionalInfo: 'Water Level: ${alert['waterLevel']}m - ${alert['status']}',
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alert sent for ${alert['location']}'),
          backgroundColor: alert['color'],
        ),
      );
    }
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.water),
              title: const Text('Flood Alerts'),
              subtitle: const Text('Receive flood warnings'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // Handle flood alerts toggle
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text('Evacuation Alerts'),
              subtitle: const Text('Emergency evacuation notices'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // Handle evacuation alerts toggle
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.cloud),
              title: const Text('Weather Warnings'),
              subtitle: const Text('Weather-related alerts'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // Handle weather warnings toggle
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
