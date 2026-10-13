import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:http/http.dart' as http;

class LocationResult {
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final String shortAddress;
  final String? street;
  final String? area;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final double? accuracy;
  final DateTime timestamp;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    required this.shortAddress,
    this.street,
    this.area,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.accuracy,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'formattedAddress': formattedAddress,
      'shortAddress': shortAddress,
      'street': street,
      'area': area,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class LocationServiceDisabledException implements Exception {
  final String message;
  LocationServiceDisabledException([this.message = 'Device GPS / Location Services are disabled.']);
  @override
  String toString() => message;
}

class LocationPermissionDeniedException implements Exception {
  final String message;
  LocationPermissionDeniedException([this.message = 'Location permission was denied by the user.']);
  @override
  String toString() => message;
}

class LocationPermissionPermanentlyDeniedException implements Exception {
  final String message;
  LocationPermissionPermanentlyDeniedException([
    this.message = 'Location permission is permanently denied. Please allow it from App Settings.',
  ]);
  @override
  String toString() => message;
}

class LocationFetchException implements Exception {
  final String message;
  LocationFetchException([this.message = 'Unable to determine GPS location.']);
  @override
  String toString() => message;
}

class LocationService {
  static Future<bool> isLocationServiceEnabled() async {
    return await geolocator.Geolocator.isLocationServiceEnabled();
  }

  static Future<bool> openLocationSettings() async {
    return await geolocator.Geolocator.openLocationSettings();
  }

  static Future<bool> openAppSettings() async {
    return await geolocator.Geolocator.openAppSettings();
  }

  /// Request GPS position and resolve to a real formatted address via reverse geocoding
  static Future<LocationResult> getCurrentLocation({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    // 1. Check if location services (GPS) are enabled on the device
    final serviceEnabled = await geolocator.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceDisabledException();
    }

    // 2. Check and request location permission
    geolocator.LocationPermission permission =
        await geolocator.Geolocator.checkPermission();

    if (permission == geolocator.LocationPermission.denied) {
      permission = await geolocator.Geolocator.requestPermission();
      if (permission == geolocator.LocationPermission.denied) {
        throw LocationPermissionDeniedException();
      }
    }

    if (permission == geolocator.LocationPermission.deniedForever) {
      throw LocationPermissionPermanentlyDeniedException();
    }

    // 3. Obtain location position
    geolocator.Position? position;

    try {
      position = await geolocator.Geolocator.getCurrentPosition(
        locationSettings: geolocator.LocationSettings(
          accuracy: geolocator.LocationAccuracy.high,
          timeLimit: timeout,
        ),
      );
    } catch (e) {
      debugPrint('⚠️ getCurrentPosition error or timeout ($e), trying lastKnownPosition...');
    }

    // Fall back to last known position if current position acquisition timed out
    if (position == null) {
      try {
        position = await geolocator.Geolocator.getLastKnownPosition();
      } catch (e) {
        debugPrint('⚠️ getLastKnownPosition error: $e');
      }
    }

    if (position == null) {
      throw LocationFetchException(
        'GPS signal not received in time. Please check your signal or enter manually.',
      );
    }

    // 4. Reverse geocode coordinates into a real street / city address
    return await reverseGeocode(position);
  }

  /// Reverse geocode coordinates to human-readable address
  static Future<LocationResult> reverseGeocode(geolocator.Position position) async {
    final lat = position.latitude;
    final lon = position.longitude;

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1',
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'Sahaaya-Disaster-App/1.0 (contact@sahaaya.org)',
          'Accept-Language': 'en',
        },
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>? ?? {};

        final road = address['road'] ??
            address['pedestrian'] ??
            address['street'] ??
            address['path'];
        final area = address['suburb'] ??
            address['neighbourhood'] ??
            address['residential'] ??
            address['hamlet'] ??
            address['village'];
        final city = address['city'] ??
            address['town'] ??
            address['municipality'] ??
            address['county'] ??
            address['state_district'];
        final state = address['state'];
        final postcode = address['postcode'];
        final country = address['country'];

        // Build a clean, readable short address
        final parts = <String>[];
        if (road != null && road.toString().trim().isNotEmpty) {
          parts.add(road.toString().trim());
        }
        if (area != null &&
            area.toString().trim().isNotEmpty &&
            !parts.contains(area.toString().trim())) {
          parts.add(area.toString().trim());
        }
        if (city != null &&
            city.toString().trim().isNotEmpty &&
            !parts.contains(city.toString().trim())) {
          parts.add(city.toString().trim());
        }
        if (state != null && state.toString().trim().isNotEmpty) {
          parts.add(state.toString().trim());
        }

        final shortAddr = parts.isNotEmpty
            ? parts.join(', ')
            : (data['display_name'] ?? 'Near $lat, $lon');

        return LocationResult(
          latitude: lat,
          longitude: lon,
          formattedAddress: data['display_name'] ?? shortAddr,
          shortAddress: shortAddr,
          street: road?.toString(),
          area: area?.toString(),
          city: city?.toString(),
          state: state?.toString(),
          postalCode: postcode?.toString(),
          country: country?.toString(),
          accuracy: position.accuracy,
        );
      }
    } catch (e) {
      debugPrint('⚠️ Reverse geocoding error ($e). Using coordinates fallback.');
    }

    // Fallback if offline or reverse geocoding API error
    final fallback =
        'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lon.toStringAsFixed(4)}';
    return LocationResult(
      latitude: lat,
      longitude: lon,
      formattedAddress: fallback,
      shortAddress: fallback,
      accuracy: position.accuracy,
    );
  }
}
