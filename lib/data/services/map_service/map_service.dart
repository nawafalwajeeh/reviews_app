// lib/features/review/services/google_places_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:uuid/uuid.dart';

import '../../../utils/constants/api_constants.dart';
import '../../../utils/logging/logger.dart';

// --- PLACE MODELS ---
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

  factory GooglePlaceSuggestion.fromAutocomplete(Map<String, dynamic> prediction) {
    final types = List<String>.from(prediction['types'] ?? []);
    final isEstablishment = types.any((type) => 
        type.contains('establishment') || 
        type.contains('point_of_interest'));

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

  factory GooglePlaceSuggestion.fromNearbySearch(Map<String, dynamic> result, LatLng userLocation) {
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
    if (types.contains('restaurant') || types.contains('food')) return 'restaurant';
    if (types.contains('cafe') || types.contains('coffee')) return 'local_cafe';
    if (types.contains('bar') || types.contains('night_club')) return 'local_bar';
    if (types.contains('hotel') || types.contains('lodging')) return 'hotel';
    if (types.contains('store') || types.contains('shopping_mall') || types.contains('clothing_store')) return 'store';
    if (types.contains('park') || types.contains('amusement_park')) return 'park';
    if (types.contains('museum') || types.contains('art_gallery')) return 'museum';
    if (types.contains('hospital') || types.contains('health') || types.contains('doctor')) return 'local_hospital';
    if (types.contains('school') || types.contains('university') || types.contains('college')) return 'school';
    if (types.contains('gas_station') || types.contains('car_wash')) return 'local_gas_station';
    if (types.contains('bank') || types.contains('atm') || types.contains('finance')) return 'account_balance';
    if (types.contains('pharmacy') || types.contains('drugstore')) return 'local_pharmacy';
    if (types.contains('gym') || types.contains('health_club')) return 'fitness_center';
    if (types.contains('movie_theater') || types.contains('cinema')) return 'movie';
    if (types.contains('library')) return 'local_library';
    if (types.contains('post_office')) return 'local_post_office';
    if (types.contains('police')) return 'local_police';
    if (types.contains('fire_station')) return 'local_fire_department';
    return 'place';
  }

  static String? _getPrimaryCategory(List<String> types) {
    // Priority order for categories
    const categoryPriority = [
      'restaurant', 'cafe', 'bar', 'hotel', 'store', 'park', 'museum',
      'hospital', 'school', 'gas_station', 'bank', 'pharmacy', 'gym',
      'movie_theater', 'library'
    ];

    for (final category in categoryPriority) {
      if (types.contains(category)) {
        return category;
      }
    }

    return types.isNotEmpty ? types.first : 'establishment';
  }

  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0; // Earth's radius in meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
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
        final photoUrl = 'https://maps.googleapis.com/maps/api/place/photo?'
            'maxwidth=400&photoreference=$photoRef'
            '&key=${Platform.isAndroid ? ApiConstants.googleMapAndroidApikey : ApiConstants.googleMapIOSApikey}';
        photos.add(photoUrl);
      }
    }

    // Extract opening hours
    String? openingHoursText;
    if (result['opening_hours'] != null && result['opening_hours']['weekday_text'] != null) {
      openingHoursText = (result['opening_hours']['weekday_text'] as List).join('\n');
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
      rating: result['rating'] != null ? double.parse(result['rating'].toString()) : null,
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
      'restaurant', 'cafe', 'bar', 'hotel', 'store', 'park', 'museum',
      'hospital', 'school', 'gas_station', 'bank', 'pharmacy', 'gym'
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

// --- MAIN GOOGLE PLACES SERVICE ---
class GooglePlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static final http.Client _client = http.Client();
  static final Uuid _uuid = const Uuid();

  /// Get API key based on platform
  static String get _apiKey => Platform.isAndroid
      ? ApiConstants.googleMapAndroidApikey
      : ApiConstants.googleMapIOSApikey;

  /// Search places using Google Places Autocomplete
  static Future<List<GooglePlaceSuggestion>> searchPlaces(
    String query, {
    LatLng? location,
    String? type,
    SearchFilters? filters,
    String language = 'en',
  }) async {
    try {
      if (query.isEmpty) return [];

      final params = {
        'input': query,
        'key': _apiKey,
        'language': language,
      };

      // Add location bias if available
      if (location != null) {
        params['location'] = '${location.latitude},${location.longitude}';
        params['radius'] = (filters?.radius ?? 5000).toString();
      }

      // Add type filter if specified
      if (type != null && type.isNotEmpty) {
        params['types'] = type;
      } else {
        params['types'] = 'establishment|geocode';
      }

      final uri = Uri.parse('$_baseUrl/autocomplete/json').replace(queryParameters: params);
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions
              .map((prediction) => GooglePlaceSuggestion.fromAutocomplete(prediction))
              .toList();
        } else {
          AppLoggerHelper.warning('Google Places Autocomplete status: ${data['status']}');
        }
      } else {
        AppLoggerHelper.error('HTTP error: ${response.statusCode}');
      }
      
      return [];
    } catch (e) {
      AppLoggerHelper.error('Google Places search error: $e');
      return [];
    }
  }

  

   /// Get address from coordinates using reverse geocoding
  static Future<String?> getAddressFromLatLng(LatLng location) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        
        // Build address components
        final addressComponents = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode,
          place.country,
        ].where((component) => component != null && component!.isNotEmpty).toList();

        if (addressComponents.isNotEmpty) {
          return addressComponents.join(', ');
        }
      }
      
      // Fallback: Return coordinates if no address found
      return '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
    } catch (e) {
      AppLoggerHelper.error('Reverse geocoding error: $e');
      
      // Fallback: Return coordinates
      return '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
    }
  }

  /// Enhanced reverse geocoding with detailed address components
  static Future<Map<String, dynamic>?> getDetailedAddressFromLatLng(LatLng location) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        
        // Build full address
        final fullAddress = [
          place.street,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((component) => component != null && component!.isNotEmpty).join(', ');

        return {
          'street': place.street ?? '',
          'locality': place.locality ?? '',
          'subLocality': place.subLocality ?? '',
          'administrativeArea': place.administrativeArea ?? '',
          'postalCode': place.postalCode ?? '',
          'country': place.country ?? '',
          'isoCountryCode': place.isoCountryCode ?? '',
          'thoroughfare': place.thoroughfare ?? '',
          'subThoroughfare': place.subThoroughfare ?? '',
          'fullAddress': fullAddress.isNotEmpty ? fullAddress : '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
        };
      }
      
      return {
        'fullAddress': '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
        'street': '',
        'locality': '',
        'country': '',
      };
    } catch (e) {
      AppLoggerHelper.error('Detailed reverse geocoding error: $e');
      return {
        'fullAddress': '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
        'street': '',
        'locality': '',
        'country': '',
      };
    }
  }

  /// Get coordinates from address (forward geocoding)
  static Future<List<GooglePlaceSuggestion>> geocodeAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      final suggestions = <GooglePlaceSuggestion>[];

      for (int i = 0; i < locations.length; i++) {
        final location = locations[i];
        final placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        String addressName = address;
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          addressName = [
            place.street,
            place.locality,
            place.administrativeArea,
            place.country,
          ].where((component) => component != null && component!.isNotEmpty).join(', ');
        }

        suggestions.add(GooglePlaceSuggestion(
          id: 'geocode_$i',
          title: addressName,
          subtitle: 'Address',
          location: LatLng(location.latitude, location.longitude),
          type: 'address',
          icon: 'location',
        ));
      }

      return suggestions;
    } catch (e) {
      AppLoggerHelper.error('Forward geocoding error: $e');
      return [];
    }
  }

  /// Get short address (street + city) from coordinates
  static Future<String?> getShortAddressFromLatLng(LatLng location) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final shortAddress = [
          place.street,
          place.locality,
        ].where((component) => component != null && component!.isNotEmpty).join(', ');

        return shortAddress.isNotEmpty ? shortAddress : place.country;
      }
      return null;
    } catch (e) {
      AppLoggerHelper.error('Short address geocoding error: $e');
      return null;
    }
  }

  /// Batch geocode multiple addresses
  static Future<List<GooglePlaceSuggestion>> batchGeocodeAddresses(List<String> addresses) async {
    final allSuggestions = <GooglePlaceSuggestion>[];
    
    for (final address in addresses) {
      try {
        final suggestions = await geocodeAddress(address);
        allSuggestions.addAll(suggestions);
        
        // Add small delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        AppLoggerHelper.error('Batch geocoding error for address $address: $e');
      }
    }
    
    return allSuggestions;
  }

  /// Validate if an address exists
  static Future<bool> validateAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      return locations.isNotEmpty;
    } catch (e) {
      AppLoggerHelper.error('Address validation error: $e');
      return false;
    }
  }


  /// Get detailed place information
  static Future<GooglePlaceDetails?> getPlaceDetails(
    String placeId, {
    String language = 'en',
  }) async {
    try {
      final params = {
        'place_id': placeId,
        'key': _apiKey,
        'language': language,
        'fields': 'name,formatted_address,geometry,formatted_phone_number,'
            'international_phone_number,website,rating,user_ratings_total,'
            'photo,opening_hours,type,price_level,review,business_status,'
            'address_component,plus_code,url,utc_offset,vicinity',
      };

      final uri = Uri.parse('$_baseUrl/details/json').replace(queryParameters: params);
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return GooglePlaceDetails.fromJson(data);
        } else {
          AppLoggerHelper.warning('Google Places Details status: ${data['status']}');
        }
      }
      
      return null;
    } catch (e) {
      AppLoggerHelper.error('Google Places details error: $e');
      return null;
    }
  }

  /// Search for nearby places
  static Future<List<GooglePlaceSuggestion>> getNearbyPlaces({
    required LatLng location,
    String? type,
    String? keyword,
    SearchFilters? filters,
    String language = 'en',
    int limit = 20,
  }) async {
    try {
      final params = {
        'location': '${location.latitude},${location.longitude}',
        'key': _apiKey,
        'language': language,
        'radius': (filters?.radius ?? 5000).toString(),
      };

      // Add type filter
      if (type != null && type.isNotEmpty) {
        params['type'] = type;
      }

      // Add keyword search
      if (keyword != null && keyword.isNotEmpty) {
        params['keyword'] = keyword;
      }

      // Add open now filter
      if (filters?.openNow == true) {
        params['opennow'] = 'true';
      }

      // Add minimum rating (approximate using price level)
      if (filters?.minRating != null && filters!.minRating > 0) {
        params['minprice'] = filters.minRating.round().toString();
      }

      final uri = Uri.parse('$_baseUrl/nearbysearch/json').replace(queryParameters: params);
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          return results
              .take(limit)
              .map((result) => GooglePlaceSuggestion.fromNearbySearch(result, location))
              .toList();
        } else {
          AppLoggerHelper.warning('Google Places Nearby status: ${data['status']}');
        }
      }
      
      return [];
    } catch (e) {
      AppLoggerHelper.error('Google Places nearby search error: $e');
      return [];
    }
  }

  /// Text search for places
  static Future<List<GooglePlaceSuggestion>> textSearch(
    String query, {
    LatLng? location,
    String? type,
    SearchFilters? filters,
    String language = 'en',
    int limit = 20,
  }) async {
    try {
      final params = {
        'query': query,
        'key': _apiKey,
        'language': language,
      };

      // Add location bias
      if (location != null) {
        params['location'] = '${location.latitude},${location.longitude}';
        params['radius'] = (filters?.radius ?? 5000).toString();
      }

      // Add type filter
      if (type != null && type.isNotEmpty) {
        params['type'] = type;
      }

      final uri = Uri.parse('$_baseUrl/textsearch/json').replace(queryParameters: params);
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          return results
              .take(limit)
              .map((result) => GooglePlaceSuggestion.fromNearbySearch(result, location ?? const LatLng(0, 0)))
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      AppLoggerHelper.error('Google Places text search error: $e');
      return [];
    }
  }

  /// Get place photo URL
  static String getPlacePhotoUrl(String photoReference, {int maxWidth = 400}) {
    return '$_baseUrl/photo?maxwidth=$maxWidth&photoreference=$photoReference&key=$_apiKey';
  }

  /// Find place from text (more accurate than autocomplete)
  static Future<List<GooglePlaceSuggestion>> findPlaceFromText(
    String query, {
    LatLng? location,
    String language = 'en',
  }) async {
    try {
      final params = {
        'input': query,
        'inputtype': 'textquery',
        'key': _apiKey,
        'language': language,
        'fields': 'name,formatted_address,geometry,place_id,types',
      };

      // Add location bias
      if (location != null) {
        params['locationbias'] = 'circle:5000@${location.latitude},${location.longitude}';
      }

      final uri = Uri.parse('$_baseUrl/findplacefromtext/json').replace(queryParameters: params);
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final candidates = data['candidates'] as List;
          return candidates.map((candidate) {
            final geometry = candidate['geometry']['location'];
            return GooglePlaceSuggestion(
              id: candidate['place_id'] ?? _uuid.v4(),
              title: candidate['name'],
              subtitle: candidate['formatted_address'],
              location: LatLng(geometry['lat'], geometry['lng']),
              type: 'place',
              placeId: candidate['place_id'],
              icon: _getPlaceIcon(List<String>.from(candidate['types'] ?? [])),
              category: _getPrimaryCategory(List<String>.from(candidate['types'] ?? [])),
            );
          }).toList();
        }
      }
      
      return [];
    } catch (e) {
      AppLoggerHelper.error('Google Places find from text error: $e');
      return [];
    }
  }

  /// Get popular places by type in an area
  static Future<List<GooglePlaceSuggestion>> getPopularPlaces({
    required LatLng location,
    required String type,
    int radius = 10000,
    String language = 'en',
  }) async {
    try {
      final params = {
        'location': '${location.latitude},${location.longitude}',
        'type': type,
        'key': _apiKey,
        'language': language,
        'radius': radius.toString(),
        'rankby': 'prominence', // Use prominence for popular places
      };

      final uri = Uri.parse('$_baseUrl/nearbysearch/json').replace(queryParameters: params);
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          return results
              .take(10) // Limit to top 10 popular places
              .map((result) => GooglePlaceSuggestion.fromNearbySearch(result, location))
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      AppLoggerHelper.error('Google Places popular places error: $e');
      return [];
    }
  }

  /// Get place predictions with more details
  static Future<List<GooglePlaceSuggestion>> getPlacePredictions(
    String query, {
    LatLng? location,
    String? sessionToken,
    String language = 'en',
  }) async {
    try {
      final params = {
        'input': query,
        'key': _apiKey,
        'language': language,
        'types': 'establishment',
      };

      if (location != null) {
        params['location'] = '${location.latitude},${location.longitude}';
        params['radius'] = '50000';
      }

      if (sessionToken != null) {
        params['sessiontoken'] = sessionToken;
      }

      final uri = Uri.parse('$_baseUrl/autocomplete/json').replace(queryParameters: params);
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions
              .map((prediction) => GooglePlaceSuggestion.fromAutocomplete(prediction))
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      AppLoggerHelper.error('Google Places predictions error: $e');
      return [];
    }
  }

  // Helper method to get place icon
  static String _getPlaceIcon(List<String> types) {
    if (types.contains('restaurant') || types.contains('food')) return 'restaurant';
    if (types.contains('cafe')) return 'local_cafe';
    if (types.contains('bar') || types.contains('night_club')) return 'local_bar';
    if (types.contains('hotel') || types.contains('lodging')) return 'hotel';
    if (types.contains('store') || types.contains('shopping_mall')) return 'store';
    if (types.contains('park') || types.contains('amusement_park')) return 'park';
    if (types.contains('museum') || types.contains('art_gallery')) return 'museum';
    if (types.contains('hospital') || types.contains('health')) return 'local_hospital';
    if (types.contains('school') || types.contains('university')) return 'school';
    if (types.contains('gas_station')) return 'local_gas_station';
    if (types.contains('bank') || types.contains('atm')) return 'account_balance';
    return 'place';
  }

  // Helper method to get primary category
  static String? _getPrimaryCategory(List<String> types) {
    const categoryPriority = [
      'restaurant', 'cafe', 'bar', 'hotel', 'store', 'park', 'museum',
      'hospital', 'school', 'gas_station', 'bank', 'atm'
    ];

    for (final category in categoryPriority) {
      if (types.contains(category)) {
        return category;
      }
    }

    return types.isNotEmpty ? types.first : null;
  }
}

