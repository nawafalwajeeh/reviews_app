// --- PLACE MODELS ---
import 'dart:io';
import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../utils/constants/api_constants.dart';

class GooglePlaceSuggestion {
  final String id;
  final String title;
  final String? subtitle;
  final LatLng? location;
  final String type; // 'place', 'address', 'establishment'
  final String? placeId;
  final String? icon;
  final String? category;
  final double? rating;
  final int? reviewCount;
  final bool? isOpen;
  final double? distance;
  final String? photoReference;
  final List<String>? types;

  GooglePlaceSuggestion({
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
    this.types,
  });

  factory GooglePlaceSuggestion.fromAutocomplete(
    Map<String, dynamic> prediction,
  ) {
    final types = List<String>.from(prediction['types'] ?? []);
    final isEstablishment = types.any(
      (type) =>
          type.contains('establishment') || type.contains('point_of_interest'),
    );

    return GooglePlaceSuggestion(
      id: prediction['place_id'] ?? const Uuid().v4(),
      title: prediction['description'],
      subtitle: _extractSubtitle(prediction),
      type: isEstablishment ? 'place' : 'address',
      placeId: prediction['place_id'],
      icon: _getPlaceIcon(types),
      category: _getPrimaryCategory(types),
      types: types,
    );
  }

  factory GooglePlaceSuggestion.fromNearbySearch(
    Map<String, dynamic> result,
    LatLng userLocation,
  ) {
    final types = List<String>.from(result['types'] ?? []);
    final geometry = result['geometry']['location'];
    final location = LatLng(geometry['lat'], geometry['lng']);

    // Calculate distance
    final distance = _calculateDistance(
      userLocation.latitude,
      userLocation.longitude,
      location.latitude,
      location.longitude,
    );

    // Get first photo if available
    String? photoRef;
    if (result['photos'] != null && (result['photos'] as List).isNotEmpty) {
      photoRef = result['photos'][0]['photo_reference'];
    }

    return GooglePlaceSuggestion(
      id: result['place_id'] ?? const Uuid().v4(),
      title: result['name'],
      subtitle: result['vicinity'],
      location: location,
      type: 'place',
      placeId: result['place_id'],
      icon: _getPlaceIcon(types),
      category: _getPrimaryCategory(types),
      rating: result['rating']?.toDouble(),
      reviewCount: result['user_ratings_total'],
      isOpen: result['opening_hours']?['open_now'] ?? false,
      distance: distance,
      photoReference: photoRef,
      types: types,
    );
  }

  static String? _extractSubtitle(Map<String, dynamic> prediction) {
    final description = prediction['description'] as String?;
    if (description != null) {
      final parts = description.split(',');
      if (parts.length > 1) {
        return parts.sublist(1).join(',').trim();
      }
    }
    return null;
  }

  static String _getPlaceIcon(List<String> types) {
    if (types.contains('restaurant') || types.contains('food')) {
      return 'restaurant';
    }
    if (types.contains('cafe') || types.contains('coffee')) return 'local_cafe';
    if (types.contains('bar') || types.contains('night_club')) {
      return 'local_bar';
    }
    if (types.contains('hotel') || types.contains('lodging')) return 'hotel';
    if (types.contains('store') ||
        types.contains('shopping_mall') ||
        types.contains('clothing_store')) {
      return 'store';
    }
    if (types.contains('park') || types.contains('amusement_park')) {
      return 'park';
    }
    if (types.contains('museum') || types.contains('art_gallery')) {
      return 'museum';
    }
    if (types.contains('hospital') ||
        types.contains('health') ||
        types.contains('doctor')) {
      return 'local_hospital';
    }
    if (types.contains('school') ||
        types.contains('university') ||
        types.contains('college')) {
      return 'school';
    }
    if (types.contains('gas_station') || types.contains('car_wash')) {
      return 'local_gas_station';
    }
    if (types.contains('bank') ||
        types.contains('atm') ||
        types.contains('finance')) {
      return 'account_balance';
    }
    if (types.contains('pharmacy') || types.contains('drugstore')) {
      return 'local_pharmacy';
    }
    if (types.contains('gym') || types.contains('health_club')) {
      return 'fitness_center';
    }
    if (types.contains('movie_theater') || types.contains('cinema')) {
      return 'movie';
    }
    if (types.contains('library')) return 'local_library';
    if (types.contains('post_office')) return 'local_post_office';
    if (types.contains('police')) return 'local_police';
    if (types.contains('fire_station')) return 'local_fire_department';
    return 'place';
  }

  static String? _getPrimaryCategory(List<String> types) {
    // Priority order for categories
    const categoryPriority = [
      'restaurant',
      'cafe',
      'bar',
      'hotel',
      'store',
      'park',
      'museum',
      'hospital',
      'school',
      'gas_station',
      'bank',
      'pharmacy',
      'gym',
      'movie_theater',
      'library',
    ];

    for (final category in categoryPriority) {
      if (types.contains(category)) {
        return category;
      }
    }

    return types.isNotEmpty ? types.first : 'establishment';
  }

  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000.0; // Earth's radius in meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _toRadians(double degree) => degree * pi / 180;
}

