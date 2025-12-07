import 'package:google_maps_flutter/google_maps_flutter.dart';

class RecentSearch {
  final String id;
  final String query;
  final String? placeId;
  final LatLng? location;
  final String? address;
  final DateTime timestamp;
  final String type; // 'search', 'place', 'direction'

  RecentSearch({
    required this.id,
    required this.query,
    this.placeId,
    this.location,
    this.address,
    required this.timestamp,
    required this.type,
  });
}