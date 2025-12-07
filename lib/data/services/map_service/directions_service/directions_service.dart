import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../utils/logging/logger.dart';
import '../../../../features/review/models/directions_model.dart';

/// Service for fetching directions using FREE OSRM (OpenStreetMap) API
/// No API key or billing required!
class DirectionsService {
  // Free OSRM Demo Server - No API key needed!
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1';
  static final http.Client _client = http.Client();

  /// Fetch directions between two points using FREE OSRM API
  ///
  /// [origin] - Starting point
  /// [destination] - Ending point
  /// [travelMode] - Mode of travel: driving, walking, bicycling
  /// [alternatives] - Whether to return alternative routes
  /// [language] - Language for instructions (not used by OSRM)
  static Future<DirectionsModel?> getDirections({
    required LatLng origin,
    required LatLng destination,
    String travelMode = 'driving',
    bool alternatives = false,
    String language = 'en',
  }) async {
    try {
      // Convert travel mode to OSRM profile
      String profile = _getTravelModeProfile(travelMode);

      // OSRM uses lon,lat format (opposite of Google Maps!)
      final coordinates =
          '${origin.longitude},${origin.latitude};'
          '${destination.longitude},${destination.latitude}';

      // Build OSRM URL
      final uri = Uri.parse('$_baseUrl/$profile/$coordinates').replace(
        queryParameters: {
          'overview': 'full',
          'geometries': 'polyline',
          'steps': 'true',
          'alternatives': alternatives.toString(),
        },
      );

      AppLoggerHelper.info('Fetching directions from OSRM: $uri');
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['code'] == 'Ok' &&
            data['routes'] != null &&
            data['routes'].isNotEmpty) {
          // Convert OSRM response to our DirectionsModel format
          return _convertOSRMToDirectionsModel(data, origin, destination);
        } else {
          AppLoggerHelper.warning('No route found between the two points');
          return null;
        }
      } else {
        AppLoggerHelper.error(
          'HTTP error fetching directions: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      AppLoggerHelper.error('Error fetching directions: $e');
      return null;
    }
  }

  /// Convert travel mode to OSRM profile
  static String _getTravelModeProfile(String travelMode) {
    switch (travelMode.toLowerCase()) {
      case 'walking':
        return 'foot';
      case 'bicycling':
      case 'cycling':
        return 'bike';
      case 'driving':
      default:
        return 'car';
    }
  }

  /// Convert OSRM response to DirectionsModel
  static DirectionsModel _convertOSRMToDirectionsModel(
    Map<String, dynamic> osrmData,
    LatLng origin,
    LatLng destination,
  ) {
    final routes = <RouteModel>[];

    for (final route in osrmData['routes']) {
      // Decode polyline
      final polylineEncoded = route['geometry'] as String;
      final polylinePoints = _decodePolyline(polylineEncoded);

      // Get distance and duration
      final distance = (route['distance'] as num).toInt(); // meters
      final duration = (route['duration'] as num).toInt(); // seconds

      // Create bounds
      final bounds = _createBoundsFromPoints(polylinePoints);

      // Create a single leg from origin to destination
      final leg = LegModel(
        distance: formatDistance(distance),
        duration: formatDuration(duration),
        distanceValue: distance,
        durationValue: duration,
        startLocation: origin,
        endLocation: destination,
        startAddress: 'Origin',
        endAddress: 'Destination',
        steps: [], // OSRM steps could be parsed here if needed
      );

      // Create route model with all required fields
      routes.add(
        RouteModel(
          summary: 'Route via OSRM',
          legs: [leg],
          overviewPolyline: polylineEncoded,
          polylinePoints: polylinePoints,
          bounds: bounds,
        ),
      );
    }

    return DirectionsModel(routes: routes, status: 'OK');
  }

  /// Decode polyline string to list of LatLng points
  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  /// Create bounds from list of points
  static LatLngBounds _createBoundsFromPoints(List<LatLng> points) {
    double? minLat, maxLat, minLng, maxLng;

    for (final point in points) {
      minLat = minLat == null ? point.latitude : min(minLat, point.latitude);
      maxLat = maxLat == null ? point.latitude : max(maxLat, point.latitude);
      minLng = minLng == null ? point.longitude : min(minLng, point.longitude);
      maxLng = maxLng == null ? point.longitude : max(maxLng, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat ?? 0, minLng ?? 0),
      northeast: LatLng(maxLat ?? 0, maxLng ?? 0),
    );
  }

  /// Get directions with waypoints using OSRM
  static Future<DirectionsModel?> getDirectionsWithWaypoints({
    required LatLng origin,
    required LatLng destination,
    required List<LatLng> waypoints,
    String travelMode = 'driving',
    bool optimizeWaypoints = false,
    String language = 'en',
  }) async {
    try {
      String profile = _getTravelModeProfile(travelMode);

      // Build coordinates string with waypoints
      String coordinates = '${origin.longitude},${origin.latitude}';
      for (final waypoint in waypoints) {
        coordinates += ';${waypoint.longitude},${waypoint.latitude}';
      }
      coordinates += ';${destination.longitude},${destination.latitude}';

      final uri = Uri.parse('$_baseUrl/$profile/$coordinates').replace(
        queryParameters: {
          'overview': 'full',
          'geometries': 'polyline',
          'steps': 'true',
        },
      );

      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['code'] == 'Ok' &&
            data['routes'] != null &&
            data['routes'].isNotEmpty) {
          return _convertOSRMToDirectionsModel(data, origin, destination);
        } else {
          AppLoggerHelper.error('No route found with waypoints');
          return null;
        }
      } else {
        AppLoggerHelper.error(
          'HTTP error fetching directions: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      AppLoggerHelper.error('Error fetching directions with waypoints: $e');
      return null;
    }
  }

  /// Calculate distance between two points (in meters)
  static double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // meters

    final lat1Rad = point1.latitude * (pi / 180);
    final lat2Rad = point2.latitude * (pi / 180);
    final deltaLat = (point2.latitude - point1.latitude) * (pi / 180);
    final deltaLng = (point2.longitude - point1.longitude) * (pi / 180);

    final a =
        sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLng / 2) * sin(deltaLng / 2);

    final c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  /// Format distance for display
  static String formatDistance(int meters) {
    if (meters < 1000) {
      return '$meters m';
    } else {
      final km = (meters / 1000).toStringAsFixed(1);
      return '$km km';
    }
  }

  /// Format duration for display
  static String formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds sec';
    } else if (seconds < 3600) {
      final minutes = (seconds / 60).round();
      return '$minutes min';
    } else {
      final hours = (seconds / 3600).floor();
      final minutes = ((seconds % 3600) / 60).round();
      return minutes > 0 ? '$hours h $minutes min' : '$hours h';
    }
  }
}
