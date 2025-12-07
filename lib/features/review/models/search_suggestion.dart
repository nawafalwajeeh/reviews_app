// Add this to your existing models or create a new file
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controllers/category_controller.dart';
import 'category_model.dart';
import 'google_search_suggestions.dart';
import 'place_model.dart';

class SearchSuggestion {
  final String id;
  final String title;
  final String? subtitle;
  final LatLng? location;
  final String type; // 'local_place', 'google_place', 'address', 'recent', 'current_location'
  final String? placeId;
  final String? icon;
  final String? category;
  final double? rating;
  final int? reviewCount;
  final bool? isOpen;
  final double? distance;
  final String? photoReference;

  SearchSuggestion({
    required this.id,
    required this.title,
    this.subtitle,
    this.location,
    required this.type,
    this.placeId,
    this.icon,
    this.category,
    this.rating,
    this.reviewCount,
    this.isOpen,
    this.distance,
    this.photoReference,
  });

  // Convert from GooglePlaceSuggestion
  factory SearchSuggestion.fromGooglePlace(GooglePlaceSuggestion googlePlace) {
    return SearchSuggestion(
      id: googlePlace.id,
      title: googlePlace.title,
      subtitle: googlePlace.subtitle,
      location: googlePlace.location,
      type: 'google_place',
      placeId: googlePlace.placeId,
      icon: googlePlace.icon,
      category: googlePlace.category,
      rating: googlePlace.rating,
      reviewCount: googlePlace.reviewCount,
      isOpen: googlePlace.isOpen,
      distance: googlePlace.distance,
      photoReference: googlePlace.photoReference,
    );
  }

  // Convert from PlaceModel (your local places)
  factory SearchSuggestion.fromPlaceModel(PlaceModel place) {
    return SearchSuggestion(
      id: place.id,
      title: place.title,
      subtitle: place.address.shortAddress,
      location: LatLng(place.latitude, place.longitude),
      type: 'local_place',
      placeId: place.id,
      icon: _getIconFromCategory(place.categoryId),
      category: place.categoryId,
      rating: place.averageRating,
      reviewCount: place.reviewsCount,
    );
  }

  static String? _getIconFromCategory(String categoryId) {
    // Map your category IDs to icons
    final categoryController = CategoryController.instance;
    try {
      final category = categoryController.allCategories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => CategoryModel.empty(),
      );
      return category.iconKey;
    } catch (e) {
      return 'place';
    }
  }

  @override
  String toString() {
    return 'SearchSuggestion{title: $title, type: $type, location: $location}';
  }
}