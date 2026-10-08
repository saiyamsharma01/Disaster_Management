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

  // Flood alert monitoring stations data
  final List<Map<String, dynamic>> _floodAlerts = [
    {
      'id': '1',
      'location': 'Amritsar Central Canal',
      'severity': 'HIGH',
      'waterLevel': 2.8,
      'threshold': 3.0,
      'status': 'Evacuation Advisory Active',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 20)),
      'color': const Color(0xFFDC2626),
    },
    {
      'id': '2',
      'location': 'Ravi River Basin Sector 4',
      'severity': 'MEDIUM',
      'waterLevel': 1.6,
      'threshold': 2.5,
      'status': 'Water Rising Moderately',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 45)),
      'color': const Color(0xFFEA580C),
    },
    {
      'id': '3',
      'location': 'Beas River Lowland Gauge',
      'severity': 'LOW',
      'waterLevel': 0.8,
      'threshold': 2.0,
      'status': 'Normal Seasonal Flow',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      'color': const Color(0xFF059669),
    },
  ];

  Future<void> _sendTestFloodAlert() async {
    _fcmTestService.sendTestFloodAlert();
    await _notificationService.showFloodAlert(
      location: 'Amritsar Central Canal',
      severity: 'HIGH',
      additionalInfo: 'Water level at 2.8m. Evacuation recommended immediately.',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🌊 Live Flood Alert broadcasted!'),
          backgroundColor: const Color(0xFF0284C7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _sendTestEvacuationAlert() async {
    await _notificationService.showEvacuationAlert(
      location: 'Amritsar Central',
      evacuationCenter: 'Guru Nanak Dev University Shelter Hub',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🚨 Evacuation Order broadcasted!'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _sendTestWeatherWarning() async {
    await _notificationService.showWeatherWarning(
      warningType: 'Heavy Inundation Warning',
      location: 'Amritsar District & Catchment',
      duration: 'Next 6 hours',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('⚠️ Weather Warning broadcasted!'),
          backgroundColor: const Color(0xFFD97706),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
          tooltip: 'Back',
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(FontAwesomeIcons.water, color: Color(0xFF0284C7), size: 16),
            ),
            const SizedBox(width: 10),
            const Text(
              'Flood & Water Radar',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Water Status Hero Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0369A1), Color(0xFF0284C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.sensors_rounded, color: Colors.white, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'HYDROLOGICAL GAUGES ACTIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'Live Telemetry',
                        style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Active Catchment Sensors',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_floodAlerts.length} Monitoring Stations',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: Colors.white, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Highest recorded level: 2.8m at Amritsar Central (Critical)',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Emergency Dispatch Buttons
            const Text(
              'Broadcast Test Emergency Alerts',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildActionBtn(
                    label: 'Flood Warning',
                    icon: Icons.water_drop_rounded,
                    color: const Color(0xFF0284C7),
                    onTap: _sendTestFloodAlert,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionBtn(
                    label: 'Evacuation',
                    icon: Icons.warning_rounded,
                    color: const Color(0xFFDC2626),
                    onTap: _sendTestEvacuationAlert,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionBtn(
                    label: 'Weather Alert',
                    icon: Icons.thunderstorm_rounded,
                    color: const Color(0xFFD97706),
                    onTap: _sendTestWeatherWarning,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Live Stations List
            const Text(
              'Hydrological Stations Status',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _floodAlerts.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final alert = _floodAlerts[i];
                final Color col = alert['color'] as Color;
                final double level = alert['waterLevel'] as double;
                final double threshold = alert['threshold'] as double;
                final double progress = (level / threshold).clamp(0.0, 1.0);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: col.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(FontAwesomeIcons.water, color: col, size: 16),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                alert['location'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: col.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              alert['severity'],
                              style: TextStyle(
                                color: col,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Water Level: ${level}m',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: col),
                          ),
                          Text(
                            'Danger Mark: ${threshold}m',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: AlwaysStoppedAnimation<Color>(col),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        alert['status'],
                        style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
