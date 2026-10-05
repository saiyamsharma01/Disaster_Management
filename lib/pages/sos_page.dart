import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:sahaaya/services/notification_service.dart';
import 'package:go_router/go_router.dart';

class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  static const double _clusterMergeDistanceMeters = 1200; // 1.2 km to merge alerts
  static const double _coreRadiusMeters = 800; // Red core radius (~0.8 km)
  static const double _cautionRadiusMeters = 3500; // Yellow caution radius (~3.5 km)

  final MapController _mapController = MapController();
  static const double _centerLat = 31.6340;
  static const double _centerLng = 74.8723; // Amritsar center
  final NotificationService _notificationService = NotificationService();

  static final List<_AlertData> _demoAlerts = [
    _AlertData(
      latitude: 31.6208,
      longitude: 74.8765,
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      title: 'Golden Temple Precinct',
      description: 'Multiple visitors raised alerts near the main entrance.',
      isDemo: true,
    ),
    _AlertData(
      latitude: 31.6215,
      longitude: 74.8741,
      timestamp: DateTime.now().subtract(const Duration(minutes: 11)),
      title: 'Golden Temple Precinct',
      description: 'Coordinated SOS from volunteers on patrol.',
      isDemo: true,
    ),
    _AlertData(
      latitude: 31.6226,
      longitude: 74.8782,
      timestamp: DateTime.now().subtract(const Duration(minutes: 14)),
      title: 'Golden Temple Precinct',
      description: 'Independent alert confirms crowd distress.',
      isDemo: true,
    ),
    _AlertData(
      latitude: 31.6398,
      longitude: 74.8729,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      title: 'Hall Bazar Transit Hub',
      description: 'Travellers reported suspicious activity.',
      isDemo: true,
    ),
    _AlertData(
      latitude: 31.6411,
      longitude: 74.8702,
      timestamp: DateTime.now().subtract(const Duration(minutes: 7)),
      title: 'Hall Bazar Transit Hub',
      description: 'Follow-up SOS from nearby kiosk.',
      isDemo: true,
    ),
    _AlertData(
      latitude: 31.6384,
      longitude: 74.8751,
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      title: 'Hall Bazar Transit Hub',
      description: 'Volunteer flagged unsafe conditions.',
      isDemo: true,
    ),
    _AlertData(
      latitude: 31.6535,
      longitude: 74.8907,
      timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
      title: 'Ranjit Avenue Community Park',
      description: 'SOS from evening walkers.',
      isDemo: true,
    ),
    _AlertData(
      latitude: 31.6517,
      longitude: 74.8934,
      timestamp: DateTime.now().subtract(const Duration(minutes: 21)),
      title: 'Ranjit Avenue Community Park',
      description: 'Second alert confirms escalation.',
      isDemo: true,
    ),
    _AlertData(
      latitude: 31.6542,
      longitude: 74.8886,
      timestamp: DateTime.now().subtract(const Duration(minutes: 24)),
      title: 'Ranjit Avenue Community Park',
      description: 'Neighborhood watch raised additional alert.',
      isDemo: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Automatically send SOS when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sendSOS();
    });
  }

  void _animateToLocation(double lat, double lng, double zoom) {
    _mapController.move(LatLng(lat, lng), zoom);
  }

  void _zoomIn() {
    _mapController.move(
        _mapController.camera.center, _mapController.camera.zoom + 1);
  }

  void _zoomOut() {
    _mapController.move(
        _mapController.camera.center, _mapController.camera.zoom - 1);
  }

  /// SOS function to save location to Firestore
  Future<void> sendSOS() async {
    try {
      // Ask for location permission if not granted
      geolocator.LocationPermission permission = await geolocator.Geolocator
          .checkPermission();
      if (permission == geolocator.LocationPermission.denied ||
          permission == geolocator.LocationPermission.deniedForever) {
        permission = await geolocator.Geolocator.requestPermission();
      }

      // Get current location
      geolocator.Position position = await geolocator.Geolocator
          .getCurrentPosition(
        locationSettings: const geolocator.LocationSettings(
          accuracy: geolocator.LocationAccuracy.high,
        ),
      );

      final double lat = position.latitude;
      final double lng = position.longitude;

      // Save to Firestore
      await FirebaseFirestore.instance.collection('sos_locations').add({
        'latitude': lat,
        'longitude': lng,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // After saving, animate map to new SOS location
      _animateToLocation(lat, lng, 15);

      // Send notification about SOS alert
      await _notificationService.showLocalNotification(
        title: '🚨 SOS Alert Sent',
        body: 'Emergency SOS alert has been sent from your location. Help is on the way!',
        payload: 'sos_alert:$lat:$lng',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Live SOS alert sent successfully!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sending SOS: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send SOS: $e')),
        );
      }
    }
  }

  List<_AlertData> _collectAlerts(QuerySnapshot<Object?>? snapshot) {
    final List<_AlertData> alerts = [..._demoAlerts];

    if (snapshot != null) {
      for (final doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data() is Map<String, dynamic>
            ? doc.data()! as Map<String, dynamic>
            : <String, dynamic>{};
        final double? lat = (data['latitude'] as num?)?.toDouble();
        final double? lng = (data['longitude'] as num?)?.toDouble();
        if (lat == null || lng == null) continue;

        final DateTime timestamp = (data['timestamp'] as Timestamp?)
            ?.toDate() ?? DateTime.now();
        alerts.add(
          _AlertData(
            latitude: lat,
            longitude: lng,
            timestamp: timestamp,
            title: 'Live SOS Alert',
            description: 'Reported by a nearby user device.',
            isDemo: false,
          ),
        );
      }
    }

    alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return alerts;
  }

  List<_Hotspot> _identifyHotspots(List<_AlertData> alerts) {
    final List<_Hotspot> clusters = [];

    for (final alert in alerts) {
      _Hotspot? matchingCluster;
      for (final cluster in clusters) {
        final double distanceToCluster = _calculateDistance(
          cluster.latitude,
          cluster.longitude,
          alert.latitude,
          alert.longitude,
        );
        if (distanceToCluster <= _clusterMergeDistanceMeters) {
          matchingCluster = cluster;
          break;
        }
      }

      if (matchingCluster != null) {
        matchingCluster.add(alert);
      } else {
        clusters.add(_Hotspot(alert));
      }
    }

    return clusters.where((cluster) => cluster.alerts.length >= 3).toList();
  }

  double _calculateDistance(double lat1, double lon1, double lat2,
      double lon2) {
    const double earthRadiusKm = 6371.0;
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.asin(math.sqrt(a));
    return earthRadiusKm * c * 1000; // Convert to meters
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  String _formatTimestamp(DateTime timestamp) {
    final String day = timestamp.day.toString().padLeft(2, '0');
    final String month = timestamp.month.toString().padLeft(2, '0');
    final String year = timestamp.year.toString();
    final String hour = timestamp.hour.toString().padLeft(2, '0');
    final String minute = timestamp.minute.toString().padLeft(2, '0');
    return '$day/$month/$year • $hour:$minute';
  }

  String _formatCoordinate(double lat, double lng) {
    return '${lat.toStringAsFixed(3)}°, ${lng.toStringAsFixed(3)}°';
  }

  String _formatRadius(double meters) {
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final bool isNarrow = MediaQuery.of(context).size.width < 600;

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
            Icon(FontAwesomeIcons.triangleExclamation, color: Colors.red),
            SizedBox(width: 10),
            Text('SOS Emergency'),
          ],
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.sos, color: Colors.white),
            onPressed: sendSOS,
            tooltip: 'Send Live SOS Alert',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sos_locations')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final List<_AlertData> alerts = _collectAlerts(snapshot.data);
          final List<_Hotspot> hotspots = _identifyHotspots(alerts);

          if (isNarrow) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: const LatLng(_centerLat, _centerLng),
                          initialZoom: 13.0,
                          minZoom: 3.0,
                          maxZoom: 18.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.sahaaya',
                          ),
                          // Hotspot circles
                          ...hotspots.map((hotspot) =>
                              CircleLayer(
                                circles: [
                                  // Caution circle (yellow)
                                  CircleMarker(
                                    point: LatLng(
                                        hotspot.latitude, hotspot.longitude),
                                    radius: _cautionRadiusMeters,
                                    color: Colors.yellow.withValues(alpha: 0.2),
                                    borderColor: Colors.orangeAccent
                                        .withValues(alpha: 0.6),
                                    borderStrokeWidth: 2.0,
                                    useRadiusInMeter: true,
                                  ),
                                  // Core circle (red)
                                  CircleMarker(
                                    point: LatLng(
                                        hotspot.latitude, hotspot.longitude),
                                    radius: _coreRadiusMeters,
                                    color: Colors.red.withValues(alpha: 0.35),
                                    borderColor: Colors.red,
                                    borderStrokeWidth: 2.4,
                                    useRadiusInMeter: true,
                                  ),
                                ],
                              )),
                          // Alert markers
                          MarkerLayer(
                            markers: alerts.map((alert) =>
                                Marker(
                                  point: LatLng(
                                      alert.latitude, alert.longitude),
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    Icons.location_on,
                                    color: alert.isDemo
                                        ? Colors.orangeAccent
                                        : Colors.red,
                                    size: 40,
                                  ),
                                )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    children: [
                      _RoundIconButton(icon: Icons.add, onPressed: _zoomIn),
                      const SizedBox(height: 8),
                      _RoundIconButton(icon: Icons.remove, onPressed: _zoomOut),
                      const SizedBox(height: 8),
                      _RoundIconButton(
                        icon: Icons.my_location,
                        onPressed: () =>
                            _animateToLocation(_centerLat, _centerLng, 13),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: ElevatedButton.icon(
                    icon: const Icon(FontAwesomeIcons.list),
                    label: Text('SOS Alerts (${alerts.length})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        showDragHandle: true,
                        isScrollControlled: true,
                        builder: (ctx) => DraggableScrollableSheet(
                          expand: false,
                          initialChildSize: 0.55,
                          minChildSize: 0.35,
                          maxChildSize: 0.9,
                          builder: (context, scrollController) {
                            return _buildAlertsList(
                                alerts, hotspots, scrollController);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          // Desktop/Wide layout
          return Row(
            children: [
              Expanded(
                flex: 3,
                child: Card(
                  margin: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: const LatLng(_centerLat, _centerLng),
                            initialZoom: 13.0,
                            minZoom: 3.0,
                            maxZoom: 18.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.sahaaya',
                            ),
                            // Hotspot circles
                            ...hotspots.map((hotspot) =>
                                CircleLayer(
                                  circles: [
                                    CircleMarker(
                                      point: LatLng(
                                          hotspot.latitude, hotspot.longitude),
                                      radius: _cautionRadiusMeters,
                                      color: Colors.yellow.withValues(alpha: 0.2),
                                      borderColor: Colors.orangeAccent
                                          .withValues(alpha: 0.6),
                                      borderStrokeWidth: 2.0,
                                      useRadiusInMeter: true,
                                    ),
                                    CircleMarker(
                                      point: LatLng(
                                          hotspot.latitude, hotspot.longitude),
                                      radius: _coreRadiusMeters,
                                      color: Colors.red.withValues(alpha: 0.35),
                                      borderColor: Colors.red,
                                      borderStrokeWidth: 2.4,
                                      useRadiusInMeter: true,
                                    ),
                                  ],
                                )),
                            MarkerLayer(
                              markers: alerts.map((alert) =>
                                  Marker(
                                    point: LatLng(
                                        alert.latitude, alert.longitude),
                                    width: 40,
                                    height: 40,
                                    child: Icon(
                                      Icons.location_on,
                                      color: alert.isDemo
                                          ? Colors.orangeAccent
                                          : Colors.red,
                                      size: 40,
                                    ),
                                  )).toList(),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: Column(
                            children: [
                              _RoundIconButton(
                                  icon: Icons.add, onPressed: _zoomIn),
                              const SizedBox(height: 8),
                              _RoundIconButton(
                                  icon: Icons.remove, onPressed: _zoomOut),
                              const SizedBox(height: 8),
                              _RoundIconButton(
                                icon: Icons.my_location,
                                onPressed: () =>
                                    _animateToLocation(
                                        _centerLat, _centerLng, 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: _buildAlertsList(alerts, hotspots, null),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAlertsList(List<_AlertData> alerts, List<_Hotspot> hotspots,
      ScrollController? scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(8),
      children: [
        const ListTile(
          leading: Icon(
              FontAwesomeIcons.triangleExclamation, color: Colors.red),
          title: Text('SOS Alerts Overview'),
          subtitle: Text('Live reports with demo data for showcase.'),
        ),
        const Divider(height: 1),
        if (hotspots.isNotEmpty) ...[
          ListTile(
            leading: const Icon(Icons.shield, color: Colors.redAccent),
            title: const Text('High-Risk Zones'),
            subtitle: Text('Core ${_formatRadius(
                _coreRadiusMeters)} • Caution ${_formatRadius(
                _cautionRadiusMeters)}'),
          ),
          ...hotspots.map((hotspot) =>
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  child: Text(hotspot.alerts.length.toString()),
                ),
                title: Text('Cluster of ${hotspot.alerts.length} alerts'),
                subtitle: Text('Tap to focus • Center ${_formatCoordinate(
                    hotspot.latitude, hotspot.longitude)}'),
                onTap: () {
                  if (scrollController != null) Navigator.pop(context);
                  _animateToLocation(hotspot.latitude, hotspot.longitude, 14);
                },
              )),
          const Divider(height: 1),
        ] else
          const ListTile(
            title: Text('No high-risk zones detected yet'),
            subtitle: Text(
                'Zones appear automatically after three nearby alerts.'),
          ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('All Alerts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        if (alerts.isEmpty)
          const ListTile(
            title: Text('No SOS alerts yet'),
            subtitle: Text('Press the SOS button to send a live alert.'),
          )
        else
          ...alerts.map((alert) =>
              ListTile(
                leading: Icon(
                  FontAwesomeIcons.triangleExclamation,
                  color: alert.isDemo ? Colors.orangeAccent : Colors.red,
                ),
                title: Text(alert.title),
                subtitle: Text(
                    '${_formatTimestamp(alert.timestamp)} • ${alert.isDemo
                        ? 'Demo data'
                        : 'Live data'}'),
                trailing: Text(
                    _formatCoordinate(alert.latitude, alert.longitude)),
                onTap: () {
                  if (scrollController != null) Navigator.pop(context);
                  _animateToLocation(alert.latitude, alert.longitude, 15);
                },
              )),
      ],
    );
  }
}

class _AlertData {
  const _AlertData({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.title,
    required this.description,
    required this.isDemo,
  });

  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String title;
  final String description;
  final bool isDemo;
}

class _Hotspot {
  _Hotspot(_AlertData firstAlert)
      : alerts = [firstAlert],
        latitude = firstAlert.latitude,
        longitude = firstAlert.longitude;

  double latitude;
  double longitude;
  final List<_AlertData> alerts;

  void add(_AlertData alert) {
    alerts.add(alert);
    _recalculateCenter();
  }

  void _recalculateCenter() {
    double latSum = 0;
    double lngSum = 0;
    for (final alert in alerts) {
      latSum += alert.latitude;
      lngSum += alert.longitude;
    }
    latitude = latSum / alerts.length;
    longitude = lngSum / alerts.length;
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        color: Colors.white,
        elevation: 2,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 22, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}