// --- GEOCODING EXTENSIONS ---
extension GeocodingExtension on GooglePlacesService {
  /// Get address from coordinates (reverse geocoding)
  static Future<String?> getAddressFromLatLng(LatLng location) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final addressComponents = [
          place.street,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((component) => component != null && component.isNotEmpty).toList();

        return addressComponents.join(', ');
      }
      return null;
    } catch (e) {
      AppLoggerHelper.error('Reverse geocoding error: $e');
      return null;
    }
  }

  /// Get coordinates from address (forward geocoding)
  static Future<List<GooglePlaceSuggestion>> geocodeAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      final suggestions = <GooglePlaceSuggestion>[];

      for (int i = 0; i < locations.length; i++) {
        final location = locations[i];
        final placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        String addressName = address;
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          addressName = [
            place.street,
            place.locality,
            place.administrativeArea,
            place.country,
          ].where((component) => component != null && component.isNotEmpty).join(', ');
        }

        suggestions.add(GooglePlaceSuggestion(
          id: 'geocode_$i',
          title: addressName,
          subtitle: 'Address',
          location: LatLng(location.latitude, location.longitude),
          type: 'address',
          icon: 'location',
        ));
      }

      return suggestions;
    } catch (e) {
      AppLoggerHelper.error('Forward geocoding error: $e');
      return [];
    }
  }

  /// Get detailed address information from coordinates
  static Future<Map<String, dynamic>?> getDetailedAddressFromLatLng(LatLng location) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return {
          'street': place.street,
          'locality': place.locality,
          'administrativeArea': place.administrativeArea,
          'postalCode': place.postalCode,
          'country': place.country,
          'isoCountryCode': place.isoCountryCode,
          'fullAddress': [
            place.street,
            place.locality,
            place.administrativeArea,
            place.postalCode,
            place.country,
          ].where((component) => component != null && component.isNotEmpty).join(', '),
        };
      }
      return null;
    } catch (e) {
      AppLoggerHelper.error('Detailed reverse geocoding error: $e');
      return null;
    }
  }
}