class GooglePlaceDetails {
  final String name;
  final String? address;
  final LatLng location;
  final String? phoneNumber;
  final String? internationalPhoneNumber;
  final String? website;
  final double? rating;
  final int? totalRatings;
  final List<String> photos;
  final String? placeId;
  final String? category;
  final bool? isOpen;
  final String? openingHours;
  final List<String> types;
  final int? priceLevel; // 0-4
  final List<Review>? reviews;
  final String? businessStatus;
  final String? formattedPhoneNumber;

  GooglePlaceDetails({
    required this.name,
    this.address,
    required this.location,
    this.phoneNumber,
    this.internationalPhoneNumber,
    this.website,
    this.rating,
    this.totalRatings,
    this.photos = const [],
    this.placeId,
    this.category,
    this.isOpen,
    this.openingHours,
    this.types = const [],
    this.priceLevel,
    this.reviews,
    this.businessStatus,
    this.formattedPhoneNumber,
  });

  factory GooglePlaceDetails.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    final geometry = result['geometry']['location'];

    // Extract photos
    final photos = <String>[];
    if (result['photos'] != null) {
      final photoList = result['photos'] as List;
      for (final photo in photoList.take(5)) {
        final photoRef = photo['photo_reference'];
        final photoUrl =
            'https://maps.googleapis.com/maps/api/place/photo?'
            'maxwidth=400&photoreference=$photoRef'
            '&key=${Platform.isAndroid ? ApiConstants.googleMapAndroidApikey : ApiConstants.googleMapIOSApikey}';
        photos.add(photoUrl);
      }
    }

    // Extract opening hours
    String? openingHoursText;
    if (result['opening_hours'] != null &&
        result['opening_hours']['weekday_text'] != null) {
      openingHoursText = (result['opening_hours']['weekday_text'] as List).join(
        '\n',
      );
    }

    // Extract reviews
    final reviews = <Review>[];
    if (result['reviews'] != null) {
      final reviewList = result['reviews'] as List;
      for (final review in reviewList.take(10)) {
        reviews.add(Review.fromJson(review));
      }
    }

    final types = List<String>.from(result['types'] ?? []);

    return GooglePlaceDetails(
      name: result['name'] ?? 'Unknown Place',
      address: result['formatted_address'],
      location: LatLng(geometry['lat'], geometry['lng']),
      phoneNumber: result['formatted_phone_number'],
      internationalPhoneNumber: result['international_phone_number'],
      website: result['website'],
      rating: result['rating'] != null
          ? double.parse(result['rating'].toString())
          : null,
      totalRatings: result['user_ratings_total'],
      photos: photos,
      placeId: result['place_id'],
      category: _getPrimaryCategory(types),
      isOpen: result['opening_hours']?['open_now'] ?? false,
      openingHours: openingHoursText,
      types: types,
      priceLevel: result['price_level'],
      reviews: reviews.isNotEmpty ? reviews : null,
      businessStatus: result['business_status'],
      formattedPhoneNumber: result['formatted_phone_number'],
    );
  }

  static String? _getPrimaryCategory(List<String> types) {
    const categoryPriority = [
      'restaurant',
      'cafe',
      'bar',
      'hotel',
      'store',
      'park',
      'museum',
      'hospital',
      'school',
      'gas_station',
      'bank',
      'pharmacy',
      'gym',
    ];

    for (final category in categoryPriority) {
      if (types.contains(category)) {
        return category;
      }
    }

    return types.isNotEmpty ? types.first : 'establishment';
  }
}





class Review {
  final String authorName;
  final double rating;
  final String text;
  final DateTime time;
  final String? profilePhotoUrl;
  final String? relativeTimeDescription;

  Review({
    required this.authorName,
    required this.rating,
    required this.text,
    required this.time,
    this.profilePhotoUrl,
    this.relativeTimeDescription,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      authorName: json['author_name'],
      rating: json['rating']?.toDouble() ?? 0.0,
      text: json['text'] ?? '',
      time: DateTime.fromMillisecondsSinceEpoch(json['time'] * 1000),
      profilePhotoUrl: json['profile_photo_url'],
      relativeTimeDescription: json['relative_time_description'],
    );
  }
}

class SearchFilters {
  final bool openNow;
  final double minRating;
  final String? priceRange;
  final String? type;
  final String? keyword;
  final int radius;

  SearchFilters({
    this.openNow = false,
    this.minRating = 0.0,
    this.priceRange,
    this.type,
    this.keyword,
    this.radius = 5000,
  });

  Map<String, dynamic> toJson() {
    return {
      'openNow': openNow,
      'minRating': minRating,
      'priceRange': priceRange,
      'type': type,
      'keyword': keyword,
      'radius': radius,
    };
  }
}
