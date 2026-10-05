import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class NearbyShelterPage extends StatefulWidget {
  const NearbyShelterPage({super.key});

  @override
  State<NearbyShelterPage> createState() => _NearbyShelterPageState();
}

class _NearbyShelterPageState extends State<NearbyShelterPage> {
  final MapController _mapController = MapController();

  // Dummy shelters near Chandigarh center (including Jhanderi area)
  final List<_Shelter> _shelters = const [
    _Shelter(
      name: 'Jhanderi Community Center',
      latitude: 30.7445,
      longitude: 76.7695,
      capacity: 200,
      occupancy: 85,
    ),
    _Shelter(
      name: 'Jhanderi Primary School Shelter',
      latitude: 30.7425,
      longitude: 76.7720,
      capacity: 180,
      occupancy: 120,
    ),
    _Shelter(
      name: 'Sector 17 Emergency Shelter',
      latitude: 30.7410,
      longitude: 76.7800,
      capacity: 350,
      occupancy: 280,
    ),
    _Shelter(
      name: 'Rock Garden Relief Center',
      latitude: 30.7520,
      longitude: 76.8010,
      capacity: 150,
      occupancy: 95,
    ),
    _Shelter(
      name: 'Sukhna Lake Community Hall',
      latitude: 30.7420,
      longitude: 76.8150,
      capacity: 220,
      occupancy: 165,
    ),
    _Shelter(
      name: 'Sector 22 Sports Complex Shelter',
      latitude: 30.7320,
      longitude: 76.7650,
      capacity: 400,
      occupancy: 310,
    ),
    _Shelter(
      name: 'Panjab University Auditorium',
      latitude: 30.7570,
      longitude: 76.7690,
      capacity: 500,
      occupancy: 420,
    ),
    _Shelter(
      name: 'Sector 35 Community Center',
      latitude: 30.7280,
      longitude: 76.7580,
      capacity: 180,
      occupancy: 90,
    ),
    _Shelter(
      name: 'Elante Mall Emergency Zone',
      latitude: 30.7040,
      longitude: 76.8020,
      capacity: 600,
      occupancy: 450,
    ),
    _Shelter(
      name: 'PGIMER Medical Relief Center',
      latitude: 30.7640,
      longitude: 76.7750,
      capacity: 300,
      occupancy: 240,
    ),
    _Shelter(
      name: 'Sector 16 Stadium Shelter',
      latitude: 30.7450,
      longitude: 76.7870,
      capacity: 450,
      occupancy: 320,
    ),
    _Shelter(
      name: 'Industrial Area Phase 1 Hall',
      latitude: 30.7210,
      longitude: 76.8080,
      capacity: 250,
      occupancy: 180,
    ),
    _Shelter(
      name: 'Manimajra Community Shelter',
      latitude: 30.7120,
      longitude: 76.8510,
      capacity: 200,
      occupancy: 140,
    ),
    _Shelter(
      name: 'Sector 43 School Shelter',
      latitude: 30.7150,
      longitude: 76.7420,
      capacity: 170,
      occupancy: 110,
    ),
    _Shelter(
      name: 'Chandigarh Railway Station Hall',
      latitude: 30.7048,
      longitude: 76.7950,
      capacity: 350,
      occupancy: 290,
    ),
  ];

  static const double _centerLat = 30.7333;
  static const double _centerLng = 76.7794;

  void _animateToLocation(double lat, double lng, double zoom) {
    _mapController.move(LatLng(lat, lng), zoom);
  }

  void _zoomIn() {
    _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
  }

  void _zoomOut() {
    _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
  }

