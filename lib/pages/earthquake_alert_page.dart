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

  Future<void> _loadEarthquakeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final earthquakes = await _earthquakeService.getEarthquakeData(
        timeRange: _selectedTimeRange,
      );

      setState(() {
        _earthquakes = earthquakes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'SEVERE':
        return Colors.red.shade900;
      case 'HIGH':
        return Colors.red;
      case 'MODERATE':
        return Colors.orange;
      case 'MEDIUM':
        return Colors.yellow.shade700;
      default:
        return Colors.green;
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
      title: 'Earthquake Alert',
      body: '${earthquake.location}\nMagnitude: ${earthquake.magnitude
          .toStringAsFixed(1)} - ${earthquake.severityLevel}',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alert sent for ${earthquake.location}'),
          backgroundColor: _getSeverityColor(earthquake.severityLevel),
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
        title: const Text('Earthquake Alerts'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              context.pushNamed('earthquake_map');
            },
            tooltip: 'View Map',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEarthquakeData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade50, Colors.red.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(FontAwesomeIcons.globe, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      'Live Earthquake Data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Events: ${_earthquakes.length}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'High Severity: $highSeverityCount',
                  style: TextStyle(
                    fontSize: 16,
                    color: highSeverityCount > 0 ? Colors.red.shade700 : Colors
                        .grey[700],
                    fontWeight: highSeverityCount > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Time Range: ${_getTimeRangeLabel()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Data Source: USGS',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          // Error Message
          if (_errorMessage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),

          // Loading Indicator
          if (_isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading earthquake data...'),
                  ],
                ),
              ),
            ),

          // Earthquake List
          if (!_isLoading && _earthquakes.isNotEmpty)
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadEarthquakeData,
                child: ListView.builder(
                  itemCount: _earthquakes.length,
                  itemBuilder: (context, index) {
                    final earthquake = _earthquakes[index];
                    final severityColor = _getSeverityColor(
                        earthquake.severityLevel);
                    final severityIcon = _getSeverityIcon(
                        earthquake.severityLevel);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      elevation: 2,
                      child: ExpansionTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: severityColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            severityIcon,
                            color: severityColor,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          earthquake.location,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: severityColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'M ${earthquake.magnitude.toStringAsFixed(
                                        1)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  earthquake.severityLevel,
                                  style: TextStyle(
                                    color: severityColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              earthquake.timeAgo,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.notifications_active),
                          onPressed: () =>
                              _sendEarthquakeNotification(earthquake),
                          tooltip: 'Send Alert',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow(
                                  'Time',
                                  earthquake.time.toString().substring(0, 19),
                                  Icons.access_time,
                                ),
                                const SizedBox(height: 8),
                                _buildDetailRow(
                                  'Depth',
                                  '${earthquake.depth.toStringAsFixed(1)} km',
                                  Icons.arrow_downward,
                                ),
                                const SizedBox(height: 8),
                                _buildDetailRow(
                                  'Coordinates',
                                  '${earthquake.latitude.toStringAsFixed(
                                      4)}, ${earthquake.longitude
                                      .toStringAsFixed(4)}',
                                  Icons.location_on,
                                ),
                                if (earthquake.tsunami != null) ...[
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    'Tsunami',
                                    earthquake.tsunami == '1'
                                        ? 'Possible'
                                        : 'No',
                                    Icons.waves,
                                    color: earthquake.tsunami == '1' ? Colors
                                        .red : Colors.green,
                                  ),
                                ],
                                if (earthquake.alert != null) ...[
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    'Alert',
                                    earthquake.alert!.toUpperCase(),
                                    Icons.warning,
                                    color: Colors.orange,
                                  ),
                                ],
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

          // Empty State
          if (!_isLoading && _earthquakes.isEmpty && _errorMessage == null)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.circleCheck,
                      size: 64,
                      color: Colors.green,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No earthquakes detected',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'in the selected time range',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon,
      {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: color ?? Colors.grey[800],
              fontSize: 13,
            ),
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
        return 'Major (M4.5+, Week)';
      default:
        return 'Past 24 Hours';
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Filter Earthquakes'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('Past 24 Hours'),
                  subtitle: const Text('All earthquakes'),
                  value: 'day',
                  groupValue: _selectedTimeRange,
                  onChanged: (value) {
                    setState(() {
                      _selectedTimeRange = value!;
                    });
                    Navigator.pop(context);
                    _loadEarthquakeData();
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Past Week'),
                  subtitle: const Text('All earthquakes'),
                  value: 'week',
                  groupValue: _selectedTimeRange,
                  onChanged: (value) {
                    setState(() {
                      _selectedTimeRange = value!;
                    });
                    Navigator.pop(context);
                    _loadEarthquakeData();
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Major Events'),
                  subtitle: const Text('M4.5+ past week'),
                  value: 'major',
                  groupValue: _selectedTimeRange,
                  onChanged: (value) {
                    setState(() {
                      _selectedTimeRange = value!;
                    });
                    Navigator.pop(context);
                    _loadEarthquakeData();
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Significant Events'),
                  subtitle: const Text('Past month'),
                  value: 'significant',
                  groupValue: _selectedTimeRange,
                  onChanged: (value) {
                    setState(() {
                      _selectedTimeRange = value!;
                    });
                    Navigator.pop(context);
                    _loadEarthquakeData();
                  },
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
