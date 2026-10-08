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
        return 'Food & Shelter Needs';
      case 3:
        return 'Volunteer Connect';
      default:
        return 'Relief Crisis Map';
    }
  }

  Color get _accent {
    switch (widget.choice) {
      case 1:
        return const Color(0xFFDC2626);
      case 2:
        return const Color(0xFFD97706);
      case 3:
        return const Color(0xFF059669);
      default:
        return const Color(0xFF4F46E5);
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
        return FontAwesomeIcons.mapLocationDot;
    }
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

  @override
  Widget build(BuildContext context) {
    final markersData = _buildMarkersData();
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
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_icon, color: _accent, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _title,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: isNarrow
          ? Stack(
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
                        MarkerLayer(
                          markers: markersData
                              .map((m) => Marker(
                                    point: LatLng(m['lat'] as double, m['lng'] as double),
                                    width: 38,
                                    height: 38,
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      color: _accent,
                                      size: 38,
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
                  bottom: 24,
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
                  bottom: 24,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.format_list_bulleted_rounded, size: 18),
                    label: Text('Spots (${markersData.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
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
                            return ListView(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              children: [
                                Text(_title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                                const SizedBox(height: 12),
                                ...markersData.map((m) => Card(
                                      elevation: 0,
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                                      ),
                                      child: ListTile(
                                        leading: Icon(_icon, color: _accent),
                                        title: Text(m['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                        subtitle: Text(m['subtitle'] as String, style: const TextStyle(fontSize: 12)),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _animateToLocation(m['lat'] as double, m['lng'] as double, 15);
                                        },
                                      ),
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
                            MarkerLayer(
                              markers: markersData
                                  .map((m) => Marker(
                                        point: LatLng(m['lat'] as double, m['lng'] as double),
                                        width: 38,
                                        height: 38,
                                        child: Icon(
                                          Icons.location_on_rounded,
                                          color: _accent,
                                          size: 38,
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 16,
                        bottom: 24,
                        child: Column(
                          children: [
                            _RoundIconButton(icon: Icons.add, onPressed: _zoomIn),
                            const SizedBox(height: 8),
                            _RoundIconButton(icon: Icons.remove, onPressed: _zoomOut),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, color: const Color(0xFFE2E8F0)),
                Expanded(
                  flex: 2,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(_title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                      const SizedBox(height: 12),
                      ...markersData.map((m) => Card(
                            elevation: 0,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            child: ListTile(
                              leading: Icon(_icon, color: _accent),
                              title: Text(m['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              subtitle: Text(m['subtitle'] as String, style: const TextStyle(fontSize: 12)),
                              onTap: () => _animateToLocation(m['lat'] as double, m['lng'] as double, 15),
                            ),
                          )),
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
        return const [
          {'title': 'Precinct Crowd Incident', 'subtitle': 'Critical response required', 'lat': 31.6208, 'lng': 74.8765},
          {'title': 'Market Alley Distress', 'subtitle': 'First responder en route', 'lat': 31.6215, 'lng': 74.8741},
          {'title': 'Transit Area Evacuation', 'subtitle': 'Sector police flagged', 'lat': 31.6398, 'lng': 74.8729},
        ];
      case 2:
        return const [
          {'title': 'Community Hall Relief Kitchen', 'subtitle': 'Hot meals & dry rations', 'lat': 31.6250, 'lng': 74.8700},
          {'title': 'Primary School Shelter', 'subtitle': 'Blankets & water purification', 'lat': 31.6300, 'lng': 74.8800},
          {'title': 'Sports Complex Camp', 'subtitle': '200 emergency bedding capacity', 'lat': 31.6450, 'lng': 74.8650},
        ];
      case 3:
        return const [
          {'title': 'Youth Red Cross Team Alpha', 'subtitle': '8 volunteers available', 'lat': 31.6280, 'lng': 74.8750},
          {'title': 'Civic Rescue Brigade Hub', 'subtitle': 'Medical triage & logistics', 'lat': 31.6350, 'lng': 74.8680},
        ];
      default:
        return const [];
    }
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
