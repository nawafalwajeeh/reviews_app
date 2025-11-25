import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:reviews_app/features/review/models/search_suggestion.dart';
import 'package:uuid/uuid.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:reviews_app/features/review/models/place_model.dart';
import 'package:reviews_app/features/review/controllers/place_controller.dart';
import 'package:reviews_app/features/review/controllers/category_controller.dart';
import '../../../data/services/map_service/map_service.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/marker_icons.dart';
import '../../../utils/logging/logger.dart';
import '../../personalization/models/address_model.dart';
import '../models/category_model.dart';
import '../models/google_search_suggestions.dart';

class PlacesMapController extends GetxController {
  static PlacesMapController get instance => Get.find();

  // --- CORE MAP VARIABLES ---
  final currentLocation = Rx<LocationData?>(null);
  final pickedLocation = Rx<LatLng?>(null);
  final locationName = 'Getting location...'.obs;
  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;
  final isLoading = false.obs;

  // --- PLACES INTEGRATION ---
  final RxList<PlaceModel> displayedPlaces = <PlaceModel>[].obs;
  final Rx<PlaceModel?> selectedPlace = Rx<PlaceModel?>(null);
  final RxString selectedCategoryId = ''.obs;
  final RxList<PlaceModel> nearbyPlaces = <PlaceModel>[].obs;
  final RxDouble searchRadius = 5000.0.obs; // 5km default

  // --- ENHANCED SEARCH & UI ---
  final searchQuery = ''.obs;
  final searchSuggestions = <SearchSuggestion>[].obs;
  final recentSearches = <RecentSearch>[].obs;
  final isSearching = false.obs;
  final showLocationDetails = false.obs;
  final showBottomSheet = false.obs;

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

  // --- GETX CONTROLLERS ---
  final PlaceController placeController = Get.find();
  final CategoryController categoryController = Get.find();

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    isLoading.value = true;

