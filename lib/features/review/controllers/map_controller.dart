

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart' hide Location;
import '../../../utils/constants/api_constants.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/device/device_utility.dart';
import '../../../utils/logging/logger.dart';
import '../../../utils/popups/loaders.dart';
import '../../personalization/models/address_model.dart';

// --- SEARCH RELATED CLASSES ---
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

// Google Places API Service
class GooglePlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static final http.Client _client = http.Client();

  bool get currentPlatform => AppDeviceUtils.isAndroid();

  /// Search places using Google Places Autocomplete API
  static Future<List<SearchSuggestion>> searchPlaces(
    String query, {
    LatLng? location,
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
        'types': 'establishment|geocode',
        'components': 'country:uk', // Optional: restrict to specific country
      };

      if (location != null) {
        params['location'] = '${location.latitude},${location.longitude}';
        params['radius'] = '50000'; // 50km radius
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
                id:
                    prediction['place_id'] ??
                    prediction['id'] ??
                    const Uuid().v4(),
                title: prediction['description'],
                subtitle: _extractSubtitle(prediction),
                type: 'place',
                placeId: prediction['place_id'],
                icon: _getPlaceIcon(prediction['types']),
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
      // Fallback to geocoding if Places API fails
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
}

class MapController extends GetxController {
  static MapController get instance => Get.find();

  /// -- Static/ Helper Variables
  static const LatLng defaultLocation = LatLng(51.5074, 0.1278);

  /// VARIABLES
  final currentLocation = Rx<LocationData?>(
    LocationData.fromMap({
      'latitude': defaultLocation.latitude,
      'longitude': defaultLocation.longitude,
      'accuracy': 0.0,
      'time': DateTime.now().millisecondsSinceEpoch.toDouble(),
    }),
  );

  final pickedLocation = Rx<LatLng?>(defaultLocation);
  final locationName = 'Default Location (London)'.obs;
  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;
  final isLoading = false.obs;

  // Search functionality
  final searchQuery = ''.obs;
  final searchSuggestions = <SearchSuggestion>[].obs;
  final isSearching = false.obs;
  final selectedPlaceDetails = Rx<PlaceDetails?>(null);
  final showLocationDetails = false.obs;

  StreamSubscription<LocationData>? _locationSubscription;
  final mapControllerCompleter = Completer<GoogleMapController>();
  GoogleMapController? googleMapController;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  bool _isInitialMapSetupComplete = false;
  Timer? _searchDebounceTimer;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  @override
  void onClose() {
    _locationSubscription?.cancel();
    _searchDebounceTimer?.cancel();
    if (googleMapController != null) {
      googleMapController!.dispose();
    }
    super.onClose();
  }

  // --- SEARCH FUNCTIONALITY ---

  /// Handle search query changes with debounce
  void onSearchQueryChanged(String query) {
    searchQuery.value = query;

    // Cancel previous timer
    _searchDebounceTimer?.cancel();

    if (query.isEmpty) {
      searchSuggestions.clear();
      isSearching.value = false;
      return;
    }

    isSearching.value = true;

    // Debounce search to avoid too many API calls
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  /// Perform actual search
  Future<void> _performSearch(String query) async {
    try {
      LatLng? searchLocation;
      if (currentLocation.value?.latitude != null &&
          currentLocation.value?.longitude != null) {
        searchLocation = LatLng(
          currentLocation.value!.latitude!,
          currentLocation.value!.longitude!,
        );
      }

      final suggestions = await GooglePlacesService.searchPlaces(
        query,
        location: searchLocation,
      );
      searchSuggestions.assignAll(suggestions);
    } catch (e) {
      AppLoggerHelper.error('Search error: $e');
      searchSuggestions.clear();
    } finally {
      isSearching.value = false;
    }
  }

  /// Handle suggestion selection
  Future<void> onSuggestionSelected(SearchSuggestion suggestion) async {
    searchQuery.value = suggestion.title;
    searchSuggestions.clear();
    isSearching.value = false;

    try {
      if (suggestion.type == 'current_location') {
        // Move to current location
        if (currentLocation.value?.latitude != null &&
            currentLocation.value?.longitude != null) {
          final latLng = LatLng(
            currentLocation.value!.latitude!,
            currentLocation.value!.longitude!,
          );
          _moveCameraToLatLng(latLng);
          _addMarkerForLocation(latLng, suggestion.title);
        }
      } else if (suggestion.placeId != null) {
        // Get place details and move to location
        final details = await GooglePlacesService.getPlaceDetails(
          suggestion.placeId!,
        );
        if (details != null) {
          _moveCameraToLatLng(details.location);
          _addMarkerForLocation(details.location, details.name);
          selectedPlaceDetails.value = details;
          showLocationDetails.value = true;
        }
      } else if (suggestion.location != null) {
        // Move to the suggested location
        _moveCameraToLatLng(suggestion.location!);
        _addMarkerForLocation(suggestion.location!, suggestion.title);

        // Get address details for the location
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
    } catch (e) {
      AppLoggerHelper.error('Suggestion selection error: $e');
      // Show error snackbar
      Get.snackbar(
        'Error',
        'Could not load location details',
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: AppColors.white,
      );
    }
  }

  /// Add marker for a specific location
  void _addMarkerForLocation(LatLng location, String title) {
    const markerId = MarkerId('search_result');
    final marker = Marker(
      markerId: markerId,
      position: location,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: title),
    );

    markers.removeWhere((m) => m.markerId == markerId);
    markers.add(marker);
    markers.refresh();
  }

  /// Clear search and markers
  void clearSearch() {
    searchQuery.value = '';
    searchSuggestions.clear();
    isSearching.value = false;
    showLocationDetails.value = false;
    selectedPlaceDetails.value = null;

    // Remove search result markers but keep selection marker
    markers.removeWhere((m) => m.markerId.value == 'search_result');
    markers.refresh();
  }

  /// Select this location for picking
  void selectCurrentLocationForPicking() {
    if (selectedPlaceDetails.value != null) {
      pickedLocation.value = selectedPlaceDetails.value!.location;
      _updateSelectionMarker(selectedPlaceDetails.value!.location);
      locationName.value = selectedPlaceDetails.value!.name;
      hideLocationDetails();
    }
  }

  /// Hide location details
  void hideLocationDetails() {
    showLocationDetails.value = false;
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
    isLoading.value = true;
    if (_isInitialMapSetupComplete) return;

    final targetLocation = currentLocation.value;
    final LatLng target = LatLng(
      targetLocation!.latitude!,
      targetLocation.longitude!,
    );

    if (pickedLocation.value == null) {
      pickedLocation.value = target;
      _updateSelectionMarker(target);
    }

    _moveCameraToLatLng(target);
    _updateAllMarkers();

    _isInitialMapSetupComplete = true;
    isLoading.value = false;
  }

  void _moveCameraToLatLng(LatLng target) {
    googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(zoom: 15, target: target)),
    );
  }

  // void onMapTap(LatLng position) {
  //   pickedLocation.value = position;
  //   _updateSelectionMarker(position);
  //   _getLocationName(position.latitude, position.longitude);

  //   // Show location details for tapped location
  //   _showDetailsForTappedLocation(position);
  // }

  void onMapTap(LatLng position) {
    pickedLocation.value = position;
    _updateSelectionMarker(position);
    _getLocationName(position.latitude, position.longitude);

    // Show location details for tapped location
    _showDetailsForTappedLocation(position);
  }

  Future<void> _showDetailsForTappedLocation(LatLng position) async {
    try {
      final address = await GooglePlacesService.getAddressFromLatLng(position);
      selectedPlaceDetails.value = PlaceDetails(
        name: 'Selected Location',
        address: address,
        location: position,
      );
      showLocationDetails.value = true;
    } catch (e) {
      AppLoggerHelper.error('Error getting details for tapped location: $e');
    }
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

  void _updateAllMarkers() {
    final LocationData currentLoc = currentLocation.value!;
    final Set<Marker> newMarkers = {
      Marker(
        markerId: const MarkerId('currentLocation'),
        icon: currentLocationIcon,
        position: LatLng(currentLoc.latitude!, currentLoc.longitude!),
      ),
    };

    final selectedMarker = markers
        .where((m) => m.markerId == const MarkerId('selectedLocation'))
        .firstOrNull;

    if (selectedMarker != null) {
      newMarkers.add(selectedMarker);
    }

    final searchMarker = markers
        .where((m) => m.markerId.value == 'search_result')
        .firstOrNull;

    if (searchMarker != null) {
      newMarkers.add(searchMarker);
    }

    markers.assignAll(newMarkers);
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

  void getCurrentLocation() async {
    final location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    LocationData? newLocationData;

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
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
      } on PlatformException catch (e) {
        AppLoggerHelper.error('Initial Location Fetch Error: ${e.message}');
      }
    }

    if (currentLocation.value!.latitude != null &&
        currentLocation.value!.longitude != null) {
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
          _updateAllMarkers();
        }
      },
      onError: (error) {
        AppLoggerHelper.error('Live Location Stream Error: $error');
      },
    );
  }

  void _moveCameraToLocation(LocationData location) {
    _moveCameraToLatLng(LatLng(location.latitude!, location.longitude!));
  }

  void savePickedLocation() {
    if (pickedLocation.value == null) return;

    final LatLng position = pickedLocation.value!;

    // Create address with proper data
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
}
