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
        return 'Food/Shelter Reports Map';
      case 3:
        return 'Volunteer Reports Map';
      default:
        return 'Reports Map';
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
        return FontAwesomeIcons.house;
      case 3:
        return FontAwesomeIcons.userGroup;
      default:
        return FontAwesomeIcons.map;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create dummy data based on choice
    final dummyData = _createDummyData();
    
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
          children: [
            Icon(_icon, color: _accent),
            const SizedBox(width: 10),
            Text(_title),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(_centerLat, _centerLng),
              initialZoom: 13.0,
              minZoom: 3.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.sahaaya',
              ),
              MarkerLayer(
                markers: dummyData.map((data) =>
                    Marker(
                      point: LatLng(data['lat'], data['lng']),
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
          
          // Info panel
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(_icon, color: _accent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Reports: ${dummyData.length}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Latest: ${dummyData.isNotEmpty ? dummyData.first['time'] : 'No reports'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
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

  List<Map<String, dynamic>> _createDummyData() {
    // Create different amounts of dummy data based on choice
    int count = 0;
    switch (widget.choice) {
      case 1: // Emergency
        count = 3;
        break;
      case 2: // Food/Shelter
        count = 5;
        break;
      case 3: // Volunteer
        count = 2;
        break;
      default:
        count = 1;
    }
    
    List<Map<String, dynamic>> dummyData = [];
    for (int i = 0; i < count; i++) {
      dummyData.add({
        'lat': _centerLat + (i % 3 - 1) * 0.01,
        // Spread around
        'lng': _centerLng + (i % 2) * 0.01,
        'time': '${DateTime.now().day}/${DateTime.now().month} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'title': _getDummyTitle(i),
      });
    }
    
    return dummyData;
  }

  String _getDummyTitle(int index) {
    switch (widget.choice) {
      case 1: // Emergency
        return 'Emergency Report ${index + 1}';
      case 2: // Food/Shelter
        return 'Food/Shelter Need ${index + 1}';
      case 3: // Volunteer
        return 'Volunteer Request ${index + 1}';
      default:
        return 'Report ${index + 1}';
    }
  }
}
