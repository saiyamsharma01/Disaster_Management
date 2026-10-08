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
  bool _isSending = false;

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
    // Fast initial location probe in background without blocking UI
    _tryGetFastInitialLocation();
  }

  Future<void> _tryGetFastInitialLocation() async {
    try {
      final lastPos = await geolocator.Geolocator.getLastKnownPosition();
      if (lastPos != null && mounted) {
        _animateToLocation(lastPos.latitude, lastPos.longitude, 13.5);
      }
    } catch (_) {}
  }

  void _animateToLocation(double lat, double lng, double zoom) {
    try {
      _mapController.move(LatLng(lat, lng), zoom);
    } catch (_) {}
  }

  void _zoomIn() {
    try {
      _mapController.move(
          _mapController.camera.center, _mapController.camera.zoom + 1);
    } catch (_) {}
  }

  void _zoomOut() {
    try {
      _mapController.move(
          _mapController.camera.center, _mapController.camera.zoom - 1);
    } catch (_) {}
  }

  /// Fast, non-blocking SOS broadcast
  Future<void> sendSOS() async {
    if (_isSending) return;
    setState(() => _isSending = true);

    try {
      geolocator.LocationPermission permission = await geolocator.Geolocator.checkPermission();
      if (permission == geolocator.LocationPermission.denied ||
          permission == geolocator.LocationPermission.deniedForever) {
        permission = await geolocator.Geolocator.requestPermission();
      }

      double lat = _centerLat;
      double lng = _centerLng;

      // Try fast last known position first
      final lastPos = await geolocator.Geolocator.getLastKnownPosition();
      if (lastPos != null) {
        lat = lastPos.latitude;
        lng = lastPos.longitude;
      } else {
        // Fallback to current position with strict 4s timeout
        try {
          final pos = await geolocator.Geolocator.getCurrentPosition(
            locationSettings: const geolocator.LocationSettings(
              accuracy: geolocator.LocationAccuracy.medium,
              timeLimit: Duration(seconds: 4),
            ),
          );
          lat = pos.latitude;
          lng = pos.longitude;
        } catch (_) {}
      }

      // Save to Firestore
      await FirebaseFirestore.instance.collection('sos_locations').add({
        'latitude': lat,
        'longitude': lng,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Animate map to SOS location
      _animateToLocation(lat, lng, 15);

      // Send local notification
      try {
        await _notificationService.showLocalNotification(
          title: '🚨 SOS Alert Dispatched',
          body: 'Emergency SOS alert broadcasted from your location. Responders alerted!',
          payload: 'sos_alert:$lat:$lng',
        );
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Text('Emergency SOS broadcasted successfully!'),
              ],
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sending SOS: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to broadcast SOS: $e'),
            backgroundColor: Colors.black87,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
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

  @override
  Widget build(BuildContext context) {
    final bool isNarrow = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
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
            Icon(Icons.shield_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Emergency SOS Radar',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isSending
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                  )
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFDC2626),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.emergency_rounded, size: 18),
                    label: const Text(
                      'TRIGGER SOS',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                    onPressed: sendSOS,
                  ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sos_locations')
            .orderBy('timestamp', descending: true)
            .limit(40)
            .snapshots(),
        builder: (context, snapshot) {
          final List<_AlertData> alerts = _collectAlerts(snapshot.data);
          final List<_Hotspot> hotspots = _identifyHotspots(alerts);

          if (isNarrow) {
            return Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: FlutterMap(
                      mapController: _mapController,
                      options: const MapOptions(
                        initialCenter: LatLng(_centerLat, _centerLng),
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
                        ...hotspots.map((hotspot) => CircleLayer(
                              circles: [
                                CircleMarker(
                                  point: LatLng(hotspot.latitude, hotspot.longitude),
                                  radius: _cautionRadiusMeters,
                                  color: Colors.yellow.withValues(alpha: 0.2),
                                  borderColor: Colors.orangeAccent.withValues(alpha: 0.6),
                                  borderStrokeWidth: 2.0,
                                  useRadiusInMeter: true,
                                ),
                                CircleMarker(
                                  point: LatLng(hotspot.latitude, hotspot.longitude),
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
                          markers: alerts
                              .map((alert) => Marker(
                                    point: LatLng(alert.latitude, alert.longitude),
                                    width: 36,
                                    height: 36,
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      color: alert.isDemo
                                          ? const Color(0xFFF97316)
                                          : const Color(0xFFDC2626),
                                      size: 36,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 20,
                  child: Column(
                    children: [
                      _RoundIconButton(icon: Icons.add, onPressed: _zoomIn),
                      const SizedBox(height: 8),
                      _RoundIconButton(icon: Icons.remove, onPressed: _zoomOut),
                      const SizedBox(height: 8),
                      _RoundIconButton(
                        icon: Icons.my_location_rounded,
                        onPressed: () => _animateToLocation(_centerLat, _centerLng, 13),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 20,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.format_list_bulleted_rounded, size: 18),
                    label: Text('Alerts (${alerts.length})', style: const TextStyle(fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        showDragHandle: true,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (ctx) => DraggableScrollableSheet(
                          expand: false,
                          initialChildSize: 0.55,
                          minChildSize: 0.35,
                          maxChildSize: 0.9,
                          builder: (context, scrollController) {
                            return _buildAlertsList(alerts, hotspots, scrollController);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          // Desktop / Wide layout
          return Row(
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    RepaintBoundary(
                      child: FlutterMap(
                        mapController: _mapController,
                        options: const MapOptions(
                          initialCenter: LatLng(_centerLat, _centerLng),
                          initialZoom: 13.0,
                          minZoom: 3.0,
                          maxZoom: 18.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.sahaaya',
                          ),
                          ...hotspots.map((hotspot) => CircleLayer(
                                circles: [
                                  CircleMarker(
                                    point: LatLng(hotspot.latitude, hotspot.longitude),
                                    radius: _cautionRadiusMeters,
                                    color: Colors.yellow.withValues(alpha: 0.2),
                                    borderColor: Colors.orangeAccent.withValues(alpha: 0.6),
                                    borderStrokeWidth: 2.0,
                                    useRadiusInMeter: true,
                                  ),
                                  CircleMarker(
                                    point: LatLng(hotspot.latitude, hotspot.longitude),
                                    radius: _coreRadiusMeters,
                                    color: Colors.red.withValues(alpha: 0.35),
                                    borderColor: Colors.red,
                                    borderStrokeWidth: 2.4,
                                    useRadiusInMeter: true,
                                  ),
                                ],
                              )),
                          MarkerLayer(
                            markers: alerts
                                .map((alert) => Marker(
                                      point: LatLng(alert.latitude, alert.longitude),
                                      width: 36,
                                      height: 36,
                                      child: Icon(
                                        Icons.location_on_rounded,
                                        color: alert.isDemo
                                            ? const Color(0xFFF97316)
                                            : const Color(0xFFDC2626),
                                        size: 36,
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 20,
                      child: Column(
                        children: [
                          _RoundIconButton(icon: Icons.add, onPressed: _zoomIn),
                          const SizedBox(height: 8),
                          _RoundIconButton(icon: Icons.remove, onPressed: _zoomOut),
                          const SizedBox(height: 8),
                          _RoundIconButton(
                            icon: Icons.my_location_rounded,
                            onPressed: () => _animateToLocation(_centerLat, _centerLng, 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, color: Colors.grey.shade200),
              Expanded(
                flex: 2,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(FontAwesomeIcons.triangleExclamation, color: Colors.red, size: 18),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SOS Alerts Overview', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                Text('Live reports & danger zones', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(height: 1),
        if (hotspots.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'HIGH-RISK ZONES (${hotspots.length})',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Colors.red),
          ),
          const SizedBox(height: 6),
          ...hotspots.map((hotspot) => Card(
                elevation: 0,
                color: const Color(0xFFFEF2F2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.red.shade200),
                ),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    child: Text(hotspot.alerts.length.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  title: Text('Cluster of ${hotspot.alerts.length} SOS Alerts', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: Text('Tap to focus • Center ${_formatCoordinate(hotspot.latitude, hotspot.longitude)}', style: const TextStyle(fontSize: 12)),
                  onTap: () {
                    if (scrollController != null) Navigator.pop(context);
                    _animateToLocation(hotspot.latitude, hotspot.longitude, 14);
                  },
                ),
              )),
          const SizedBox(height: 12),
          const Divider(height: 1),
        ],
        const SizedBox(height: 12),
        Text(
          'ALL INCIDENT REPORTS (${alerts.length})',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 6),
        if (alerts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('No SOS alerts active at this moment.')),
          )
        else
          ...alerts.map((alert) => Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: alert.isDemo ? Colors.orange.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: alert.isDemo ? Colors.orange : Colors.red,
                      size: 20,
                    ),
                  ),
                  title: Text(alert.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: Text(
                    '${_formatTimestamp(alert.timestamp)} • ${alert.isDemo ? "Simulated" : "Live User GPS"}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  onTap: () {
                    if (scrollController != null) Navigator.pop(context);
                    _animateToLocation(alert.latitude, alert.longitude, 15);
                  },
                ),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onPressed,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, size: 20, color: const Color(0xFF0F172A)),
          ),
        ),
      ),
    );
  }
}
