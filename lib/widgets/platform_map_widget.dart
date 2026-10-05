import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

/// A platform-aware map widget that uses:
/// - flutter_map for Web
/// - Mapbox for Mobile (Android/iOS)
class PlatformMapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  final List<PlatformMarker>? markers;
  final Function()? onMapCreated;

  const PlatformMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 13.0,
    this.markers,
    this.onMapCreated,
  });

  @override
  State<PlatformMapWidget> createState() => _PlatformMapWidgetState();
}

class _PlatformMapWidgetState extends State<PlatformMapWidget> {
  mapbox.MapboxMap? _mapboxMap;
  flutter_map.MapController? _flutterMapController;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _flutterMapController = flutter_map.MapController();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildFlutterMap();
    } else {
      return _buildMapboxMap();
    }
  }

  // Build flutter_map for Web
  Widget _buildFlutterMap() {
    return flutter_map.FlutterMap(
      mapController: _flutterMapController,
      options: flutter_map.MapOptions(
        initialCenter: latlong.LatLng(widget.latitude, widget.longitude),
        initialZoom: widget.zoom,
      ),
      children: [
        flutter_map.TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        if (widget.markers != null && widget.markers!.isNotEmpty)
          flutter_map.MarkerLayer(
            markers: widget.markers!
                .map((m) =>
                flutter_map.Marker(
                  point: latlong.LatLng(m.latitude, m.longitude),
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.location_pin,
                    color: m.color ?? Colors.red,
                    size: 40,
                  ),
                ))
                .toList(),
          ),
      ],
    );
  }

  // Build Mapbox map for Mobile
  Widget _buildMapboxMap() {
    return mapbox.MapWidget(
      cameraOptions: mapbox.CameraOptions(
        center: mapbox.Point(
          coordinates: mapbox.Position(widget.longitude, widget.latitude),
        ),
        zoom: widget.zoom,
        bearing: 0,
        pitch: 0,
      ),
      onMapCreated: (mapbox.MapboxMap mapboxMap) {
        _mapboxMap = mapboxMap;
        _setupMapboxMarkers();
        if (widget.onMapCreated != null) {
          widget.onMapCreated!();
        }
      },
    );
  }

  Future<void> _setupMapboxMarkers() async {
    if (_mapboxMap == null || widget.markers == null) return;

    final pointAnnotationManager =
    await _mapboxMap!.annotations.createPointAnnotationManager();

    for (final marker in widget.markers!) {
      final pointAnnotationOptions = mapbox.PointAnnotationOptions(
        geometry: mapbox.Point(
          coordinates: mapbox.Position(marker.longitude, marker.latitude),
        ),
        iconImage: "marker",
        iconSize: 1.2,
        iconColor: (marker.color ?? Colors.red).toARGB32(),
      );

      await pointAnnotationManager.create(pointAnnotationOptions);
    }
  }
}

/// Platform-agnostic marker class
class PlatformMarker {
  final double latitude;
  final double longitude;
  final Color? color;
  final String? title;
  final String? description;

  const PlatformMarker({
    required this.latitude,
    required this.longitude,
    this.color,
    this.title,
    this.description,
  });
}
