import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sahaaya/services/earthquake_service.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:go_router/go_router.dart';

class EarthquakeMapPage extends StatefulWidget {
  const EarthquakeMapPage({super.key});

  @override
  State<EarthquakeMapPage> createState() => _EarthquakeMapPageState();
}

class _EarthquakeMapPageState extends State<EarthquakeMapPage> {
  final EarthquakeService _earthquakeService = EarthquakeService();
  final MapController _mapController = MapController();

  List<EarthquakeData> _earthquakes = [];
  bool _isLoading = false;
  String _selectedTimeRange = 'day';
  geolocator.Position? _userLocation;
  EarthquakeData? _selectedEarthquake;

  // Default center (global view)
  double _centerLat = 28.6139;
  double _centerLng = 77.2090;
  final double _initialZoom = 4.0;

  @override
  void initState() {
    super.initState();
    _getUserFastLocation();
    _loadEarthquakeData();
  }

  Future<void> _getUserFastLocation() async {
    try {
      final lastPos = await geolocator.Geolocator.getLastKnownPosition();
      if (lastPos != null && mounted) {
        setState(() {
          _userLocation = lastPos;
          _centerLat = lastPos.latitude;
          _centerLng = lastPos.longitude;
        });
      }

      final permission = await geolocator.Geolocator.checkPermission();
      if (permission == geolocator.LocationPermission.always ||
          permission == geolocator.LocationPermission.whileInUse) {
        final pos = await geolocator.Geolocator.getCurrentPosition(
          locationSettings: const geolocator.LocationSettings(
            accuracy: geolocator.LocationAccuracy.medium,
            timeLimit: Duration(seconds: 4),
          ),
        );
        if (mounted) {
          setState(() {
            _userLocation = pos;
            _centerLat = pos.latitude;
            _centerLng = pos.longitude;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _loadEarthquakeData({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);

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
      debugPrint('Error loading earthquake data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getMagnitudeColor(double magnitude) {
    if (magnitude >= 7.0) return const Color(0xFF581C87); // Purple 900
    if (magnitude >= 6.0) return const Color(0xFF7F1D1D); // Red 900
    if (magnitude >= 5.0) return const Color(0xFFDC2626); // Red 600
    if (magnitude >= 4.0) return const Color(0xFFEA580C); // Orange 600
    if (magnitude >= 3.0) return const Color(0xFFD97706); // Amber 600
    return const Color(0xFF059669); // Emerald 600
  }

  double _getMagnitudeMarkerSize(double magnitude) {
    if (magnitude >= 7.0) return 44.0;
    if (magnitude >= 6.0) return 38.0;
    if (magnitude >= 5.0) return 32.0;
    if (magnitude >= 4.0) return 26.0;
    return 22.0;
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

  void _centerOnUser() {
    if (_userLocation != null) {
      try {
        _mapController.move(
          LatLng(_userLocation!.latitude, _userLocation!.longitude),
          7.0,
        );
      } catch (_) {}
    }
  }

  Widget _buildMapWidget() {
    final markers = <Marker>[];

    // User location marker
    if (_userLocation != null) {
      markers.add(
        Marker(
          point: LatLng(_userLocation!.latitude, _userLocation!.longitude),
          width: 40,
          height: 40,
          child: const Icon(
            Icons.my_location_rounded,
            color: Color(0xFF2563EB),
            size: 28,
          ),
        ),
      );
    }

    // Earthquake markers
    for (final earthquake in _earthquakes) {
      final color = _getMagnitudeColor(earthquake.magnitude);
      final size = _getMagnitudeMarkerSize(earthquake.magnitude);
      final isSelected = _selectedEarthquake?.id == earthquake.id;

      markers.add(
        Marker(
          point: LatLng(earthquake.latitude, earthquake.longitude),
          width: isSelected ? size + 10 : size,
          height: isSelected ? size + 10 : size,
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedEarthquake = earthquake);
            },
            child: Container(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.85),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: isSelected ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: isSelected ? 12 : 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  earthquake.magnitude.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 9.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(_centerLat, _centerLng),
          initialZoom: _initialZoom,
          minZoom: 2.0,
          maxZoom: 18.0,
          onTap: (tapPosition, point) {
            if (_selectedEarthquake != null) {
              setState(() => _selectedEarthquake = null);
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.sahaaya',
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
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
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              GoRouter.of(context).go('/dashboard');
            }
          },
          tooltip: 'Back',
        ),
        title: const Text(
          'Seismic Map Radar',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
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
      body: Stack(
        children: [
          // Map Canvas
          Positioned.fill(
            child: _isLoading && _earthquakes.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFEA580C)))
                : _buildMapWidget(),
          ),

          // Mini Magnitude Legend (Top-Left)
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Magnitude · ${_earthquakes.length} Events',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildLegendDot('M5+', const Color(0xFFDC2626)),
                      const SizedBox(width: 8),
                      _buildLegendDot('M4+', const Color(0xFFEA580C)),
                      const SizedBox(width: 8),
                      _buildLegendDot('M3+', const Color(0xFFD97706)),
                      const SizedBox(width: 8),
                      _buildLegendDot('<3', const Color(0xFF059669)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Map Zoom & Location controls
          Positioned(
            right: 16,
            bottom: _selectedEarthquake != null ? 220 : 24,
            child: Column(
              children: [
                _RoundIconButton(icon: Icons.add, onPressed: _zoomIn),
                const SizedBox(height: 8),
                _RoundIconButton(icon: Icons.remove, onPressed: _zoomOut),
                const SizedBox(height: 8),
                if (_userLocation != null)
                  _RoundIconButton(
                    icon: Icons.my_location_rounded,
                    onPressed: _centerOnUser,
                  ),
              ],
            ),
          ),

          // Selected Earthquake Card
          if (_selectedEarthquake != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getMagnitudeColor(_selectedEarthquake!.magnitude),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'M ${_selectedEarthquake!.magnitude.toStringAsFixed(1)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedEarthquake!.location,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${_selectedEarthquake!.timeAgo} · Depth: ${_selectedEarthquake!.depth.toStringAsFixed(1)} km',
                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => setState(() => _selectedEarthquake = null),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
      ],
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Filter Seismic Radar', style: TextStyle(fontWeight: FontWeight.bold)),
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
              title: const Text('Major Events (M4.5+)'),
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

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _RoundIconButton({required this.icon, required this.onPressed});

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