// --- ERROR HANDLING ---
class GooglePlacesException implements Exception {
  final String message;
  final String status;

  GooglePlacesException(this.message, this.status);

  @override
  String toString() => 'GooglePlacesException: $message (Status: $status)';
}

class GooglePlacesErrorHandler {
  static void handleError(String status, String? errorMessage) {
    switch (status) {
      case 'ZERO_RESULTS':
        AppLoggerHelper.info('No results found for the query');
        break;
      case 'OVER_QUERY_LIMIT':
        AppLoggerHelper.warning('Google Places API quota exceeded');
        break;
      case 'REQUEST_DENIED':
        AppLoggerHelper.error('Google Places API request denied: $errorMessage');
        break;
      case 'INVALID_REQUEST':
        AppLoggerHelper.error('Invalid Google Places API request: $errorMessage');
        break;
      case 'UNKNOWN_ERROR':
        AppLoggerHelper.error('Unknown Google Places API error');
        break;
      default:
        AppLoggerHelper.error('Google Places API error: $status - $errorMessage');
    }
  }
}


//-------------------------
// import 'dart:convert';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:reviews_app/features/review/controllers/map_controller.dart';
// import 'package:uuid/uuid.dart';

// class GooglePlacesService {
//   static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
//   static final http.Client _client = http.Client();

