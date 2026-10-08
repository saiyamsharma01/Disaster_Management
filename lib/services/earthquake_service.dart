import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class EarthquakeData {
  final String id;
  final String location;
  final double magnitude;
  final DateTime time;
  final double latitude;
  final double longitude;
  final double depth;
  final String? tsunami;
  final String? alert;

  EarthquakeData({
    required this.id,
    required this.location,
    required this.magnitude,
    required this.time,
    required this.latitude,
    required this.longitude,
    required this.depth,
    this.tsunami,
    this.alert,
  });

  factory EarthquakeData.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'];
    final geometry = json['geometry'];
    final coordinates = geometry['coordinates'] as List;

    return EarthquakeData(
      id: json['id'] ?? '',
      location: properties['place'] ?? 'Unknown location',
      magnitude: (properties['mag'] ?? 0.0).toDouble(),
      time: DateTime.fromMillisecondsSinceEpoch(properties['time'] ?? 0),
      latitude: coordinates[1].toDouble(),
      longitude: coordinates[0].toDouble(),
      depth: coordinates[2].toDouble(),
      tsunami: properties['tsunami']?.toString(),
      alert: properties['alert'],
    );
  }

  String get severityLevel {
    if (magnitude >= 7.0) return 'SEVERE';
    if (magnitude >= 6.0) return 'HIGH';
    if (magnitude >= 5.0) return 'MODERATE';
    if (magnitude >= 4.0) return 'MEDIUM';
    return 'LOW';
  }

  String get timeAgo {
    final difference = DateTime.now().difference(time);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}

class EarthquakeService {
  // In-memory cache to prevent repeated multi-megabyte downloads and UI lag
  static final Map<String, List<EarthquakeData>> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(minutes: 3);

  // Different time ranges for earthquake data
  static const String allDayUrl =
      'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson';
  static const String allWeekUrl =
      'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_week.geojson';
  static const String significantMonthUrl =
      'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/significant_month.geojson';
  static const String magnitude4_5WeekUrl =
      'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/4.5_week.geojson';

  /// Fetches earthquake data from USGS API with smart in-memory caching
  Future<List<EarthquakeData>> getEarthquakeData({
    String timeRange = 'day',
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _cache.containsKey(timeRange) &&
        _cacheTimestamps.containsKey(timeRange) &&
        now.difference(_cacheTimestamps[timeRange]!) < _cacheDuration) {
      return _cache[timeRange]!;
    }

    String url = allDayUrl;
    switch (timeRange) {
      case 'week':
        url = allWeekUrl;
        break;
      case 'significant':
        url = significantMonthUrl;
        break;
      case 'major':
        url = magnitude4_5WeekUrl;
        break;
      default:
        url = allDayUrl;
    }

    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List;

        final list = features
            .map((quake) => EarthquakeData.fromJson(quake))
            .toList()
          ..sort((a, b) => b.time.compareTo(a.time));

        _cache[timeRange] = list;
        _cacheTimestamps[timeRange] = now;
        return list;
      } else {
        if (_cache.containsKey(timeRange)) {
          return _cache[timeRange]!;
        }
        throw Exception(
            'Failed to fetch earthquake data: ${response.statusCode}');
      }
    } catch (e) {
      if (_cache.containsKey(timeRange)) {
        return _cache[timeRange]!;
      }
      throw Exception('Error fetching earthquake data: $e');
    }
  }

  /// Gets earthquakes near a specific location (within radius in km)
  Future<List<EarthquakeData>> getEarthquakesNearLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 500,
    String timeRange = 'day',
  }) async {
    final allQuakes = await getEarthquakeData(timeRange: timeRange);

    return allQuakes.where((quake) {
      final distance = _calculateDistance(
        latitude,
        longitude,
        quake.latitude,
        quake.longitude,
      );
      return distance <= radiusKm;
    }).toList();
  }

  /// Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2,
      double lon2) {
    const earthRadius = 6371.0; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }
}
