import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class IVROutcomePage extends StatefulWidget {
  const IVROutcomePage({super.key, required this.choice});

  final int choice; // 1, 2 or 3
  @override
  State<IVROutcomePage> createState() => _IVROutcomePageState();
}

class _IVROutcomePageState extends State<IVROutcomePage> {
  final MapController _mapController = MapController();
  static const double _centerLat = 31.6340;
  static const double _centerLng = 74.8723;

  String get _title {
    switch (widget.choice) {
      case 1:
        return 'Emergency Reports';
      case 2:
        return 'Food / Shelter Needs';
      case 3:
        return 'Volunteer Connect';
      default:
        return 'Crisis Map';
    }
  }

  Color get _accent {
    switch (widget.choice) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  IconData get _icon {
    switch (widget.choice) {
      case 1:
        return FontAwesomeIcons.triangleExclamation;
      case 2:
        return FontAwesomeIcons.bowlFood;
      case 3:
        return FontAwesomeIcons.userGroup;
      default:
        return FontAwesomeIcons.map;
    }
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

  @override
  Widget build(BuildContext context) {
    final markersData = _buildMarkersData();
    final bool isNarrow = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/dashboard');
            }
          },
          tooltip: 'Back',
        ),
        title: Row(
          children: [
            Icon(_icon, color: _accent),
            const SizedBox(width: 10),
            Text(_title),
          ],
        ),
      ),
      body: isNarrow
          ? Stack(
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
                          MarkerLayer(
                            markers: markersData.map((m) =>
                                Marker(
                                  point: LatLng(m['lat'], m['lng']),
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    Icons.location_on,
                                    color: _accent,
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
                    label: const Text('View Spots'),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        showDragHandle: true,
                        isScrollControlled: true,
                        builder: (ctx) => DraggableScrollableSheet(
                          expand: false,
                          initialChildSize: 0.5,
                          minChildSize: 0.3,
                          maxChildSize: 0.9,
                          builder: (context, scrollController) {
                            return ListView(
                              controller: scrollController,
                              children: [
                                ListTile(
                                  leading: Icon(_icon, color: _accent),
                                  title: Text(_title),
                                  subtitle: const Text('Dummy data for demo purposes'),
                                ),
                                const Divider(height: 1),
                                ...markersData.map((m) =>
                                    ListTile(
                                      leading: Icon(_icon, color: _accent),
                                  title: Text(m['title']),
                                  subtitle: Text(m['subtitle']),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _animateToLocation(m['lat'], m['lng'], 15);
                                  },
                                )),
                              ],
                            );
                          },
                        ),
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
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: const LatLng(
                                  _centerLat, _centerLng),
                              initialZoom: 13.0,
                              minZoom: 3.0,
                              maxZoom: 18.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.sahaaya',
                              ),
                              MarkerLayer(
                                markers: markersData.map((m) =>
                                    Marker(
                                      point: LatLng(m['lat'], m['lng']),
                                      width: 40,
                                      height: 40,
                                      child: Icon(
                                        Icons.location_on,
                                        color: _accent,
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
                          leading: Icon(_icon, color: _accent),
                          title: Text(_title),
                          subtitle: const Text('Dummy data for demo purposes'),
                        ),
                      ),
                      Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ListTile(
                              leading: Icon(FontAwesomeIcons.list),
                              title: Text('Spots'),
                            ),
                            const Divider(height: 1),
                            ...markersData.map((m) =>
                                ListTile(
                                  leading: Icon(_icon, color: _accent),
                              title: Text(m['title']),
                              subtitle: Text(m['subtitle']),
                              onTap: () =>
                                  _animateToLocation(m['lat'], m['lng'], 15),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  List<Map<String, dynamic>> _buildMarkersData() {
    switch (widget.choice) {
      case 1:
        return [
          {
            'lat': 31.6365,
            'lng': 74.8742,
            'title': 'Rescue Needed',
            'subtitle': 'People stranded on roof',
          },
          {
            'lat': 31.6302,
            'lng': 74.8789,
            'title': 'Medical Emergency',
            'subtitle': 'Injured individuals',
          },
        ];
      case 2:
        return [
          {
            'lat': 31.6375,
            'lng': 74.8752,
            'title': 'Food Needed',
            'subtitle': '50 meals required',
          },
          {
            'lat': 31.6412,
            'lng': 74.8821,
            'title': 'Shelter Open',
            'subtitle': 'Capacity 200',
          },
          {
            'lat': 31.6327,
            'lng': 74.8705,
            'title': 'Water Point',
            'subtitle': 'Drinking water available',
          },
        ];
      case 3:
        return [
          {
            'lat': 31.6451,
            'lng': 74.8698,
            'title': 'Volunteer Hub',
            'subtitle': 'Supply sorting',
          },
          {
            'lat': 31.6391,
            'lng': 74.8729,
            'title': 'NGO Camp',
            'subtitle': 'First-aid & blankets',
          },
        ];
      default:
        return [];
    }
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
