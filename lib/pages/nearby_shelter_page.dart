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
    _fetchUserLocation();
  }

  Future<void> _fetchUserLocation() async {
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
            accuracy: geolocator.LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
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
        if (mounted) {
          setState(() => _isLoadingLocation = false);
        }
      }
    } catch (e) {
      debugPrint('Location error: $e');
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
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
    return _allShelters.where((s) {
      final matchesSearch = _searchQuery.isEmpty ||
          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.address.toLowerCase().contains(_searchQuery.toLowerCase());

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
    for (final shelter in _filteredShelters) {
      final isSelected = _selectedShelter?.id == shelter.id;
      final percent = shelter.occupancy / shelter.capacity;
      final Color markerColor = percent > 0.85
          ? Colors.red
          : percent > 0.6
              ? Colors.amber.shade800
              : Colors.green;

      markers.add(
        Marker(
          point: LatLng(shelter.latitude, shelter.longitude),
          width: isSelected ? 54 : 44,
          height: isSelected ? 54 : 44,
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
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected ? markerColor : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: markerColor,
                  width: isSelected ? 3.5 : 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: markerColor.withValues(alpha: isSelected ? 0.6 : 0.3),
                    blurRadius: isSelected ? 12 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  FontAwesomeIcons.houseUser,
                  color: isSelected ? Colors.white : markerColor,
                  size: isSelected ? 24 : 18,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return FlutterMap(
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
          userAgentPackageName: 'com.example.cgc',
          maxZoom: 19,
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isNarrow = MediaQuery.of(context).size.width < 700;

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
        title: Row(
          children: const [
            Icon(FontAwesomeIcons.houseFloodWater, color: Colors.green),
            SizedBox(width: 10),
            Text(
              'Nearby Shelters',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: _isLoadingLocation
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            tooltip: 'Get Current Location',
            onPressed: _fetchUserLocation,
          ),
        ],
      ),
      body: isNarrow ? _buildMobileLayout() : _buildTabletLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        // Full Map
        Positioned.fill(child: _buildMapWidget()),

        // Filter Chips Floating on Top
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', Icons.apps),
                const SizedBox(width: 8),
                _buildFilterChip('Available', Icons.check_circle_outline),
                const SizedBox(width: 8),
                _buildFilterChip('High Capacity', Icons.people_outline),
              ],
            ),
          ),
        ),

        // Zoom & Location Controls on the Right
        Positioned(
          right: 16,
          bottom: _selectedShelter != null ? 220 : 80,
          child: Column(
            children: [
              _RoundIconButton(icon: Icons.add, onPressed: _zoomIn),
              const SizedBox(height: 8),
              _RoundIconButton(icon: Icons.remove, onPressed: _zoomOut),
              const SizedBox(height: 8),
              _RoundIconButton(
                icon: Icons.my_location,
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
                backgroundColor: const Color(0xFF4A00E0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 6,
              ),
              icon: const Icon(FontAwesomeIcons.list),
              label: Text(
                'View All (${_filteredShelters.length})',
                style: const TextStyle(fontWeight: FontWeight.bold),
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
    return Row(
      children: [
        // Left: Map
        Expanded(
          flex: 6,
          child: Stack(
            children: [
              _buildMapWidget(),
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
                      onPressed: () {
                        _fetchUserLocation();
                        _animateToLocation(_currentLat, _currentLng, 14.0);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Right: Sidebar with Search, Filter & List
        Expanded(
          flex: 4,
          child: Container(
            color: Colors.grey.shade50,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search shelters or areas...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All', Icons.apps),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Available',
                              Icons.check_circle_outline,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'High Capacity',
                              Icons.people_outline,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredShelters.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final shelter = _filteredShelters[index];
                      final isSelected = _selectedShelter?.id == shelter.id;
                      return _buildShelterTile(shelter, isSelected);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.black87,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF4A00E0),
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = label);
        }
      },
    );
  }

  Widget _buildSelectedShelterCard(_Shelter shelter) {
    final distance = _getDistanceInKm(shelter.latitude, shelter.longitude);
    final percent = shelter.occupancy / shelter.capacity;
    final Color statusColor = percent > 0.85
        ? Colors.red
        : percent > 0.6
            ? Colors.amber.shade800
            : Colors.green;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(FontAwesomeIcons.house, color: statusColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shelter.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        shelter.address,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => setState(() => _selectedShelter = null),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Occupancy: ${shelter.occupancy} / ${shelter.capacity}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(percent * 100).toInt()}% Full',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percent.clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade200,
                color: statusColor,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 4),
                Text(
                  '${distance.toStringAsFixed(1)} km away',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade700,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A00E0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text('Directions'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Routing to ${shelter.name}...'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    _animateToLocation(
                      shelter.latitude,
                      shelter.longitude,
                      16.0,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShelterTile(_Shelter shelter, bool isSelected) {
    final distance = _getDistanceInKm(shelter.latitude, shelter.longitude);
    final percent = shelter.occupancy / shelter.capacity;
    final Color statusColor = percent > 0.85
        ? Colors.red
        : percent > 0.6
            ? Colors.amber.shade800
            : Colors.green;

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? const BorderSide(color: Color(0xFF4A00E0), width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() => _selectedShelter = shelter);
          _animateToLocation(shelter.latitude, shelter.longitude, 15.0);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      shelter.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      percent > 0.85
                          ? 'Almost Full'
                          : percent > 0.6
                              ? 'Moderate'
                              : 'Available',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                shelter.address,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Capacity: ${shelter.occupancy}/${shelter.capacity}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    '${distance.toStringAsFixed(1)} km away',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade200,
                  color: statusColor,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showShelterListModal() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.65,
              minChildSize: 0.4,
              maxChildSize: 0.92,
              builder: (context, scrollController) {
                return SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          onChanged: (val) {
                            setState(() => _searchQuery = val);
                            setModalState(() {});
                          },
                          decoration: InputDecoration(
                            hintText: 'Search shelter by name or address...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredShelters.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final shelter = _filteredShelters[index];
                            final isSelected =
                                _selectedShelter?.id == shelter.id;
                            return _buildShelterTile(shelter, isSelected);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
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
    this.hasMedical = true,
    this.hasFood = true,
  });
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
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, size: 22, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}
