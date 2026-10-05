import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// A reusable Mapbox widget that can be customized for different use cases
class ReusableMapboxWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  final List<MapMarker>? markers;
  final Function(MapboxMap)? onMapCreated;
  final bool showUserLocation;

  const ReusableMapboxWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 13.0,
    this.markers,
    this.onMapCreated,
    this.showUserLocation = false,
  });

  @override
  State<ReusableMapboxWidget> createState() => _ReusableMapboxWidgetState();
}

class _ReusableMapboxWidgetState extends State<ReusableMapboxWidget> {
  MapboxMap? _mapboxMap;

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      cameraOptions: CameraOptions(
        center: Point(coordinates: Position(widget.longitude, widget.latitude)),
        zoom: widget.zoom,
        bearing: 0,
        pitch: 0,
      ),
      onMapCreated: (MapboxMap mapboxMap) {
        _mapboxMap = mapboxMap;
        _setupMap();
        if (widget.onMapCreated != null) {
          widget.onMapCreated!(mapboxMap);
        }
      },
    );
  }

  Future<void> _setupMap() async {
    if (_mapboxMap == null) return;

    // Add markers if provided
    if (widget.markers != null && widget.markers!.isNotEmpty) {
      await _addMarkers();
    }

    // Show user location if requested
    if (widget.showUserLocation) {
      await _mapboxMap!.location.updateSettings(
        LocationComponentSettings(
          enabled: true,
          pulsingEnabled: true,
        ),
      );
    }
  }

  Future<void> _addMarkers() async {
    if (_mapboxMap == null || widget.markers == null) return;

    final pointAnnotationManager =
    await _mapboxMap!.annotations.createPointAnnotationManager();

    for (final marker in widget.markers!) {
      final pointAnnotationOptions = PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(marker.longitude, marker.latitude),
        ),
        iconImage: marker.iconImage,
        iconSize: marker.iconSize,
        iconColor: marker.color?.toARGB32(),
      );

      await pointAnnotationManager.create(pointAnnotationOptions);
    }
  }

  /// Animate camera to a new position
  Future<void> animateCamera({
    required double latitude,
    required double longitude,
    double? zoom,
  }) async {
    if (_mapboxMap == null) return;

    await _mapboxMap!.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(longitude, latitude)),
        zoom: zoom ?? widget.zoom,
        bearing: 0,
        pitch: 0,
      ),
      MapAnimationOptions(duration: 1000, startDelay: 0),
    );
  }
}

/// Class to represent a map marker
class MapMarker {
  final double latitude;
  final double longitude;
  final String? iconImage;
  final double iconSize;
  final Color? color;
  final String? title;
  final String? description;

  const MapMarker({
    required this.latitude,
    required this.longitude,
    this.iconImage,
    this.iconSize = 1.0,
    this.color,
    this.title,
    this.description,
  });
}