//   // Search places with filters
//   static Future<List<SearchSuggestion>> searchPlaces(
//     String query, {
//     LatLng? location,
//     MapFilter? filter,
//   }) async {
//     try {
//       final params = {
//         'input': query,
//         'key': 'YOUR_GOOGLE_API_KEY',
//         'types': 'establishment|geocode',
//         'language': 'en',
//       };

//       if (location != null) {
//         params['location'] = '${location.latitude},${location.longitude}';
//         params['radius'] = '50000';
//       }

//       if (filter != null && filter.category != 'all') {
//         params['type'] = filter.category;
//       }

//       final uri = Uri.parse('$_baseUrl/autocomplete/json').replace(queryParameters: params);
//       final response = await _client.get(uri);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == 'OK') {
//           return _parsePredictions(data['predictions']);
//         }
//       }
//       return [];
//     } catch (e) {
//       print('Places search error: $e');
//       return await _fallbackGeocodingSearch(query);
//     }
//   }

//   // Search nearby places
//   static Future<List<PlaceDetails>> searchNearbyPlaces(
//     LatLng location, {
//     required String category,
//     double radius = 5000.0,
//   }) async {
//     try {
//       final params = {
//         'location': '${location.latitude},${location.longitude}',
//         'radius': radius.toString(),
//         'key': 'YOUR_GOOGLE_API_KEY',
//         'type': category,
//       };

