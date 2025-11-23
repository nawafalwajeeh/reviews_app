import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchSuggestion {
  final String id;
  final String title;
  final String? subtitle;
  final LatLng? location;
  final String type; // 'place', 'address', 'recent', 'current_location'
  final String? placeId;
  final String? icon;

  SearchSuggestion({
    required this.id,
    required this.title,
    this.subtitle,
    this.location,
    required this.type,
    this.placeId,
    this.icon,
  });

  @override
  String toString() {
    return 'SearchSuggestion{title: $title, type: $type, location: $location}';
  }
}