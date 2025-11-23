import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../utils/constants/api_constants.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/logging/logger.dart';
import '../../personalization/models/address_model.dart';

// --- ENHANCED SEARCH & UI MODELS ---

class MapCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<MapCategory>? subCategories;

  MapCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.color = AppColors.primaryColor,
    this.subCategories,
  });
}

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

class ContributionProgress {
  final int points;
  final int level;
  final int pointsToNextLevel;
  final List<ContributionTask> tasks;

  ContributionProgress({
    required this.points,
    required this.level,
    required this.pointsToNextLevel,
    required this.tasks,
  });
}

class ContributionTask {
  final String id;
  final String title;
  final int current;
  final int target;
  final IconData icon;

  ContributionTask({
    required this.id,
    required this.title,
    required this.current,
    required this.target,
    required this.icon,
  });
}

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

class PlaceDetails {
  final String name;
  final String? address;
  final LatLng location;
  final String? phoneNumber;
  final String? website;
  final double? rating;
  final int? totalRatings;
  final List<String>? photos;
  final String? placeId;

  PlaceDetails({
    required this.name,
    this.address,
    required this.location,
    this.phoneNumber,
    this.website,
    this.rating,
    this.totalRatings,
    this.photos,
    this.placeId,
  });
}

// Enhanced Google Places Service
class GooglePlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static final http.Client _client = http.Client();

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

  /// Get place details using Google Places Details API
  static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final params = {
        'place_id': placeId,
        'key': Platform.isAndroid
            ? ApiConstants.googleMapAndroidApikey
            : ApiConstants.googleMapIOSApikey,
        'fields':
            'name,formatted_address,geometry,international_phone_number,website,rating,user_ratings_total,photo',
      };

      final uri = Uri.parse(
        '$_baseUrl/details/json',
      ).replace(queryParameters: params);
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];
          final geometry = result['geometry']['location'];

          return PlaceDetails(
            name: result['name'] ?? 'Unknown Place',
            address: result['formatted_address'],
            location: LatLng(geometry['lat'], geometry['lng']),
            phoneNumber: result['international_phone_number'],
            website: result['website'],
            rating: result['rating'] != null
                ? double.parse(result['rating'].toString())
                : null,
            totalRatings: result['user_ratings_total'],
            placeId: placeId,
          );
        }
      }
      return null;
    } catch (e) {
      AppLoggerHelper.error('Place details error: $e');
      return null;
    }
  }

  /// Get directions between two points
  static Future<Map<String, dynamic>?> getDirections(
    LatLng origin,
    LatLng destination, {
    String mode = 'driving',
  }) async {
    try {
      final params = {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'mode': mode,
        'key': Platform.isAndroid
            ? ApiConstants.googleMapAndroidApikey
            : ApiConstants.googleMapIOSApikey,
      };

      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json',
      ).replace(queryParameters: params);
      final response = await http.Client().get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final route = data['routes'][0];
          final leg = route['legs'][0];

          // Decode polyline points
          final points = _decodePolyline(route['overview_polyline']['points']);

          return {
            'distance': leg['distance']['text'],
            'duration': leg['duration']['text'],
            'points': points,
          };
        }
      }
      return null;
    } catch (e) {
      AppLoggerHelper.error('Directions error: $e');
      return null;
    }
  }

  static List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
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

  /// Nearby places search
  static Future<List<PlaceDetails>> searchNearby({
    required LatLng location,
    required String type,
    int radius = 5000,
    String? keyword,
  }) async {
    try {
      final params = {
        'location': '${location.latitude},${location.longitude}',
        'radius': radius.toString(),
        'key': Platform.isAndroid
            ? ApiConstants.googleMapAndroidApikey
            : ApiConstants.googleMapIOSApikey,
      };

      if (type.isNotEmpty) params['type'] = type;
      if (keyword != null && keyword.isNotEmpty) params['keyword'] = keyword;

      final uri = Uri.parse(
        '$_baseUrl/nearbysearch/json',
      ).replace(queryParameters: params);
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          final places = <PlaceDetails>[];

          for (final result in results) {
            final geometry = result['geometry']['location'];
            places.add(
              PlaceDetails(
                name: result['name'] ?? 'Unknown Place',
                address: result['vicinity'],
                location: LatLng(geometry['lat'], geometry['lng']),
                rating: result['rating'] != null
                    ? double.parse(result['rating'].toString())
                    : null,
                totalRatings: result['user_ratings_total'],
                placeId: result['place_id'],
                phoneNumber: _getNestedValue(result, [
                  'international_phone_number',
                ]),
                website: _getNestedValue(result, ['website']),
                photos: result['photos'] != null
                    ? (result['photos'] as List)
                          .map((p) => p['photo_reference'].toString())
                          .toList()
                    : null,
              ),
            );
          }
          return places;
        }
      }
      return [];
    } catch (e) {
      AppLoggerHelper.error('Nearby search error: $e');
      return [];
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

  /// Get appropriate icon based on place types
  static String? _getPlaceIcon(List<dynamic>? types) {
    if (types == null || types.isEmpty) return 'place';

    final typeList = types.map((e) => e.toString()).toList();

    if (typeList.any(
      (type) =>
          type.contains('restaurant') ||
          type.contains('food') ||
          type.contains('cafe'),
    )) {
      return 'restaurant';
    } else if (typeList.any(
      (type) => type.contains('bar') || type.contains('night_club'),
    )) {
      return 'local_bar';
    } else if (typeList.any(
      (type) => type.contains('hotel') || type.contains('lodging'),
    )) {
      return 'hotel';
    } else if (typeList.any(
      (type) => type.contains('store') || type.contains('shopping_mall'),
    )) {
      return 'store';
    } else if (typeList.any(
      (type) => type.contains('park') || type.contains('amusement_park'),
    )) {
      return 'park';
    } else if (typeList.any(
      (type) => type.contains('museum') || type.contains('art_gallery'),
    )) {
      return 'museum';
    } else if (typeList.any(
      (type) => type.contains('hospital') || type.contains('health'),
    )) {
      return 'local_hospital';
    } else if (typeList.any(
      (type) => type.contains('school') || type.contains('university'),
    )) {
      return 'school';
    } else if (typeList.any((type) => type.contains('gas_station'))) {
      return 'local_gas_station';
    } else if (typeList.any(
      (type) => type.contains('bank') || type.contains('atm'),
    )) {
      return 'account_balance';
    }

    return 'place';
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

  /// Reverse geocoding to get address from coordinates
  static Future<String?> getAddressFromLatLng(LatLng location) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}'
            .replaceAll(RegExp(r'^,\s*|\s*,?\s*$'), '')
            .replaceAll(RegExp(r',\s*,', caseSensitive: false), ',');
      }
      return null;
    } catch (e) {
      AppLoggerHelper.error('Reverse geocoding error: $e');
      return null;
    }
  }

  /// Get photo URL for place
  static String getPlacePhotoUrl(String photoReference, {int maxWidth = 400}) {
    return '$_baseUrl/photo?maxwidth=$maxWidth&photoreference=$photoReference&key=${Platform.isAndroid ? ApiConstants.googleMapAndroidApikey : ApiConstants.googleMapIOSApikey}';
  }

  /// Helper method to safely get nested values from map
  static dynamic _getNestedValue(Map<String, dynamic> map, List<String> keys) {
    dynamic current = map;
    for (final key in keys) {
      if (current is Map && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current;
  }
}

class MapController extends GetxController {
  static MapController get instance => Get.find();

  // --- CORE MAP VARIABLES ---
  static const LatLng defaultLocation = LatLng(51.5074, 0.1278);

  final currentLocation = Rx<LocationData?>(null);
  final pickedLocation = Rx<LatLng?>(null);
  final locationName = 'Getting location...'.obs;
  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;
  final isLoading = false.obs;

  // --- ENHANCED SEARCH & UI ---
  final searchQuery = ''.obs;
  final searchSuggestions = <SearchSuggestion>[].obs;
  final recentSearches = <RecentSearch>[].obs;
  final isSearching = false.obs;
  final selectedPlaceDetails = Rx<PlaceDetails?>(null);
  final showLocationDetails = false.obs;

  // --- MAP STYLING & TYPE ---
  final currentMapType = MapType.normal.obs;
  final enabledMapDetails = <MapDetail>[].obs;

  // --- VOICE SEARCH ---
  final stt.SpeechToText speech = stt.SpeechToText();
  final isListening = false.obs;
  final speechText = ''.obs;

  // --- TECHNICAL ---
  StreamSubscription<LocationData>? _locationSubscription;
  final mapControllerCompleter = Completer<GoogleMapController>();
  GoogleMapController? googleMapController;
  Timer? _searchDebounceTimer;
  bool _isInitialMapSetupComplete = false;

  // --- ICONS ---
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _initializeSpeech();
    _initializeCustomMarkers();
    getCurrentLocation();
    _loadRecentSearches();
  }

  Future<void> _initializeSpeech() async {
    try {
      await speech.initialize();
    } catch (e) {
      AppLoggerHelper.error('Speech initialization error: $e');
    }
  }

  Future<void> _initializeCustomMarkers() async {
    sourceIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueGreen,
    );
    destinationIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueRed,
    );
    currentLocationIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueBlue,
    );
  }

  // --- VOICE SEARCH FUNCTIONALITY ---
  void startListening() async {
    if (await speech.hasPermission && !isListening.value) {
      isListening.value = true;
      speechText.value = '';
      speech.listen(
        onResult: (result) {
          speechText.value = result.recognizedWords;
          if (result.finalResult) {
            onSearchQueryChanged(result.recognizedWords);
            isListening.value = false;
          }
        },
        listenFor: const Duration(seconds: 30),
        cancelOnError: true,
        partialResults: true,
      );
    } else {
      final status = await speech.initialize();
      if (status) {
        startListening();
      }
    }
  }

  void stopListening() {
    isListening.value = false;
    speech.stop();
  }

  // --- ENHANCED SEARCH FUNCTIONALITY ---
  void onSearchQueryChanged(String query) {
    searchQuery.value = query;
    _searchDebounceTimer?.cancel();

    if (query.isEmpty) {
      searchSuggestions.clear();
      isSearching.value = false;
      return;
    }

    isSearching.value = true;
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performEnhancedSearch(query);
    });
  }

  Future<void> _performEnhancedSearch(String query) async {
    try {
      LatLng? searchLocation;
      if (currentLocation.value?.latitude != null) {
        searchLocation = LatLng(
          currentLocation.value!.latitude!,
          currentLocation.value!.longitude!,
        );
      }

      final List<SearchSuggestion> allSuggestions = [];

      // 1. Google Places API
      final placeSuggestions = await GooglePlacesService.searchPlaces(
        query,
        location: searchLocation,
      );
      allSuggestions.addAll(placeSuggestions);

      // 2. Recent searches matching query
      final recentMatches = recentSearches
          .where(
            (search) =>
                search.query.toLowerCase().contains(query.toLowerCase()),
          )
          .take(3)
          .map(
            (recent) => SearchSuggestion(
              id: recent.id,
              title: recent.query,
              subtitle: recent.address,
              type: 'recent',
              icon: 'history',
            ),
          )
          .toList();
      allSuggestions.addAll(recentMatches);

      // 3. Current location option
      if (query.toLowerCase().contains('current') ||
          query.toLowerCase().contains('my location')) {
        allSuggestions.insert(
          0,
          SearchSuggestion(
            id: 'current_location',
            title: 'Your Current Location',
            subtitle: 'Based on your device location',
            type: 'current_location',
            icon: 'my_location',
          ),
        );
      }

      searchSuggestions.assignAll(allSuggestions);

      _saveToRecentSearches(query, type: 'search');
    } catch (e) {
      AppLoggerHelper.error('Enhanced search error: $e');
      searchSuggestions.clear();
    } finally {
      isSearching.value = false;
    }
  }

  void _saveToRecentSearches(
    String query, {
    String type = 'search',
    String? placeId,
    LatLng? location,
    String? address,
  }) {
    final recent = RecentSearch(
      id: const Uuid().v4(),
      query: query,
      placeId: placeId,
      location: location,
      address: address,
      timestamp: DateTime.now(),
      type: type,
    );

    recentSearches.insert(0, recent);

    if (recentSearches.length > 20) {
      recentSearches.removeLast();
    }

    _saveRecentSearchesToStorage();
  }

  void _loadRecentSearches() {
    recentSearches.addAll([
      RecentSearch(
        id: '1',
        query: 'Restaurants',
        type: 'search',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      RecentSearch(
        id: '2',
        query: 'Gas Stations',
        type: 'search',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      RecentSearch(
        id: '3',
        query: 'Taiz University',
        address: 'Taizz, Yemen',
        type: 'place',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
  }

  void _saveRecentSearchesToStorage() {
    // Implement storage saving
  }

  // --- SUGGESTION SELECTION HANDLING ---
  Future<void> onSuggestionSelected(SearchSuggestion suggestion) async {
    searchQuery.value = suggestion.title;
    searchSuggestions.clear();
    isSearching.value = false;

    _saveToRecentSearches(
      suggestion.title,
      type: suggestion.type,
      placeId: suggestion.placeId,
      location: suggestion.location,
      address: suggestion.subtitle,
    );

    try {
      if (suggestion.type == 'current_location') {
        moveToCurrentLocation();
      } else if (suggestion.placeId != null) {
        await _handlePlaceSuggestion(suggestion);
      } else if (suggestion.location != null) {
        await _handleLocationSuggestion(suggestion);
      } else if (suggestion.type == 'recent') {
        onSearchQueryChanged(suggestion.title);
      }
    } catch (e) {
      AppLoggerHelper.error('Suggestion selection error: $e');
      Get.snackbar(
        'Error',
        'Could not load location details',
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: AppColors.white,
      );
    }
  }

  void moveToCurrentLocation() {
    if (currentLocation.value?.latitude != null) {
      final latLng = LatLng(
        currentLocation.value!.latitude!,
        currentLocation.value!.longitude!,
      );
      moveCameraToLatLng(latLng);
      _addMarkerForLocation(latLng, 'Your Location', isCurrentLocation: true);
    }
  }

  Future<void> _handlePlaceSuggestion(SearchSuggestion suggestion) async {
    final details = await GooglePlacesService.getPlaceDetails(
      suggestion.placeId!,
    );
    if (details != null) {
      moveCameraToLatLng(details.location);
      _addMarkerForLocation(details.location, details.name);
      selectedPlaceDetails.value = details;
      showLocationDetails.value = true;
    }
  }

  Future<void> _handleLocationSuggestion(SearchSuggestion suggestion) async {
    moveCameraToLatLng(suggestion.location!);
    _addMarkerForLocation(suggestion.location!, suggestion.title);

    final address = await GooglePlacesService.getAddressFromLatLng(
      suggestion.location!,
    );
    selectedPlaceDetails.value = PlaceDetails(
      name: suggestion.title,
      address: address,
      location: suggestion.location!,
    );
    showLocationDetails.value = true;
  }

  // --- MAP TYPE & STYLING ---
  void changeMapType(MapType newType) {
    currentMapType.value = newType;
  }

  void toggleMapDetail(MapDetail detail) {
    if (enabledMapDetails.contains(detail)) {
      enabledMapDetails.remove(detail);
    } else {
      enabledMapDetails.add(detail);
    }
    enabledMapDetails.refresh();
  }

  MapType get googleMapType {
    switch (currentMapType.value) {
      case MapType.satellite:
        return MapType.satellite;
      case MapType.terrain:
        return MapType.terrain;
      case MapType.hybrid:
        return MapType.hybrid;
      default:
        return MapType.normal;
    }
  }

  // --- MAP FUNCTIONALITY ---
  void onMapCreated(GoogleMapController controller) async {
    if (!mapControllerCompleter.isCompleted) {
      googleMapController = controller;
      mapControllerCompleter.complete(controller);
      await Future.delayed(const Duration(milliseconds: 1000));
      _performInitialMapSetup();
    }
  }

  void _performInitialMapSetup() {
    if (_isInitialMapSetupComplete) return;

    final targetLocation = currentLocation.value;
    if (targetLocation?.latitude != null) {
      final target = LatLng(
        targetLocation!.latitude!,
        targetLocation.longitude!,
      );
      moveCameraToLatLng(target);
    }

    _isInitialMapSetupComplete = true;
  }

  void moveCameraToLatLng(LatLng target) {
    googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(zoom: 15, target: target)),
    );
  }

  void onMapTap(LatLng position) {
    pickedLocation.value = position;
    _updateSelectionMarker(position);
    _getLocationName(position.latitude, position.longitude);
  }

  void _updateSelectionMarker(LatLng position) {
    const markerId = MarkerId('selectedLocation');
    final selectionMarker = Marker(
      markerId: markerId,
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'Selected Location'),
    );

    markers.removeWhere((m) => m.markerId == markerId);
    markers.add(selectionMarker);
    markers.refresh();
  }

  void _addMarkerForLocation(
    LatLng location,
    String title, {
    bool isCurrentLocation = false,
  }) {
    final markerId = MarkerId(
      isCurrentLocation ? 'currentLocation' : 'search_result',
    );
    final marker = Marker(
      markerId: markerId,
      position: location,
      icon: isCurrentLocation
          ? currentLocationIcon
          : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: title),
    );

    markers.removeWhere((m) => m.markerId == markerId);
    markers.add(marker);
    markers.refresh();
  }

  Future<void> _getLocationName(double latitude, double longitude) async {
    try {
      final address = await GooglePlacesService.getAddressFromLatLng(
        LatLng(latitude, longitude),
      );
      locationName.value = address ?? 'Unknown Location';
    } catch (e) {
      AppLoggerHelper.error('Reverse Geocoding Error: $e');
      locationName.value = 'Location name not found';
    }
  }

  // --- LOCATION SERVICES ---
  void getCurrentLocation() async {
    final location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    LocationData? newLocationData;

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        AppLoggerHelper.error('Location services are disabled');
        return;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
    }

    if (serviceEnabled && permissionGranted == PermissionStatus.granted) {
      try {
        newLocationData = await location.getLocation();
        currentLocation.value = newLocationData;
        pickedLocation.value = LatLng(
          newLocationData.latitude!,
          newLocationData.longitude!,
        );

        if (!_isInitialMapSetupComplete) {
          _performInitialMapSetup();
        }
      } on PlatformException catch (e) {
        AppLoggerHelper.error('Initial Location Fetch Error: ${e.message}');
      }
    }

    if (currentLocation.value?.latitude != null &&
        currentLocation.value?.longitude != null) {
      _getLocationName(
        currentLocation.value!.latitude!,
        currentLocation.value!.longitude!,
      );
    }

    _locationSubscription = location.onLocationChanged.listen(
      (newLocation) {
        currentLocation.value = newLocation;
        if (googleMapController != null && _isInitialMapSetupComplete) {
          _getLocationName(newLocation.latitude!, newLocation.longitude!);
          _moveCameraToLocation(newLocation);
        }
      },
      onError: (error) {
        AppLoggerHelper.error('Live Location Stream Error: $error');
      },
    );
  }

  void _moveCameraToLocation(LocationData location) {
    moveCameraToLatLng(LatLng(location.latitude!, location.longitude!));
  }

  void clearSearch() {
    searchQuery.value = '';
    searchSuggestions.clear();
    isSearching.value = false;
    showLocationDetails.value = false;
    selectedPlaceDetails.value = null;

    markers.removeWhere((m) => m.markerId.value == 'search_result');
    markers.refresh();
  }

  void savePickedLocation() {
    if (pickedLocation.value == null) return;

    final LatLng position = pickedLocation.value!;

    final newMapAddress = AddressModel(
      id: 'Map_${const Uuid().v4()}',
      name: locationName.value.isNotEmpty ? locationName.value : 'Map Location',
      phoneNumber: 'N/A',
      street: _extractStreetFromAddress(locationName.value),
      city: _extractCityFromAddress(locationName.value),
      state: '',
      postalCode: '',
      country: _extractCountryFromAddress(locationName.value),
      latitude: position.latitude,
      longitude: position.longitude,
      selectedAddress: true,
    );

    Get.back(result: newMapAddress);
  }

  // Helper methods to parse address components
  String _extractStreetFromAddress(String address) {
    if (address.isEmpty) return '';
    final parts = address.split(',');
    return parts.isNotEmpty ? parts.first.trim() : '';
  }

  String _extractCityFromAddress(String address) {
    if (address.isEmpty) return '';
    final parts = address.split(',');
    return parts.length > 1 ? parts[1].trim() : '';
  }

  String _extractCountryFromAddress(String address) {
    if (address.isEmpty) return '';
    final parts = address.split(',');
    return parts.isNotEmpty ? parts.last.trim() : '';
  }

  // --- CLEANUP ---
  @override
  void onClose() {
    _locationSubscription?.cancel();
    _searchDebounceTimer?.cancel();
    speech.stop();
    if (googleMapController != null) {
      googleMapController!.dispose();
    }
    super.onClose();
  }
}