  Widget _buildMapWidget() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(_centerLat, _centerLng),
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: _shelters
              .map((s) =>
              Marker(
                point: LatLng(s.latitude, s.longitude),
                width: 40,
                height: 40,
                child: const Icon(
                  FontAwesomeIcons.house,
                  color: Colors.green,
                  size: 26,
                ),
              ))
              .toList(),
        ),
      ],
    );
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
        title: Row(
          children: const [
            Icon(FontAwesomeIcons.houseFloodWater, color: Colors.green),
            SizedBox(width: 10),
            Text('Nearby Shelters'),
          ],
        ),
      ),
      body: isNarrow
          ? Stack(
              children: [
                // Map full-screen on narrow layouts
                Positioned.fill(
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildMapWidget(),
                    ),
                  ),
                ),
                // Zoom & action controls
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
                // Open shelter list button
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: ElevatedButton.icon(
                    icon: const Icon(FontAwesomeIcons.house),
                    label: const Text('Shelters Nearby'),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        showDragHandle: true,
                        isScrollControlled: true,
                        builder: (context) {
                          return DraggableScrollableSheet(
                            expand: false,
                            initialChildSize: 0.55,
                            minChildSize: 0.35,
                            maxChildSize: 0.9,
                            builder: (context, scrollController) {
                              return SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: _ShelterList(
                                    shelters: _shelters,
                                    onRoute: (s) {
                                      Navigator.of(context).pop();
                                      _animateToLocation(
                                          s.latitude, s.longitude, 15);
                                    },
                                    scrollable: true,
                                    scrollController: scrollController,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          _buildMapWidget(),
                          // Zoom controls on wide too
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: Column(
                              children: [
                                _RoundIconButton(icon: Icons.add,
                                    onPressed: _zoomIn),
                                const SizedBox(height: 8),
                                _RoundIconButton(icon: Icons.remove,
                                    onPressed: _zoomOut),
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
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: [
                      Card(
                        child: ListTile(
                          leading: const Icon(FontAwesomeIcons.locationCrosshairs, color: Colors.blue),
                          title: const Text('Your approximate location'),
                          subtitle: Text(
                              'Lat ${_centerLat.toStringAsFixed(4)}, '
                                  'Lng ${_centerLng.toStringAsFixed(4)}'),
                        ),
                      ),
                      Card(
                        child: _ShelterList(
                          shelters: _shelters,
                          onRoute: (s) =>
                              _animateToLocation(s.latitude, s.longitude, 15),
                          scrollable: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _Shelter {
  final String name;
  final double latitude;
  final double longitude;
  final int capacity;
  final int occupancy;
  const _Shelter({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.capacity,
    required this.occupancy,
  });
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

class _ShelterList extends StatelessWidget {
  final List<_Shelter> shelters;
  final void Function(_Shelter) onRoute;
  final bool scrollable;
  final ScrollController? scrollController;
  const _ShelterList({required this.shelters, required this.onRoute, this.scrollable = false, this.scrollController});

  @override
  Widget build(BuildContext context) {
    if (scrollable) {
      return ListView(
        controller: scrollController,
        children: [
          const ListTile(
            leading: Icon(FontAwesomeIcons.house, color: Colors.green),
            title: Text('Available Shelters'),
          ),
          const Divider(height: 1),
          for (final s in shelters)
            ListTile(
              leading: const Icon(FontAwesomeIcons.house, color: Colors.green),
              title: Text(s.name),
              subtitle: Text('Capacity ${s.capacity} · Occupied ${s.occupancy}'),
              trailing: ElevatedButton.icon(
                icon: const Icon(Icons.directions_walk),
                label: const Text('Route'),
                onPressed: () => onRoute(s),
              ),
            ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ListTile(
          leading: Icon(FontAwesomeIcons.house, color: Colors.green),
          title: Text('Available Shelters'),
        ),
        const Divider(height: 1),
        for (final s in shelters)
          ListTile(
            leading: const Icon(FontAwesomeIcons.house, color: Colors.green),
            title: Text(s.name),
            subtitle: Text('Capacity ${s.capacity} · Occupied ${s.occupancy}'),
            trailing: ElevatedButton.icon(
              icon: const Icon(Icons.directions_walk),
              label: const Text('Route'),
              onPressed: () => onRoute(s),
            ),
          ),
      ],
    );
  }
}