    try {
      await _initializeSpeech();
      getCurrentLocation();
      _loadRecentSearches();
      _loadPlaces();

      // Small delay to ensure smooth UX
      await Future.delayed(const Duration(milliseconds: 1000));
    } catch (e) {
      AppLoggerHelper.error('App initialization error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _initializeSpeech() async {
    try {
      await speech.initialize();
    } catch (e) {
      AppLoggerHelper.error('Speech initialization error: $e');
    }
  }

  // --- PLACES INTEGRATION METHODS ---
  void _loadPlaces() {
    try {
      AppLoggerHelper.info('Loading places from PlaceController...');

      // Use places from PlaceController
      final availablePlaces = placeController.places;
      AppLoggerHelper.info('Total places loaded: ${availablePlaces.length}');

      // Log places with their categories for debugging
      for (final place in availablePlaces.take(5)) {
        AppLoggerHelper.info(
          'Place: ${place.title} - Category: ${place.categoryId} - Lat: ${place.latitude} - Lng: ${place.longitude}',
        );
      }

      displayedPlaces.assignAll(availablePlaces);
      _createPlaceMarkers();

      // Check if places have valid coordinates
      final placesWithCoords = availablePlaces
          .where((p) => p.latitude != 0.0 && p.longitude != 0.0)
          .length;
      AppLoggerHelper.info('Places with valid coordinates: $placesWithCoords');
    } catch (e) {
      AppLoggerHelper.error('Error loading places: $e');
      Get.snackbar(
        'Loading Error',
        'Could not load places',
        backgroundColor: AppColors.error,
      );
    }
  }

  // void _createPlaceMarkers() async {
  //   markers.clear();

  //   for (final place in displayedPlaces) {
  //     if (place.latitude == 0.0 || place.longitude == 0.0) continue;

  //     final marker = Marker(
  //       markerId: MarkerId('place_${place.id}'),
  //       position: LatLng(place.latitude, place.longitude),
  //       infoWindow: InfoWindow(
  //         title: place.title,
  //         snippet: '${place.averageRating} ⭐ • ${place.address.shortAddress}',
  //       ),
  //       icon: await _createCustomPlaceMarker(place),
  //       onTap: () => _onPlaceMarkerTapped(place),
  //     );

  //     markers.add(marker);
  //   }
  //   markers.refresh();
  // }

  // Future<void> _createPlaceMarkers() async {
  //   markers.clear();

  //   // Add current location marker if available
  //   if (currentLocation.value?.latitude != null) {
  //     final currentLocationMarker = Marker(
  //       markerId: const MarkerId('current_location'),
  //       position: LatLng(
  //         currentLocation.value!.latitude!,
  //         currentLocation.value!.longitude!,
  //       ),
  //       icon: await CustomMarkerGenerator.getCurrentLocationMarker(),
  //       infoWindow: const InfoWindow(title: 'Your Location'),
  //       zIndexInt: 1000,
  //     );
  //     markers.add(currentLocationMarker);
  //   }

  //   // Add place markers
  //   for (final place in displayedPlaces) {
  //     if (place.latitude == 0.0 || place.longitude == 0.0) continue;

  //     final isSelected = selectedPlace.value?.id == place.id;
  //     final marker = Marker(
  //       markerId: MarkerId('place_${place.id}'),
  //       position: LatLng(place.latitude, place.longitude),
  //       infoWindow: InfoWindow(
  //         title: place.title,
  //         snippet: '${place.averageRating} ⭐ • ${place.address.shortAddress}',
  //       ),
  //       icon: await CustomMarkerGenerator.generatePlaceMarker(
  //         place,
  //         isSelected: isSelected,
  //       ),
  //       onTap: () => _onPlaceMarkerTapped(place),
  //       zIndexInt: isSelected ? 1000 : 1,
  //     );

  //     markers.add(marker);
  //   }
  //   markers.refresh();
  // }

  Future<void> _createPlaceMarkers() async {
    markers.clear();

    // Add current location marker if available
    if (currentLocation.value?.latitude != null) {
      final currentLocationMarker = Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(
          currentLocation.value!.latitude!,
          currentLocation.value!.longitude!,
        ),
        icon: await CustomMarkerGenerator.getCurrentLocationMarker(),
        infoWindow: const InfoWindow(title: 'Your Location'),
        zIndexInt: 1000,
        anchor: const Offset(0.5, 0.5),
      );
      markers.add(currentLocationMarker);
    }

    // Add place markers
    for (final place in displayedPlaces) {
      if (place.latitude == 0.0 || place.longitude == 0.0) continue;

      final isSelected = selectedPlace.value?.id == place.id;
      final marker = Marker(
        markerId: MarkerId('place_${place.id}'),
        position: LatLng(place.latitude, place.longitude),
        infoWindow: InfoWindow(
          title: place.title,
          snippet: '${place.averageRating} ⭐ • ${place.address.shortAddress}',
          onTap: () => _onPlaceMarkerTapped(place),
        ),
        icon: await CustomMarkerGenerator.generatePlaceMarker(
          place,
          isSelected: isSelected,
        ),
        onTap: () => _onPlaceMarkerTapped(place),
        zIndexInt: isSelected ? 1000 : 1,
        anchor: const Offset(0.5, 1.0), // Anchor at bottom center for pointer
      );

      markers.add(marker);
    }
    markers.refresh();
  }

  void _addHighlightMarker(PlaceModel place) {
    final markerId = MarkerId('highlighted_${place.id}');

    // Remove any existing highlight marker
    markers.removeWhere((m) => m.markerId.value.startsWith('highlighted_'));

    // Recreate the selected marker with highlighted style
    _createPlaceMarkers(); // This will recreate all markers with proper selection state
  }

  // Future<BitmapDescriptor> _createCustomPlaceMarker(PlaceModel place) async {
  //   // Create custom marker based on rating and category
  //   double rating = place.averageRating;
  //   var hue = BitmapDescriptor.hueBlue;

  //   if (rating >= 4.0) {
  //     hue = BitmapDescriptor.hueGreen;
  //   } else if (rating >= 3.0) {
  //     hue = BitmapDescriptor.hueOrange;
  //   } else if (rating >= 2.0) {
  //     hue = BitmapDescriptor.hueYellow;
  //   } else {
  //     hue = BitmapDescriptor.hueRed;
  //   }

