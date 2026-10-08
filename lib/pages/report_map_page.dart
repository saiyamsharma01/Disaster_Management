import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class ReportMapPage extends StatefulWidget {
  const ReportMapPage({super.key, required this.choice});

  final int choice; // 1, 2 or 3

  @override
  State<ReportMapPage> createState() => _ReportMapPageState();
}

class _ReportMapPageState extends State<ReportMapPage> {
  final MapController _mapController = MapController();
  static const double _centerLat = 31.6340;
  static const double _centerLng = 74.8723; // Amritsar center

  String get _title {
    switch (widget.choice) {
      case 1:
        return 'Emergency Reports Map';
      case 2:
        return 'Food & Shelter Needs';
      case 3:
        return 'Volunteer Deployment Map';
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
        return FontAwesomeIcons.house;
      case 3:
        return FontAwesomeIcons.userGroup;
      default:
        return FontAwesomeIcons.mapLocationDot;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dummyData = _createDummyData();

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
                  fontSize: 17,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Map
          RepaintBoundary(
            child: FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(_centerLat, _centerLng),
                initialZoom: 13.5,
                minZoom: 3.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.sahaaya',
                ),
                MarkerLayer(
                  markers: dummyData
                      .map((data) => Marker(
                            point: LatLng(data['lat'] as double, data['lng'] as double),
                            width: 40,
                            height: 40,
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

          // Floating Summary Card
          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_icon, color: _accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${dummyData.length} Active Verified Reports in Sector',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _createDummyData() {
    int count = 4;
    if (widget.choice == 1) count = 3;
    if (widget.choice == 2) count = 5;
    if (widget.choice == 3) count = 3;

    final List<Map<String, dynamic>> list = [];
    for (int i = 0; i < count; i++) {
      list.add({
        'lat': _centerLat + (i % 3 - 1) * 0.012,
        'lng': _centerLng + (i % 2 == 0 ? 0.01 : -0.01),
        'title': 'Report #${i + 1}',
      });
    }
    return list;
  }
}