//       final uri = Uri.parse('$_baseUrl/nearbysearch/json').replace(queryParameters: params);
//       final response = await _client.get(uri);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == 'OK') {
//           return await _parseNearbyResults(data['results']);
//         }
//       }
//       return [];
//     } catch (e) {
//       print('Nearby search error: $e');
//       return [];
//     }
//   }

//   // Get directions
//   static Future<Direction?> getDirections(LatLng origin, LatLng destination) async {
//     try {
//       final params = {
//         'origin': '${origin.latitude},${origin.longitude}',
//         'destination': '${destination.latitude},${destination.longitude}',
//         'key': 'YOUR_GOOGLE_API_KEY',
//         'mode': 'driving',
//       };

//       final uri = Uri.parse('https://maps.googleapis.com/maps/api/directions/json')
//           .replace(queryParameters: params);
//       final response = await _client.get(uri);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == 'OK') {
//           return _parseDirection(data);
//         }
//       }
//       return null;
//     } catch (e) {
//       print('Directions error: $e');
//       return null;
//     }
//   }

//   // Parse methods would go here...
//   static List<SearchSuggestion> _parsePredictions(List predictions) {
//     return predictions.map((prediction) {
//       return SearchSuggestion(
//         id: prediction['place_id'] ?? const Uuid().v4(),
//         title: prediction['description'],
//         type: 'place',
//         placeId: prediction['place_id'],
//       );
//     }).toList();
//   }

