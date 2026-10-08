import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sahaaya/services/earthquake_service.dart';
import 'package:sahaaya/services/notification_service.dart';
import 'package:go_router/go_router.dart';

class EarthquakeAlertPage extends StatefulWidget {
  const EarthquakeAlertPage({super.key});

  @override
  State<EarthquakeAlertPage> createState() => _EarthquakeAlertPageState();
}

class _EarthquakeAlertPageState extends State<EarthquakeAlertPage> {
  final EarthquakeService _earthquakeService = EarthquakeService();
  final NotificationService _notificationService = NotificationService();

  List<EarthquakeData> _earthquakes = [];
  bool _isLoading = false;
  String _selectedTimeRange = 'day';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEarthquakeData();
  }

  Future<void> _loadEarthquakeData({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final earthquakes = await _earthquakeService.getEarthquakeData(
        timeRange: _selectedTimeRange,
        forceRefresh: forceRefresh,
      );

      if (mounted) {
        setState(() {
          _earthquakes = earthquakes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'SEVERE':
        return const Color(0xFF991B1B);
      case 'HIGH':
        return const Color(0xFFDC2626);
      case 'MODERATE':
        return const Color(0xFFEA580C);
      case 'MEDIUM':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF059669);
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'SEVERE':
      case 'HIGH':
        return FontAwesomeIcons.triangleExclamation;
      case 'MODERATE':
        return FontAwesomeIcons.circleExclamation;
      default:
        return FontAwesomeIcons.circleInfo;
    }
  }

  Future<void> _sendEarthquakeNotification(EarthquakeData earthquake) async {
    await _notificationService.showLocalNotification(
      title: 'Earthquake Alert · M${earthquake.magnitude.toStringAsFixed(1)}',
      body: '${earthquake.location}\nSeverity: ${earthquake.severityLevel}',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alert sent for ${earthquake.location}'),
          backgroundColor: _getSeverityColor(earthquake.severityLevel),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final highSeverityCount = _earthquakes
        .where((e) => e.severityLevel == 'SEVERE' || e.severityLevel == 'HIGH')
        .length;

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
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(FontAwesomeIcons.volcano, color: Color(0xFFEA580C), size: 16),
            ),
            const SizedBox(width: 10),
            const Text(
              'Earthquake Monitor',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_rounded, color: Color(0xFFEA580C)),
            onPressed: () => context.pushNamed('earthquake_map'),
            tooltip: 'Live Seismic Map',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
            onPressed: () => _loadEarthquakeData(forceRefresh: true),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Color(0xFF64748B)),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Range',
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // Live Seismic Metric Header
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
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
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'USGS GLOBAL SEISMIC FEED',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: Color(0xFFF97316),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _getTimeRangeLabel(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_earthquakes.length}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Seismic Events',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 36, color: Colors.white24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$highSeverityCount',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: highSeverityCount > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                          ),
                        ),
                        const Text(
                          'High / Severe (M5+)',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Error banner
          if (_errorMessage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECDD3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          // Loading Indicator
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFEA580C)),
              ),
            ),

          // Earthquake List
          if (!_isLoading && _earthquakes.isNotEmpty)
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _loadEarthquakeData(forceRefresh: true),
                color: const Color(0xFFEA580C),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: _earthquakes.length,
                  itemBuilder: (context, index) {
                    final earthquake = _earthquakes[index];
                    final severityColor = _getSeverityColor(earthquake.severityLevel);
                    final severityIcon = _getSeverityIcon(earthquake.severityLevel);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: ExpansionTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: severityColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(severityIcon, color: severityColor, size: 18),
                        ),
                        title: Text(
                          earthquake.location,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: severityColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'M ${earthquake.magnitude.toStringAsFixed(1)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                earthquake.timeAgo,
                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.notifications_active_rounded, size: 20),
                          onPressed: () => _sendEarthquakeNotification(earthquake),
                          tooltip: 'Send Alert',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildDetailRow('Time', earthquake.time.toString().substring(0, 19), Icons.access_time_rounded),
                                const SizedBox(height: 8),
                                _buildDetailRow('Depth', '${earthquake.depth.toStringAsFixed(1)} km', Icons.arrow_downward_rounded),
                                const SizedBox(height: 8),
                                _buildDetailRow('Coordinates', '${earthquake.latitude.toStringAsFixed(4)}, ${earthquake.longitude.toStringAsFixed(4)}', Icons.location_on_rounded),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

          // Empty state
          if (!_isLoading && _earthquakes.isEmpty && _errorMessage == null)
            const Expanded(
              child: Center(
                child: Text('No earthquakes recorded in selected timeframe.'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 12),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  String _getTimeRangeLabel() {
    switch (_selectedTimeRange) {
      case 'week':
        return 'Past Week';
      case 'significant':
        return 'Significant (Month)';
      case 'major':
        return 'Major (M4.5+)';
      default:
        return 'Past 24 Hours';
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Filter Earthquakes', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Past 24 Hours'),
              value: 'day',
              groupValue: _selectedTimeRange,
              onChanged: (v) {
                setState(() => _selectedTimeRange = v!);
                Navigator.pop(context);
                _loadEarthquakeData();
              },
            ),
            RadioListTile<String>(
              title: const Text('Past Week'),
              value: 'week',
              groupValue: _selectedTimeRange,
              onChanged: (v) {
                setState(() => _selectedTimeRange = v!);
                Navigator.pop(context);
                _loadEarthquakeData();
              },
            ),
            RadioListTile<String>(
              title: const Text('Major (M4.5+ Past Week)'),
              value: 'major',
              groupValue: _selectedTimeRange,
              onChanged: (v) {
                setState(() => _selectedTimeRange = v!);
                Navigator.pop(context);
                _loadEarthquakeData();
              },
            ),
          ],
        ),
      ),
    );
  }
}
