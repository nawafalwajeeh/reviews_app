// lib/features/review/services/google_places_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:uuid/uuid.dart';
import '../../../features/review/models/google_search_suggestions.dart';
import '../../../features/review/models/search_suggestion.dart';
import '../../../utils/constants/api_constants.dart';
import '../../../utils/logging/logger.dart';

// --- MAIN GOOGLE PLACES SERVICE ---
class GooglePlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static final http.Client _client = http.Client();
  static final Uuid _uuid = const Uuid();

  /// Get API key based on platform
  static String get _apiKey => Platform.isAndroid
      ? ApiConstants.googleMapAndroidApikey
      : ApiConstants.googleMapIOSApikey;

  /// Enhanced search with global support
  static Future<List<SearchSuggestion>> searchPlaces(
    String query, {
    LatLng? location,
    String? country,
    String? language = 'en',
  }) async {
    try {
      if (query.isEmpty) {
        return _getDefaultSuggestions();
      }

      final params = {
        'input': query,
        'key': Platform.isAndroid
            ? ApiConstants.googleMapAndroidApikey
            : ApiConstants.googleMapIOSApikey,
        'language': language,
        'types': 'establishment|geocode',
      };

      // Add location bias for better results
      if (location != null) {
        params['location'] = '${location.latitude},${location.longitude}';
        params['radius'] = '50000';
      }

      // Country restriction if provided
      if (country != null) {
        params['components'] = 'country:$country';
      }

      final uri = Uri.parse(
        '$_baseUrl/autocomplete/json',
      ).replace(queryParameters: params);
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          final suggestions = <SearchSuggestion>[];

          for (final prediction in predictions) {
            suggestions.add(
              SearchSuggestion(
                id: prediction['place_id'] ?? const Uuid().v4(),
                title: prediction['description'],
                subtitle: _extractSubtitle(prediction),
                type: 'place',
                placeId: prediction['place_id'],
                icon: _getPlaceIcon(prediction['types']),
                location: null, // Will be fetched in details
              ),
            );
          }
          return suggestions;
        } else {
          throw Exception('Places API error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      AppLoggerHelper.error('Places search error: $e');
      return await _fallbackGeocodingSearch(query);
    }
  }

  /// Extract subtitle from prediction
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

  /// Get default suggestions
  static List<SearchSuggestion> _getDefaultSuggestions() {
    return [
      SearchSuggestion(
        id: 'current_location',
        title: 'Your Current Location',
        subtitle: 'Based on your device location',
        type: 'current_location',
        icon: 'my_location',
      ),
    ];
  }

  /// Fallback search using geocoding
  static Future<List<SearchSuggestion>> _fallbackGeocodingSearch(
    String query,
  ) async {
    try {
      return await geocodeAddress(query);
    } catch (e) {
      AppLoggerHelper.error('Fallback search error: $e');
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
        final addressComponents =
            [
                  place.street,
                  place.subLocality,
                  place.locality,
                  place.administrativeArea,
                  place.postalCode,
                  place.country,
                ]
                .where((component) => component != null && component.isNotEmpty)
                .toList();

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
  static Future<Map<String, dynamic>?> getDetailedAddressFromLatLng(
    LatLng location,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // Build full address
        final fullAddress =
            [
                  place.street,
                  place.locality,
                  place.administrativeArea,
                  place.country,
                ]
                .where((component) => component != null && component.isNotEmpty)
                .join(', ');

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
          'fullAddress': fullAddress.isNotEmpty
              ? fullAddress
              : '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
        };
      }

      return {
        'fullAddress':
            '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
        'street': '',
        'locality': '',
        'country': '',
      };
    } catch (e) {
      AppLoggerHelper.error('Detailed reverse geocoding error: $e');
      return {
        'fullAddress':
            '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
        'street': '',
        'locality': '',
        'country': '',
      };
    }
  }

  /// Forward geocoding to get coordinates from address
  static Future<List<SearchSuggestion>> geocodeAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      final suggestions = <SearchSuggestion>[];

      for (int i = 0; i < locations.length; i++) {
        final location = locations[i];
        final placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        String addressName = address;
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          addressName = '${place.street ?? ''}, ${place.locality ?? ''}'
              .replaceAll(RegExp(r'^,\s*|\s*,?\s*$'), '');
        }

        suggestions.add(
          SearchSuggestion(
            id: 'geocode_$i',
            title: addressName,
            subtitle: 'Address',
            location: LatLng(location.latitude, location.longitude),
            type: 'address',
            icon: 'location',
          ),
        );
      }

      return suggestions;
    } catch (e) {
      AppLoggerHelper.error('Geocoding error: $e');
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
        final shortAddress = [place.street, place.locality]
            .where((component) => component != null && component.isNotEmpty)
            .join(', ');

        return shortAddress.isNotEmpty ? shortAddress : place.country;
      }
      return null;
    } catch (e) {
      AppLoggerHelper.error('Short address geocoding error: $e');
      return null;
    }
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
        'fields':
            'name,formatted_address,geometry,formatted_phone_number,'
            'international_phone_number,website,rating,user_ratings_total,'
            'photo,opening_hours,type,price_level,review,business_status,'
            'address_component,plus_code,url,utc_offset,vicinity',
      };

      final uri = Uri.parse(
        '$_baseUrl/details/json',
      ).replace(queryParameters: params);
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return GooglePlaceDetails.fromJson(data);
        } else {
          AppLoggerHelper.warning(
            'Google Places Details status: ${data['status']}',
          );
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

      final uri = Uri.parse(
        '$_baseUrl/nearbysearch/json',
      ).replace(queryParameters: params);
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          return results
              .take(limit)
              .map(
                (result) =>
                    GooglePlaceSuggestion.fromNearbySearch(result, location),
              )
              .toList();
        } else {
          AppLoggerHelper.warning(
            'Google Places Nearby status: ${data['status']}',
          );
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
      final params = {'query': query, 'key': _apiKey, 'language': language};

      // Add location bias
      if (location != null) {
        params['location'] = '${location.latitude},${location.longitude}';
        params['radius'] = (filters?.radius ?? 5000).toString();
      }

      // Add type filter
      if (type != null && type.isNotEmpty) {
        params['type'] = type;
      }

      final uri = Uri.parse(
        '$_baseUrl/textsearch/json',
      ).replace(queryParameters: params);
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          return results
              .take(limit)
              .map(
                (result) => GooglePlaceSuggestion.fromNearbySearch(
                  result,
                  location ?? const LatLng(0, 0),
                ),
              )
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
        params['locationbias'] =
            'circle:5000@${location.latitude},${location.longitude}';
      }

      final uri = Uri.parse(
        '$_baseUrl/findplacefromtext/json',
      ).replace(queryParameters: params);
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
              category: _getPrimaryCategory(
                List<String>.from(candidate['types'] ?? []),
              ),
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

      final uri = Uri.parse(
        '$_baseUrl/nearbysearch/json',
      ).replace(queryParameters: params);
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          return results
              .take(10) // Limit to top 10 popular places
              .map(
                (result) =>
                    GooglePlaceSuggestion.fromNearbySearch(result, location),
              )
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

      final uri = Uri.parse(
        '$_baseUrl/autocomplete/json',
      ).replace(queryParameters: params);
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions
              .map(
                (prediction) =>
                    GooglePlaceSuggestion.fromAutocomplete(prediction),
              )
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
    if (types.contains('restaurant') || types.contains('food')) {
      return 'restaurant';
    }
    if (types.contains('cafe')) return 'local_cafe';
    if (types.contains('bar') || types.contains('night_club')) {
      return 'local_bar';
    }
    if (types.contains('hotel') || types.contains('lodging')) return 'hotel';
    if (types.contains('store') || types.contains('shopping_mall')) {
      return 'store';
    }
    if (types.contains('park') || types.contains('amusement_park')) {
      return 'park';
    }
    if (types.contains('museum') || types.contains('art_gallery')) {
      return 'museum';
    }
    if (types.contains('hospital') || types.contains('health')) {
      return 'local_hospital';
    }
    if (types.contains('school') || types.contains('university')) {
      return 'school';
    }
    if (types.contains('gas_station')) return 'local_gas_station';
    if (types.contains('bank') || types.contains('atm')) {
      return 'account_balance';
    }
    return 'place';
  }

  // Helper method to get primary category
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
      'atm',
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
        final addressComponents =
            [
                  place.street,
                  place.locality,
                  place.administrativeArea,
                  place.country,
                ]
                .where((component) => component != null && component.isNotEmpty)
                .toList();

        return addressComponents.join(', ');
      }
      return null;
    } catch (e) {
      AppLoggerHelper.error('Reverse geocoding error: $e');
      return null;
    }
  }

  /// Get coordinates from address (forward geocoding)
  static Future<List<GooglePlaceSuggestion>> geocodeAddress(
    String address,
  ) async {
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
          addressName =
              [
                    place.street,
                    place.locality,
                    place.administrativeArea,
                    place.country,
                  ]
                  .where(
                    (component) => component != null && component.isNotEmpty,
                  )
                  .join(', ');
        }

        suggestions.add(
          GooglePlaceSuggestion(
            id: 'geocode_$i',
            title: addressName,
            subtitle: 'Address',
            location: LatLng(location.latitude, location.longitude),
            type: 'address',
            icon: 'location',
          ),
        );
      }

      return suggestions;
    } catch (e) {
      AppLoggerHelper.error('Forward geocoding error: $e');
      return [];
    }
  }

  /// Get detailed address information from coordinates
  static Future<Map<String, dynamic>?> getDetailedAddressFromLatLng(
    LatLng location,
  ) async {
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
          'fullAddress':
              [
                    place.street,
                    place.locality,
                    place.administrativeArea,
                    place.postalCode,
                    place.country,
                  ]
                  .where(
                    (component) => component != null && component.isNotEmpty,
                  )
                  .join(', '),
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
        AppLoggerHelper.error(
          'Google Places API request denied: $errorMessage',
        );
        break;
      case 'INVALID_REQUEST':
        AppLoggerHelper.error(
          'Invalid Google Places API request: $errorMessage',
        );
        break;
      case 'UNKNOWN_ERROR':
        AppLoggerHelper.error('Unknown Google Places API error');
        break;
      default:
        AppLoggerHelper.error(
          'Google Places API error: $status - $errorMessage',
        );
    }
  }
}