//   static Future<List<PlaceDetails>> _parseNearbyResults(List results) async {
//     final places = <PlaceDetails>[];
    
//     for (final result in results) {
//       final geometry = result['geometry']['location'];
//       places.add(PlaceDetails(
//         name: result['name'] ?? 'Unknown Place',
//         address: result['vicinity'],
//         location: LatLng(geometry['lat'], geometry['lng']),
//         rating: result['rating']?.toDouble(),
//         totalRatings: result['user_ratings_total'],
//         placeId: result['place_id'],
//         types: List<String>.from(result['types'] ?? []),
//         businessStatus: result['business_status'],
//         priceLevel: result['price_level'],
//       ));
//     }
    
//     return places;
//   }

//   static Direction _parseDirection(Map<String, dynamic> data) {
//     final route = data['routes'][0];
//     final leg = route['legs'][0];
    
//     final points = _decodePolyline(route['overview_polyline']['points']);
    
//     return Direction(
//       polylinePoints: points,
//       distance: leg['distance']['text'],
//       duration: leg['duration']['text'],
//       instructions: leg['steps'][0]['html_instructions'],
//       travelMode: 'driving',
//     );
//   }

//   static List<LatLng> _decodePolyline(String encoded) {
//     // Polyline decoding logic
//     return [];
//   }

//   static Future<List<SearchSuggestion>> _fallbackGeocodingSearch(String query) async {
//     try {
//       final locations = await locationFromAddress(query);
//       return locations.map((location) {
//         return SearchSuggestion(
//           id: const Uuid().v4(),
//           title: query,
//           location: LatLng(location.latitude, location.longitude),
//           type: 'address',
//         );
//       }).toList();
//     } catch (e) {
//       return [];
//     }
//   }

//   // Existing methods...
//   static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
//     // Implementation
//     return null;
//   }

//   static Future<String?> getAddressFromLatLng(LatLng location) async {
//     // Implementation
//     return null;
//   }
// }