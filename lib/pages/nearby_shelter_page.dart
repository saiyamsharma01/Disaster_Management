import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:go_router/go_router.dart';

class NearbyShelterPage extends StatefulWidget {
  const NearbyShelterPage({super.key});

  @override
  State<NearbyShelterPage> createState() => _NearbyShelterPageState();
}

class _NearbyShelterPageState extends State<NearbyShelterPage> {
  final MapController _mapController = MapController();

  // Default center (Amritsar / Chandigarh region)
  static const double _defaultLat = 30.7333;
  static const double _defaultLng = 76.7794;

  double _currentLat = _defaultLat;
  double _currentLng = _defaultLng;
  bool _hasUserLocation = false;
  bool _isLoadingLocation = false;

  _Shelter? _selectedShelter;
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Available', 'High Capacity'

  // Master list of shelters
  final List<_Shelter> _allShelters = const [
    _Shelter(
      id: '1',
      name: 'Sector 17 Emergency Relief Center',
      address: 'Near Parade Ground, Sector 17, Chandigarh',
      phone: '+91 172 2740400',
      latitude: 30.7410,
      longitude: 76.7800,
      capacity: 350,
      occupancy: 180,
      hasMedical: true,
      hasFood: true,
    ),
    _Shelter(
      id: '2',
      name: 'Jhanderi Community & Disaster Shelter',
      address: 'Main Road, Jhanderi Area',
      phone: '+91 172 2701234',
      latitude: 30.7445,
      longitude: 76.7695,
      capacity: 200,
      occupancy: 85,
      hasMedical: true,
      hasFood: true,
    ),
    _Shelter(
      id: '3',
      name: 'Jhanderi Primary School Emergency Shelter',
      address: 'Block B, Near Jhanderi Village',
      phone: '+91 172 2705678',
      latitude: 30.7425,
      longitude: 76.7720,
      capacity: 180,
      occupancy: 120,
      hasMedical: false,
      hasFood: true,
    ),
    _Shelter(
      id: '4',
      name: 'Panjab University Relief Auditorium',
      address: 'Sector 14, PU Campus',
      phone: '+91 172 2534818',
      latitude: 30.7570,
      longitude: 76.7690,
      capacity: 500,
      occupancy: 220,
      hasMedical: true,
      hasFood: true,
    ),
    _Shelter(
      id: '5',
      name: 'Sector 22 Sports Complex Shelter',
      address: 'Opposite Market 22-B',
      phone: '+91 172 2712233',
      latitude: 30.7320,
      longitude: 76.7650,
      capacity: 400,
      occupancy: 310,
      hasMedical: true,
      hasFood: true,
    ),
    _Shelter(
      id: '6',
      name: 'PGIMER Emergency Medical Relief Hub',
      address: 'Kairon Block, Sector 12',
      phone: '+91 172 2747585',
      latitude: 30.7640,
      longitude: 76.7750,
      capacity: 300,
      occupancy: 240,
      hasMedical: true,
      hasFood: true,
    ),
    _Shelter(
      id: '7',
      name: 'Rock Garden Disaster Camp',
      address: 'Uttar Marg, Sector 1',
      phone: '+91 172 2740645',
      latitude: 30.7520,
      longitude: 76.8010,
      capacity: 150,
      occupancy: 95,
      hasMedical: false,
      hasFood: true,
    ),
    _Shelter(
      id: '8',
      name: 'Sukhna Lake Community Center',
      address: 'Near Regulator End, Sector 6',
      phone: '+91 172 2740200',
      latitude: 30.7420,
      longitude: 76.8150,
      capacity: 220,
      occupancy: 165,
      hasMedical: true,
      hasFood: true,
    ),
    _Shelter(
      id: '9',
      name: 'Sector 35 Community Shelter',
      address: 'Near Sector 35 Roundabout',
      phone: '+91 172 2603333',
      latitude: 30.7280,
      longitude: 76.7580,
      capacity: 180,
      occupancy: 90,
      hasMedical: false,
      hasFood: true,
    ),
    _Shelter(
      id: '10',
      name: 'Sector 16 Stadium Evacuation Center',
      address: 'Cricket Stadium Complex, Sector 16',
      phone: '+91 172 2741616',
      latitude: 30.7450,
      longitude: 76.7870,
      capacity: 450,
      occupancy: 320,
      hasMedical: true,
      hasFood: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchFastUserLocation();
  }

  Future<void> _fetchFastUserLocation() async {
    // 1. Instantly get last known position (0ms)
    try {
      final lastPos = await geolocator.Geolocator.getLastKnownPosition();
      if (lastPos != null && mounted) {
        setState(() {
          _currentLat = lastPos.latitude;
          _currentLng = lastPos.longitude;
          _hasUserLocation = true;
        });
        _animateToLocation(_currentLat, _currentLng, 14.0);
      }
    } catch (_) {}

    // 2. Refine in background with 4s timeout
    _fetchUserLocation();
  }

  Future<void> _fetchUserLocation() async {
    if (_isLoadingLocation) return;
    setState(() => _isLoadingLocation = true);
    try {
      geolocator.LocationPermission permission =
          await geolocator.Geolocator.checkPermission();
      if (permission == geolocator.LocationPermission.denied) {
        permission = await geolocator.Geolocator.requestPermission();
      }

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
            _currentLat = pos.latitude;
            _currentLng = pos.longitude;
            _hasUserLocation = true;
            _isLoadingLocation = false;
          });
          _animateToLocation(_currentLat, _currentLng, 14.0);
        }
      } else {
        if (mounted) setState(() => _isLoadingLocation = false);
      }
    } catch (e) {
      debugPrint('Location error: $e');
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _animateToLocation(double lat, double lng, double zoom) {
    try {
      _mapController.move(LatLng(lat, lng), zoom);
    } catch (e) {
      debugPrint('MapController move error: $e');
    }
  }

  void _zoomIn() {
    try {
      final currentZoom = _mapController.camera.zoom;
      final currentCenter = _mapController.camera.center;
      _mapController.move(currentCenter, (currentZoom + 1).clamp(3.0, 18.0));
    } catch (_) {}
  }

  void _zoomOut() {
    try {
      final currentZoom = _mapController.camera.zoom;
      final currentCenter = _mapController.camera.center;
      _mapController.move(currentCenter, (currentZoom - 1).clamp(3.0, 18.0));
    } catch (_) {}
  }

  double _getDistanceInKm(double lat, double lng) {
    final meters = geolocator.Geolocator.distanceBetween(
      _currentLat,
      _currentLng,
      lat,
      lng,
    );
    return meters / 1000.0;
  }

  List<_Shelter> get _filteredShelters {
    final search = _searchQuery.trim().toLowerCase();
    return _allShelters.where((s) {
      final matchesSearch = search.isEmpty ||
          s.name.toLowerCase().contains(search) ||
          s.address.toLowerCase().contains(search);

      if (!matchesSearch) return false;

      if (_selectedFilter == 'Available') {
        return (s.occupancy / s.capacity) < 0.8;
      } else if (_selectedFilter == 'High Capacity') {
        return s.capacity >= 300;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final distA = _getDistanceInKm(a.latitude, a.longitude);
        final distB = _getDistanceInKm(b.latitude, b.longitude);
        return distA.compareTo(distB);
      });
  }

  Widget _buildMapWidget() {
    final filtered = _filteredShelters;
    final markers = <Marker>[];

    // User Location Marker
    if (_hasUserLocation) {
      markers.add(
        Marker(
          point: LatLng(_currentLat, _currentLng),
          width: 50,
          height: 50,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withValues(alpha: 0.25),
            ),
            child: Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Shelter Markers
    for (final shelter in filtered) {
      final isSelected = _selectedShelter?.id == shelter.id;
      final percent = shelter.occupancy / shelter.capacity;
      final Color markerColor = percent > 0.85
          ? const Color(0xFFDC2626)
          : percent > 0.6
              ? const Color(0xFFD97706)
              : const Color(0xFF059669);

      markers.add(
        Marker(
          point: LatLng(shelter.latitude, shelter.longitude),
          width: isSelected ? 52 : 42,
          height: isSelected ? 52 : 42,
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedShelter = shelter);
              _animateToLocation(
                shelter.latitude,
                shelter.longitude,
                15.0,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: isSelected ? markerColor : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: markerColor,
                  width: isSelected ? 3.5 : 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: markerColor.withValues(alpha: isSelected ? 0.6 : 0.25),
                    blurRadius: isSelected ? 12 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  FontAwesomeIcons.houseUser,
                  color: isSelected ? Colors.white : markerColor,
                  size: isSelected ? 22 : 16,
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
          initialCenter: LatLng(_currentLat, _currentLng),
          initialZoom: 13.0,
          minZoom: 3.0,
          maxZoom: 18.0,
          onTap: (tapPosition, point) {
            if (_selectedShelter != null) {
              setState(() => _selectedShelter = null);
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.sahaaya',
            maxZoom: 19,
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isNarrow = MediaQuery.of(context).size.width < 700;

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
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(FontAwesomeIcons.tent, color: Color(0xFF059669), size: 16),
            ),
            const SizedBox(width: 10),
            const Text(
              'Relief Shelters',
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
            icon: _isLoadingLocation
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4F46E5)),
                  )
                : const Icon(Icons.my_location_rounded, color: Color(0xFF4F46E5)),
            tooltip: 'Get Current Location',
            onPressed: _fetchUserLocation,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isNarrow ? _buildMobileLayout() : _buildTabletLayout(),
    );
  }

  Widget _buildMobileLayout() {
    final filtered = _filteredShelters;

    return Stack(
      children: [
        // Full Map
        Positioned.fill(child: _buildMapWidget()),

        // Top Filter Bar & Search
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', Icons.apps_rounded),
                    const SizedBox(width: 8),
                    _buildFilterChip('Available', Icons.check_circle_rounded),
                    const SizedBox(width: 8),
                    _buildFilterChip('High Capacity', Icons.people_alt_rounded),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Zoom & Location Controls on the Right
        Positioned(
          right: 16,
          bottom: _selectedShelter != null ? 240 : 80,
          child: Column(
            children: [
              _RoundIconButton(icon: Icons.add, onPressed: _zoomIn),
              const SizedBox(height: 8),
              _RoundIconButton(icon: Icons.remove, onPressed: _zoomOut),
              const SizedBox(height: 8),
              _RoundIconButton(
                icon: Icons.my_location_rounded,
                onPressed: () {
                  _fetchUserLocation();
                  _animateToLocation(_currentLat, _currentLng, 14.0);
                },
              ),
            ],
          ),
        ),

        // Floating Directory List Button
        if (_selectedShelter == null)
          Positioned(
            left: 16,
            bottom: 20,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
              icon: const Icon(Icons.format_list_bulleted_rounded, size: 18),
              label: Text(
                'List View (${filtered.length})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: _showShelterListModal,
            ),
          ),

        // Selected Shelter Detail Card
        if (_selectedShelter != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: _buildSelectedShelterCard(_selectedShelter!),
          ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    final filtered = _filteredShelters;

    return Row(
      children: [
        // Left Column: Search, Filters & Shelter List
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search shelters by name or area...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildFilterChip('All', Icons.apps_rounded),
                          const SizedBox(width: 8),
                          _buildFilterChip('Available', Icons.check_circle_rounded),
                          const SizedBox(width: 8),
                          _buildFilterChip('High Capacity', Icons.people_alt_rounded),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => _buildShelterListTile(filtered[i]),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(width: 1, color: const Color(0xFFE2E8F0)),
        // Right Column: Map
        Expanded(
          flex: 3,
          child: _buildMapWidget(),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = _selectedFilter == label;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedShelterCard(_Shelter shelter) {
    final dist = _getDistanceInKm(shelter.latitude, shelter.longitude);
    final percent = shelter.occupancy / shelter.capacity;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  shelter.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => setState(() => _selectedShelter = null),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            shelter.address,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.navigation_rounded, size: 12, color: Color(0xFF4F46E5)),
                    const SizedBox(width: 4),
                    Text(
                      '${dist.toStringAsFixed(1)} km away',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: percent > 0.85 ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${shelter.capacity - shelter.occupancy} Beds Available',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: percent > 0.85 ? const Color(0xFFDC2626) : const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showShelterListModal() {
    final filtered = _filteredShelters;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Relief Shelters (${filtered.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final s = filtered[i];
                      return _buildShelterListTile(s, inModal: true);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildShelterListTile(_Shelter s, {bool inModal = false}) {
    final dist = _getDistanceInKm(s.latitude, s.longitude);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        onTap: () {
          if (inModal) Navigator.pop(context);
          setState(() => _selectedShelter = s);
          _animateToLocation(s.latitude, s.longitude, 15.0);
        },
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(FontAwesomeIcons.house, color: Color(0xFF059669), size: 16),
        ),
        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text('${dist.toStringAsFixed(1)} km • ${s.capacity - s.occupancy} beds left', style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      ),
    );
  }
}

class _Shelter {
  final String id;
  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final int capacity;
  final int occupancy;
  final bool hasMedical;
  final bool hasFood;

  const _Shelter({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.capacity,
    required this.occupancy,
    required this.hasMedical,
    required this.hasFood,
  });
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
            color: Colors.black.withValues(alpha: 0.08),
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