  //   return BitmapDescriptor.defaultMarkerWithHue(hue);
  // }

  // void _onPlaceMarkerTapped(PlaceModel place) {
  //   selectedPlace.value = place;
  //   showBottomSheet.value = true;
  //   showLocationDetails.value = true;

  //   // Move camera to place
  //   moveCameraToLatLng(LatLng(place.latitude, place.longitude));

  //   // Add highlight marker
  //   _addHighlightMarker(place);
  // }

  void _onPlaceMarkerTapped(PlaceModel place) {
    selectedPlace.value = place;
    showBottomSheet.value = true;
    showLocationDetails.value = true;

    // Move camera to place with nice animation
    moveCameraToLatLng(LatLng(place.latitude, place.longitude), zoom: 16.0);

    // Update markers to show selection
    _createPlaceMarkers();

    // Log for debugging
    AppLoggerHelper.info('Marker tapped: ${place.title}');
  }

  // Updated moveCameraToLatLng with optional zoom
  void moveCameraToLatLng(LatLng target, {double? zoom}) {
    googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: zoom ?? 15.0,
          bearing: 0,
          // tilt: isPickerMode ? 0 : 45, // Slight tilt for better view
          tilt: 45,
        ),
      ),
    );
  }

  // void _addHighlightMarker(PlaceModel place) {
  //   const markerId = MarkerId('highlighted_place');
  //   final highlightMarker = Marker(
  //     markerId: markerId,
  //     position: LatLng(place.latitude, place.longitude),
  //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
  //     infoWindow: InfoWindow(title: place.title),
  //   );

  //   markers.removeWhere((m) => m.markerId == markerId);
  //   markers.add(highlightMarker);
  //   markers.refresh();
  // }

  // --- ENHANCED SEARCH WITH PLACES INTEGRATION ---
  void onSearchQueryChanged(String query) {
    searchQuery.value = query;
    _searchDebounceTimer?.cancel();

    if (query.isEmpty) {
      searchSuggestions.clear();
      isSearching.value = false;
      _filterPlacesBySearch('');
      return;
    }

    isSearching.value = true;
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performEnhancedSearch(query);
    });
  }

  void _filterPlacesBySearch(String query) {
    if (query.isEmpty) {
      displayedPlaces.assignAll(placeController.places);
    } else {
      final filtered = placeController.places.where((place) {
        return place.title.toLowerCase().contains(query.toLowerCase()) ||
            place.description.toLowerCase().contains(query.toLowerCase()) ||
            place.address.shortAddress.toLowerCase().contains(
              query.toLowerCase(),
            );
      }).toList();
      displayedPlaces.assignAll(filtered);
    }
    _createPlaceMarkers();
  }

  // Enhanced search with database + Google API integration
  Future<void> _performEnhancedSearch(String query) async {
    try {
      final List<SearchSuggestion> allSuggestions = [];

      // 1. Search in our local database first
      final localPlaceSuggestions = _searchLocalPlaces(query);
      allSuggestions.addAll(localPlaceSuggestions);

      // 2. If we have few local results, search Google Places
      if (localPlaceSuggestions.length < 5) {
        try {
          final googleResults = await GooglePlacesService.searchPlaces(
            query,
            location: currentLocation.value != null
                ? LatLng(
                    currentLocation.value!.latitude!,
                    currentLocation.value!.longitude!,
                  )
                : null,
          );

          // Filter out duplicates with local results
          final uniqueGoogleResults = googleResults.where((googleSuggestion) {
            return !localPlaceSuggestions.any(
              (localSuggestion) =>
                  localSuggestion.title.toLowerCase() ==
                  googleSuggestion.title.toLowerCase(),
            );
          }).toList();

          allSuggestions.addAll(uniqueGoogleResults);
        } catch (e) {
          AppLoggerHelper.error('Google Places search error: $e');
        }
      }

      // 3. Add recent searches
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

      // 4. Add current location option for relevant queries
      if (_isCurrentLocationQuery(query)) {
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

  bool _isCurrentLocationQuery(String query) {
    final locationKeywords = [
      'current',
      'my location',
      'near me',
      'nearby',
      'around me',
      'close to me',
    ];
    return locationKeywords.any(
      (keyword) => query.toLowerCase().contains(keyword),
    );
  }

  // Improved local places search
  List<SearchSuggestion> _searchLocalPlaces(String query) {
    if (query.isEmpty) return [];

    final results = placeController.places.where((place) {
      final searchableText =
          '''
      ${place.title} 
      ${place.description} 
      ${place.address.shortAddress}
      ${place.tags?.join(' ') ?? ''}
      ${_getCategoryName(place.categoryId)}
    '''
              .toLowerCase();

      return searchableText.contains(query.toLowerCase());
    }).toList();

    // Sort by relevance (title matches first, then description, then address)
    results.sort((a, b) {
      final aTitleMatch = a.title.toLowerCase().contains(query.toLowerCase());
      final bTitleMatch = b.title.toLowerCase().contains(query.toLowerCase());

      if (aTitleMatch && !bTitleMatch) return -1;
      if (!aTitleMatch && bTitleMatch) return 1;

      return a.title.compareTo(b.title);
    });

    return results
        .map((place) => SearchSuggestion.fromPlaceModel(place))
        .toList();
  }

  String _getCategoryName(String categoryId) {
    try {
      final category = categoryController.allCategories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => CategoryModel.empty(),
      );
      return category.name;
    } catch (e) {
      return '';
    }
  }

  // --- CATEGORY FILTERING ---
  void filterByCategory(String categoryId) {
    try {
      selectedCategoryId.value = categoryId;

      AppLoggerHelper.info('Filtering by category: $categoryId');
      AppLoggerHelper.info(
        'Total places available: ${placeController.places.length}',
      );

      if (categoryId.isEmpty) {
        // Show all places
        displayedPlaces.assignAll(placeController.places);
        AppLoggerHelper.info('Showing all places: ${displayedPlaces.length}');
      } else {
        // Filter by category
        final filteredPlaces = placeController.places.where((place) {
          final matches = place.categoryId == categoryId;
          if (matches) {
            AppLoggerHelper.info(
              'Place matches category: ${place.title} - Category: ${place.categoryId}',
            );
          }
          return matches;
        }).toList();

        displayedPlaces.assignAll(filteredPlaces);
        AppLoggerHelper.info(
          'Filtered places count: ${displayedPlaces.length}',
        );
      }

      _createPlaceMarkers();

      // Move camera to show filtered places
      if (displayedPlaces.isNotEmpty) {
        final firstPlace = displayedPlaces.first;
        moveCameraToLatLng(LatLng(firstPlace.latitude, firstPlace.longitude));
      } else {
        AppLoggerHelper.warning('No places found for category: $categoryId');
        Get.snackbar(
          'No Places Found',
          'No places found for the selected category',
          backgroundColor: AppColors.warning,
        );
      }
    } catch (e) {
      AppLoggerHelper.error('Category filtering error: $e');
      Get.snackbar(
        'Filter Error',
        'Could not filter places by category',
        backgroundColor: AppColors.error,
      );
    }
  }

  // --- NEARBY PLACES ---
  // Future<void> loadNearbyPlaces() async {
  //   if (currentLocation.value == null) return;

  //   try {
  //     isLoading.value = true;
  //     final currentLatLng = LatLng(
  //       currentLocation.value!.latitude!,
  //       currentLocation.value!.longitude!,
  //     );

  //     // Filter places within radius
  //     nearbyPlaces.assignAll(
  //       displayedPlaces.where((place) {
  //         final distance = _calculateDistance(
  //           currentLatLng.latitude,
  //           currentLatLng.longitude,
  //           place.latitude,
  //           place.longitude,
  //         );
  //         return distance <= searchRadius.value;
  //       }).toList(),
  //     );

  //     AppLoggerHelper.info(
  //       'Found ${nearbyPlaces.length} nearby places within ${searchRadius.value}m',
  //     );
  //   } catch (e) {
  //     AppLoggerHelper.error('Error loading nearby places: $e');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0; // Earth's radius in meters

    final lat1Rad = _degreesToRadians(lat1);
    final lat2Rad = _degreesToRadians(lat2);
    final deltaLatRad = _degreesToRadians(lat2 - lat1);
    final deltaLonRad = _degreesToRadians(lon2 - lon1);

    final a =
        sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) *
            cos(lat2Rad) *
            sin(deltaLonRad / 2) *
            sin(deltaLonRad / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  // Enhanced nearby places with radius filtering
  Future<void> loadNearbyPlaces({double? customRadius}) async {
    if (currentLocation.value == null) {
      Get.snackbar(
        'Location Required',
        'Please wait for your location to load',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    try {
      isLoading.value = true;
      final currentLatLng = LatLng(
        currentLocation.value!.latitude!,
        currentLocation.value!.longitude!,
      );

      // Use custom radius or default
      final radius = customRadius ?? searchRadius.value;

      // Filter places within radius
      final nearby = displayedPlaces.where((place) {
        if (place.latitude == 0.0 || place.longitude == 0.0) return false;

        final distance = _calculateDistance(
          currentLatLng.latitude,
          currentLatLng.longitude,
          place.latitude,
          place.longitude,
        );
        return distance <= radius;
      }).toList();

      // Sort by distance
      nearby.sort((a, b) {
        final distanceA = _calculateDistance(
          currentLatLng.latitude,
          currentLatLng.longitude,
          a.latitude,
          a.longitude,
        );
        final distanceB = _calculateDistance(
          currentLatLng.latitude,
          currentLatLng.longitude,
          b.latitude,
          b.longitude,
        );
        return distanceA.compareTo(distanceB);
      });

      nearbyPlaces.assignAll(nearby);

      AppLoggerHelper.info(
        'Found ${nearbyPlaces.length} nearby places within ${radius}m',
      );

      // Show results
      if (nearbyPlaces.isNotEmpty) {
        // Create bounds to show all nearby places
        final bounds = _createBoundsForPlaces(nearbyPlaces);
        _zoomToBounds(bounds);

        Get.snackbar(
          'Nearby Places',
          'Found ${nearbyPlaces.length} places nearby',
          backgroundColor: AppColors.success,
        );
      } else {
        Get.snackbar(
          'No Places Found',
          'No places found within ${(radius / 1000).toStringAsFixed(1)}km',
          backgroundColor: AppColors.warning,
        );
      }
    } catch (e) {
      AppLoggerHelper.error('Error loading nearby places: $e');
      Get.snackbar(
        'Error',
        'Could not load nearby places',
        backgroundColor: AppColors.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  LatLngBounds _createBoundsForPlaces(List<PlaceModel> places) {
    double? minLat, maxLat, minLng, maxLng;

    for (final place in places) {
      if (place.latitude == 0.0 || place.longitude == 0.0) continue;

      minLat = minLat == null ? place.latitude : min(minLat, place.latitude);
      maxLat = maxLat == null ? place.latitude : max(maxLat, place.latitude);
      minLng = minLng == null ? place.longitude : min(minLng, place.longitude);
      maxLng = maxLng == null ? place.longitude : max(maxLng, place.longitude);
    }

    // Add padding
    const padding = 0.01;
    minLat = (minLat ?? 0) - padding;
    maxLat = (maxLat ?? 0) + padding;
    minLng = (minLng ?? 0) - padding;
    maxLng = (maxLng ?? 0) + padding;

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Future<void> _zoomToBounds(LatLngBounds bounds) async {
    final controller = await mapControllerCompleter.future;
    final cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 100);
    await controller.animateCamera(cameraUpdate);
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
      switch (suggestion.type) {
        case 'current_location':
          moveToCurrentLocation();
          break;

        case 'local_place':
          // Find and select the local place
          final place = displayedPlaces.firstWhere(
            (p) => p.id == suggestion.id,
            orElse: () => PlaceModel.empty(),
          );
          if (place.id.isNotEmpty) {
            _onPlaceMarkerTapped(place);
          }
          break;

        case 'google_place':
          await _handleGooglePlaceSuggestion(suggestion);
          break;

        case 'address':
          await _handleAddressSuggestion(suggestion);
          break;

        case 'recent':
          onSearchQueryChanged(suggestion.title);
          break;
      }
    } catch (e) {
      AppLoggerHelper.error('Suggestion selection error: $e');
      Get.snackbar(
        'Error',
        'Could not load location details',
        backgroundColor: AppColors.error,
      );
    }
  }

  Future<void> _handleGooglePlaceSuggestion(SearchSuggestion suggestion) async {
    if (suggestion.placeId != null) {
      final details = await GooglePlacesService.getPlaceDetails(
        suggestion.placeId!,
      );
      if (details != null) {
        moveCameraToLatLng(details.location);
        _addMarkerForLocation(details.location, details.name);

        // Create a temporary place from Google Places data
        final tempPlace = _createTemporaryPlaceFromGoogleDetails(
          details,
          suggestion,
        );
        _showPlaceDetails(tempPlace);
      }
    } else if (suggestion.location != null) {
      moveCameraToLatLng(suggestion.location!);
      _addMarkerForLocation(suggestion.location!, suggestion.title);

      final tempPlace = _createTemporaryPlaceFromSuggestion(suggestion);
      _showPlaceDetails(tempPlace);
    }
  }

  Future<void> _handleAddressSuggestion(SearchSuggestion suggestion) async {
    if (suggestion.location != null) {
      moveCameraToLatLng(suggestion.location!);
      _addMarkerForLocation(suggestion.location!, suggestion.title);

      final address = await GooglePlacesService.getAddressFromLatLng(
        suggestion.location!,
      );
      final tempPlace = _createTemporaryPlaceFromSuggestion(
        suggestion,
        address: address,
      );
      _showPlaceDetails(tempPlace);
    }
  }

  PlaceModel _createTemporaryPlaceFromSuggestion(
    SearchSuggestion suggestion, {
    String? address,
  }) {
    return PlaceModel(
      id: 'temp_${suggestion.id}',
      title: suggestion.title,
      description: address ?? suggestion.subtitle ?? 'Location from search',
      address: AddressModel(
        id: 'temp_address_${suggestion.id}',
        name: suggestion.title,
        phoneNumber: '',
        street: _extractStreetFromAddress(address ?? suggestion.subtitle ?? ''),
        city: _extractCityFromAddress(address ?? suggestion.subtitle ?? ''),
        state: '',
        postalCode: '',
        country: _extractCountryFromAddress(
          address ?? suggestion.subtitle ?? '',
        ),
        latitude: suggestion.location?.latitude ?? 0.0,
        longitude: suggestion.location?.longitude ?? 0.0,
      ),
      categoryId: 'other',
      averageRating: suggestion.rating ?? 0.0,
      reviewsCount: suggestion.reviewCount ?? 0,
      userId: 'search_system',
      thumbnail: suggestion.photoReference != null
          ? GooglePlacesService.getPlacePhotoUrl(suggestion.photoReference!)
          : '',
      isFeatured: false,
      creatorName: 'Search Result',
      creatorAvatarUrl: '',
      likeCount: 0,
      followerCount: 0,
    );
  }

  PlaceModel _createTemporaryPlaceFromGoogleDetails(
    GooglePlaceDetails details,
    SearchSuggestion suggestion,
  ) {
    return PlaceModel(
      id: 'google_${details.placeId ?? suggestion.id}',
      title: details.name,
      description: details.address ?? 'Google Places location',
      address: AddressModel(
        id: 'google_address_${details.placeId}',
        name: details.name,
        phoneNumber: details.formattedPhoneNumber ?? '',
        street: _extractStreetFromAddress(details.address ?? ''),
        city: _extractCityFromAddress(details.address ?? ''),
        state: '',
        postalCode: '',
        country: _extractCountryFromAddress(details.address ?? ''),
        latitude: details.location.latitude,
        longitude: details.location.longitude,
      ),
      categoryId: details.category ?? 'other',
      averageRating: details.rating ?? 0.0,
      reviewsCount: details.totalRatings ?? 0,
      userId: 'google_places',
      thumbnail: details.photos.isNotEmpty ? details.photos.first : '',
      isFeatured: false,
      creatorName: 'Google Places',
      creatorAvatarUrl: '',
      likeCount: 0,
      followerCount: 0,
    );
  }

  void _showPlaceDetails(PlaceModel place) {
    selectedPlace.value = place;
    showBottomSheet.value = true;
    showLocationDetails.value = true;

    if (place.latitude != 0.0 && place.longitude != 0.0) {
      _addHighlightMarker(place);
    }
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
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
        ),
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

  // void moveCameraToLatLng(LatLng target) {
  //   googleMapController?.animateCamera(
  //     CameraUpdate.newCameraPosition(CameraPosition(zoom: 15, target: target)),
  //   );
  // }

  void moveToCurrentLocation() {
    if (currentLocation.value?.latitude != null) {
      final latLng = LatLng(
        currentLocation.value!.latitude!,
        currentLocation.value!.longitude!,
      );
      moveCameraToLatLng(latLng);
    }
  }

  void onMapTap(LatLng position) {
    if (!showBottomSheet.value) {
      pickedLocation.value = position;
      _updateSelectionMarker(position);
      _getLocationName(position.latitude, position.longitude);
    }
  }

  // Animate marker selection
  void animateToPlace(PlaceModel place) {
    if (place.latitude == 0.0 || place.longitude == 0.0) return;

    // Move camera to place
    moveCameraToLatLng(LatLng(place.latitude, place.longitude));

    // Highlight the place
    _onPlaceMarkerTapped(place);

    // Add bounce animation
    _bounceMarker(place.id);
  }

  void _bounceMarker(String placeId) {
    // You can implement a simple bounce effect by scaling the marker
    // This would require recreating the marker with different sizes
    // For now, we'll just ensure it's properly highlighted
    _createPlaceMarkers();
  }

  // void _updateSelectionMarker(LatLng position) {
  //   const markerId = MarkerId('selectedLocation');
  //   final selectionMarker = Marker(
  //     markerId: markerId,
  //     position: position,
  //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
  //     infoWindow: const InfoWindow(title: 'Selected Location'),
  //   );

  //   markers.removeWhere((m) => m.markerId == markerId);
  //   markers.add(selectionMarker);
  //   markers.refresh();
  // }

  void _updateSelectionMarker(LatLng position) async {
    const markerId = MarkerId('selectedLocation');
    final selectionMarker = Marker(
      markerId: markerId,
      position: position,
      icon: await CustomMarkerGenerator.getSelectedLocationMarker(),
      infoWindow: const InfoWindow(title: 'Selected Location'),
      zIndexInt: 1000,
      anchor: const Offset(0.5, 1.0),
    );

    markers.removeWhere((m) => m.markerId == markerId);
    markers.add(selectionMarker);
    markers.refresh();
  }

  void _addMarkerForLocation(LatLng location, String title) {
    final markerId = MarkerId(
      'search_result_${location.latitude}_${location.longitude}',
    );
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
        }
      },
      onError: (error) {
        AppLoggerHelper.error('Live Location Stream Error: $error');
      },
    );
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

  // --- UI CONTROLS ---
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

  void clearSearch() {
    searchQuery.value = '';
    searchSuggestions.clear();
    isSearching.value = false;
    showLocationDetails.value = false;
    selectedPlace.value = null;
    showBottomSheet.value = false;

    // Remove search result markers but keep place markers
    markers.removeWhere((m) => m.markerId.value.startsWith('search_result'));
    markers.refresh();

    // Reset to show all places
    displayedPlaces.assignAll(placeController.places);
    _createPlaceMarkers();
  }

  // --- RECENT SEARCHES ---
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
  }

  void _loadRecentSearches() {
    // Load from storage or use defaults
    recentSearches.addAll([
      RecentSearch(
        id: '1',
        query: 'Restaurants',
        type: 'search',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ]);
  }

  // --- PICKER MODE FUNCTIONALITY ---
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

// RecentSearch model
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
