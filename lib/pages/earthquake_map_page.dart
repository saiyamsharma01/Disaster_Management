import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sahaaya/services/earthquake_service.dart';
import 'package:sahaaya/services/notification_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

class EarthquakeMapPage extends StatefulWidget {
  const EarthquakeMapPage({super.key});

  @override
  State<EarthquakeMapPage> createState() => _EarthquakeMapPageState();
}

class _EarthquakeMapPageState extends State<EarthquakeMapPage> {
  final EarthquakeService _earthquakeService = EarthquakeService();
  final NotificationService _notificationService = NotificationService();
  final MapController _mapController = MapController();

  List<EarthquakeData> _earthquakes = [];
  bool _isLoading = false;
  String _selectedTimeRange = 'day';
  Position? _userLocation;
  EarthquakeData? _selectedEarthquake;

  // Default center (global view)
  double _centerLat = 20.0;
  double _centerLng = 0.0;
  double _initialZoom = 2.0;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _loadEarthquakeData();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _userLocation = position;
        _centerLat = position.latitude;
        _centerLng = position.longitude;
        _initialZoom = 6.0;
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _loadEarthquakeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final earthquakes = await _earthquakeService.getEarthquakeData(
        timeRange: _selectedTimeRange,
      );

      setState(() {
        _earthquakes = earthquakes;
        _isLoading = false;
      });

      // Send notifications for high magnitude earthquakes near user
      if (_userLocation != null) {
        _checkForNearbyHighMagnitudeEarthquakes(earthquakes);
      }
    } catch (e) {
      debugPrint('Error loading earthquake data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _checkForNearbyHighMagnitudeEarthquakes(
      List<EarthquakeData> earthquakes) {
    if (_userLocation == null) return;

    for (var earthquake in earthquakes) {
      // Check if magnitude > 4.0
      if (earthquake.magnitude > 4.0) {
        // Calculate distance from user
        final distance = Geolocator.distanceBetween(
          _userLocation!.latitude,
          _userLocation!.longitude,
          earthquake.latitude,
          earthquake.longitude,
        ) / 1000; // Convert to km

        // If within 500km, send notification
        if (distance <= 500) {
          _sendEarthquakeAlert(earthquake, distance);
        }
      }
    }
  }

  Future<void> _sendEarthquakeAlert(EarthquakeData earthquake,
      double distanceKm) async {
    await _notificationService.showLocalNotification(
      title: '⚠️ Earthquake Alert - M${earthquake.magnitude.toStringAsFixed(
          1)}',
      body: '${earthquake.location}\n${distanceKm.toStringAsFixed(
          0)}km from your location\n${earthquake.timeAgo}',
    );
  }

  Color _getMagnitudeColor(double magnitude) {
    if (magnitude >= 7.0) return Colors.purple.shade900;
    if (magnitude >= 6.0) return Colors.red.shade900;
    if (magnitude >= 5.0) return Colors.red;
    if (magnitude >= 4.0) return Colors.orange;
    if (magnitude >= 3.0) return Colors.yellow.shade700;
    return Colors.green;
  }

  double _getMagnitudeMarkerSize(double magnitude) {
    if (magnitude >= 7.0) return 50.0;
    if (magnitude >= 6.0) return 40.0;
    if (magnitude >= 5.0) return 35.0;
    if (magnitude >= 4.0) return 30.0;
    if (magnitude >= 3.0) return 25.0;
    return 20.0;
  }

  void _zoomIn() {
    _mapController.move(
        _mapController.camera.center, _mapController.camera.zoom + 1);
  }

  void _zoomOut() {
    _mapController.move(
        _mapController.camera.center, _mapController.camera.zoom - 1);
  }

  void _centerOnUser() {
    if (_userLocation != null) {
      _mapController.move(
        LatLng(_userLocation!.latitude, _userLocation!.longitude),
        8.0,
      );
    }
  }

  Widget _buildMapWidget() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(_centerLat, _centerLng),
        initialZoom: _initialZoom,
        onTap: (tapPosition, point) {
          setState(() {
            _selectedEarthquake = null;
          });
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        // User location marker
        if (_userLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(
                    _userLocation!.latitude, _userLocation!.longitude),
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
            ],
          ),
        // Earthquake markers
        MarkerLayer(
          markers: _earthquakes.map((earthquake) {
            final color = _getMagnitudeColor(earthquake.magnitude);
            final size = _getMagnitudeMarkerSize(earthquake.magnitude);

            return Marker(
              point: LatLng(earthquake.latitude, earthquake.longitude),
              width: size,
              height: size,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedEarthquake = earthquake;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      earthquake.magnitude.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              GoRouter.of(context).go('/dashboard');
            }
          },
          tooltip: 'Back',
        ),
        title: const Text('Earthquake Map'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
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
      body: Stack(
        children: [
          // Map
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading earthquake data...'),
                ],
              ),
            )
          else
            _buildMapWidget(),

          // Legend
          Positioned(
            top: 16,
            left: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Magnitude',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem('7.0+', Colors.purple.shade900),
                    _buildLegendItem('6.0-6.9', Colors.red.shade900),
                    _buildLegendItem('5.0-5.9', Colors.red),
                    _buildLegendItem('4.0-4.9', Colors.orange),
                    _buildLegendItem('3.0-3.9', Colors.yellow.shade700),
                    _buildLegendItem('< 3.0', Colors.green),
                    const Divider(height: 16),
                    Text(
                      'Total: ${_earthquakes.length}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Map controls
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              children: [
                _RoundIconButton(icon: Icons.add, onPressed: _zoomIn),
                const SizedBox(height: 8),
                _RoundIconButton(icon: Icons.remove, onPressed: _zoomOut),
                const SizedBox(height: 8),
                if (_userLocation != null)
                  _RoundIconButton(
                    icon: Icons.my_location,
                    onPressed: _centerOnUser,
                  ),
              ],
            ),
          ),

          // Selected earthquake info
          if (_selectedEarthquake != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 80,
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getMagnitudeColor(
                                  _selectedEarthquake!.magnitude),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'M ${_selectedEarthquake!.magnitude
                                  .toStringAsFixed(1)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedEarthquake!.severityLevel,
                              style: TextStyle(
                                color: _getMagnitudeColor(
                                    _selectedEarthquake!.magnitude),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _selectedEarthquake = null;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedEarthquake!.location,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Time: ${_selectedEarthquake!.timeAgo}'),
                      Text('Depth: ${_selectedEarthquake!.depth.toStringAsFixed(
                          1)} km'),
                      if (_userLocation != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Distance: ${(Geolocator.distanceBetween(
                            _userLocation!.latitude,
                            _userLocation!.longitude,
                            _selectedEarthquake!.latitude,
                            _selectedEarthquake!.longitude,
                          ) / 1000).toStringAsFixed(0)} km from you',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.notifications_active),
                        label: const Text('Send Alert'),
                        onPressed: () {
                          final distance = _userLocation != null
                              ? Geolocator.distanceBetween(
                            _userLocation!.latitude,
                            _userLocation!.longitude,
                            _selectedEarthquake!.latitude,
                            _selectedEarthquake!.longitude,
                          ) / 1000
                              : 0.0;
                          _sendEarthquakeAlert(_selectedEarthquake!, distance);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
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

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _RoundIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        color: Colors.white,
        elevation: 4,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, size: 24, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}
