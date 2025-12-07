import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Model for Google Directions API response
class DirectionsModel {
  final List<RouteModel> routes;
  final String status;

  DirectionsModel({required this.routes, required this.status});

  factory DirectionsModel.fromJson(Map<String, dynamic> json) {
    return DirectionsModel(
      routes:
          (json['routes'] as List?)
              ?.map((route) => RouteModel.fromJson(route))
              .toList() ??
          [],
      status: json['status'] ?? '',
    );
  }
}

/// Model for a single route
class RouteModel {
  final String summary;
  final List<LegModel> legs;
  final String overviewPolyline;
  final List<LatLng> polylinePoints;
  final LatLngBounds bounds;

  RouteModel({
    required this.summary,
    required this.legs,
    required this.overviewPolyline,
    required this.polylinePoints,
    required this.bounds,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    final overviewPolyline =
        json['overview_polyline']?['points'] as String? ?? '';
    final polylinePoints = _decodePolyline(overviewPolyline);

    final boundsJson = json['bounds'];
    final bounds = LatLngBounds(
      southwest: LatLng(
        boundsJson['southwest']['lat'],
        boundsJson['southwest']['lng'],
      ),
      northeast: LatLng(
        boundsJson['northeast']['lat'],
        boundsJson['northeast']['lng'],
      ),
    );

    return RouteModel(
      summary: json['summary'] ?? '',
      legs:
          (json['legs'] as List?)
              ?.map((leg) => LegModel.fromJson(leg))
              .toList() ??
          [],
      overviewPolyline: overviewPolyline,
      polylinePoints: polylinePoints,
      bounds: bounds,
    );
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
}

/// Model for a route leg (segment between two waypoints)
class LegModel {
  final String distance;
  final String duration;
  final int distanceValue; // in meters
  final int durationValue; // in seconds
  final LatLng startLocation;
  final LatLng endLocation;
  final String startAddress;
  final String endAddress;
  final List<StepModel> steps;

  LegModel({
    required this.distance,
    required this.duration,
    required this.distanceValue,
    required this.durationValue,
    required this.startLocation,
    required this.endLocation,
    required this.startAddress,
    required this.endAddress,
    required this.steps,
  });

  factory LegModel.fromJson(Map<String, dynamic> json) {
    return LegModel(
      distance: json['distance']?['text'] ?? '',
      duration: json['duration']?['text'] ?? '',
      distanceValue: json['distance']?['value'] ?? 0,
      durationValue: json['duration']?['value'] ?? 0,
      startLocation: LatLng(
        json['start_location']['lat'],
        json['start_location']['lng'],
      ),
      endLocation: LatLng(
        json['end_location']['lat'],
        json['end_location']['lng'],
      ),
      startAddress: json['start_address'] ?? '',
      endAddress: json['end_address'] ?? '',
      steps:
          (json['steps'] as List?)
              ?.map((step) => StepModel.fromJson(step))
              .toList() ??
          [],
    );
  }
}

/// Model for a navigation step
class StepModel {
  final String htmlInstructions;
  final String distance;
  final String duration;
  final int distanceValue;
  final int durationValue;
  final LatLng startLocation;
  final LatLng endLocation;
  final String travelMode;
  final String? maneuver;

  StepModel({
    required this.htmlInstructions,
    required this.distance,
    required this.duration,
    required this.distanceValue,
    required this.durationValue,
    required this.startLocation,
    required this.endLocation,
    required this.travelMode,
    this.maneuver,
  });

  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(
      htmlInstructions: json['html_instructions'] ?? '',
      distance: json['distance']?['text'] ?? '',
      duration: json['duration']?['text'] ?? '',
      distanceValue: json['distance']?['value'] ?? 0,
      durationValue: json['duration']?['value'] ?? 0,
      startLocation: LatLng(
        json['start_location']['lat'],
        json['start_location']['lng'],
      ),
      endLocation: LatLng(
        json['end_location']['lat'],
        json['end_location']['lng'],
      ),
      travelMode: json['travel_mode'] ?? 'DRIVING',
      maneuver: json['maneuver'],
    );
  }

  /// Get plain text instructions (remove HTML tags)
  String get plainInstructions {
    return htmlInstructions
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }
}
