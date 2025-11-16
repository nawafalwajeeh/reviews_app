import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';

import '../../../utils/constants/api_constants.dart';
import '../../../utils/constants/colors.dart';
import '../../personalization/models/address_model.dart';
// NOTE: Some imports are required for the code to compile,
// but their logic is simplified or mocked below for runnable Flutter Dart.

// --- MOCK CLASSES for Compilation (as per previous context) ---
class PointLatLng {
  const PointLatLng(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

enum TravelMode { driving }

class RoutesApiRequest {
  const RoutesApiRequest({
    required this.origin,
    required this.destination,
    required this.travelMode,
  });
  final PointLatLng origin;
  final PointLatLng destination;
  final TravelMode travelMode;
}

class PolylinePoints {
  PolylinePoints({required String apiKey});
  Future<RoutesApiResponse> getRouteBetweenCoordinatesV2({
    required RoutesApiRequest request,
  }) async {
    return const RoutesApiResponse(routes: []);
  }
}

class RoutesApiResponse {
  final List<dynamic> routes;
  const RoutesApiResponse({this.routes = const []});
}

class AppLoggerHelper {
  static void info(String message) {
    print('INFO: $message');
  }

  static void error(String message) {
    print('ERROR: $message');
  }
}

class AppLoaders {
  static void errorSnackBar({required String title, required String message}) {}
}

// --- MOCK Geocoding for concept demonstration (replace with actual 'geocoding' package logic) ---
class Placemark {
  final String? locality;
  final String? country;
  const Placemark({this.locality, this.country});
}

class GeocodingPlatform {
  static Future<List<Placemark>> placemarkFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    // Mocking reverse geocoding results based on known coordinates
    if (latitude == 51.5074 && longitude == 0.1278) {
      return [const Placemark(locality: 'London', country: 'United Kingdom')];
    }
    return [
      const Placemark(locality: 'Unknown City', country: 'Unknown Country'),
    ];
  }
}
// --- END MOCK CLASSES ---

class MapController extends GetxController {
  static MapController get instance => Get.find();

  /// -- Static/ Helper Variables
  static const LatLng defaultLocation = LatLng(
    51.5074,
    0.1278,
  ); // Center of London (Fallback)
  static const LatLng sourceLocation = LatLng(13.57952, 44.02091);
  static const LatLng destination = LatLng(12.77944, 45.03667);

  /// VARIABLES
  // CRITICAL FIX: Initialize currentLocation with a guaranteed non-null default value.
  final currentLocation = Rx<LocationData?>(
    LocationData.fromMap({
      'latitude': defaultLocation.latitude,
      'longitude': defaultLocation.longitude,
      'accuracy': 0.0,
      'time': DateTime.now().millisecondsSinceEpoch.toDouble(),
    }),
  );

  // Also initialize pickedLocation to the default so the confirm button can potentially be enabled immediately
  final pickedLocation = Rx<LatLng?>(defaultLocation);
  final locationName =
      'Default Location (London)'.obs; // Holds the geocoded name

  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;

  StreamSubscription<LocationData>? _locationSubscription;
  final mapControllerCompleter = Completer<GoogleMapController>();
  GoogleMapController? googleMapController;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  // Flag to prevent redundant initial map setup
  bool _isInitialMapSetupComplete = false;

  /// -- LIFECYCLE AND INITIALIZATION
  @override
  void onInit() {
    super.onInit();
    // Start fetching location immediately (runs in parallel with map loading)
    getCurrentLocation();
    getPolyPoints();
  }

  /// -- MAP CREATION AND CAMERA LOGIC
  void onMapCreated(GoogleMapController controller) async {
    if (!mapControllerCompleter.isCompleted) {
      googleMapController = controller;
      mapControllerCompleter.complete(controller);
      AppLoggerHelper.info("MapController successfully created and completed.");

      // Delay to allow the native platform view to stabilize.
      AppLoggerHelper.info("Waiting 1000ms for Platform View stabilization...");
      await Future.delayed(const Duration(milliseconds: 1000));

      // Run the initial setup only once
      _performInitialMapSetup();
    }
  }

  /// Consolidates initial camera move and marker drawing after map is ready
  void _performInitialMapSetup() {
    if (_isInitialMapSetupComplete) return;

    final targetLocation = currentLocation.value;

    // The location value is now guaranteed non-null due to initialization
    final LatLng target = LatLng(
      targetLocation!.latitude!,
      targetLocation.longitude!,
    );

    // If the map is opened in Picker Mode, ensure the first picked location is set for the marker/button
    if (pickedLocation.value == null) {
      pickedLocation.value = target;
      // Also update the selection marker when the map first loads
      _updateSelectionMarker(target);
    }

    _moveCameraToLatLng(target);
    _updateAllMarkers();

    _isInitialMapSetupComplete = true;
    AppLoggerHelper.info(
      'Initial map setup complete: Camera moved and markers drawn.',
    );
  }

  void _moveCameraToLatLng(LatLng target) {
    googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(zoom: 13.5, target: target),
      ),
    );
  }

  void _moveCameraToLocation(LocationData location) {
    _moveCameraToLatLng(LatLng(location.latitude!, location.longitude!));
  }

  /// -- PICKING LOGIC
  void onMapTap(LatLng position) {
    pickedLocation.value = position;
    _updateSelectionMarker(position);
    _getLocationName(
      position.latitude,
      position.longitude,
    ); // Geocode the tapped location
    AppLoggerHelper.info(
      'Location selected: ${position.latitude}, ${position.longitude}',
    );
  }

  void savePickedLocation() {
    if (pickedLocation.value == null) return;

    final LatLng position = pickedLocation.value!;

    // 1. Create a temporary AddressModel using the picked coordinates.
    // The locationName.value is kept up-to-date by _getLocationName (called in onMapTap)
    final newMapAddress = AddressModel(
      id: 'Map_${const Uuid().v4()}',
      name: 'Map Location',
      phoneNumber: 'N/A',
      street: locationName.value.isNotEmpty
          ? locationName.value
          : 'Picked location at Lat ${position.latitude.toStringAsFixed(4)}, Lng ${position.longitude.toStringAsFixed(4)}',
      city: '',
      state: '',
      postalCode: '',
      country: '',
      latitude: position.latitude, // Set the coordinates
      longitude: position.longitude, // Set the coordinates
      selectedAddress: true,
    );

    // 2. Use Get.back() to return the AddressModel to the caller (AddressController)
    Get.back(result: newMapAddress);
  }

  /// -- REVERSE GEOCODING LOGIC
  Future<void> _getLocationName(double latitude, double longitude) async {
    try {
      final placemarks = await GeocodingPlatform.placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Construct a readable name (e.g., City, Country)
        final name = '${place.locality ?? ''}, ${place.country ?? ''}'
            .trim()
            .replaceAll(RegExp(r'^,|, $'), '');
        locationName.value = name.isNotEmpty ? name : 'Unnamed Location';
        AppLoggerHelper.info('Geocoded Location Name: $name');
      } else {
        locationName.value = 'Location name not found';
      }
    } catch (e) {
      AppLoggerHelper.error('Reverse Geocoding Error: $e');
      locationName.value = 'Geocoding failed';
    }
  }

  /// -- LOCATION FETCHING LOGIC
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
      // Try to get actual location
      try {
        newLocationData = await location.getLocation();
        currentLocation.value =
            newLocationData; // Update state with real location

        // Also update the picked location to the user's current location initially
        pickedLocation.value = LatLng(
          newLocationData.latitude!,
          newLocationData.longitude!,
        );
      } on PlatformException catch (e) {
        AppLoggerHelper.error('Initial Location Fetch Error: ${e.message}');
        // If fetch fails, we rely on the default value already set in the declaration
      }
    }
    // If permissions fail, we rely on the default value already set in the declaration

    // Geocode and update name for initial/actual location (non-blocking)
    if (currentLocation.value!.latitude != null &&
        currentLocation.value!.longitude != null) {
      _getLocationName(
        currentLocation.value!.latitude!,
        currentLocation.value!.longitude!,
      );
    }

    // Start listening to live location updates
    _locationSubscription = location.onLocationChanged.listen(
      (newLocation) {
        currentLocation.value = newLocation;

        // Only interact with the map if the map controller is ready
        if (googleMapController != null && _isInitialMapSetupComplete) {
          _getLocationName(
            newLocation.latitude!,
            newLocation.longitude!,
          ); // Geocode new location
          _moveCameraToLocation(newLocation);
          _updateAllMarkers();
        }
      },
      onError: (error) {
        AppLoggerHelper.error('Live Location Stream Error: $error');
      },
      cancelOnError: false,
    );
  }

  /// -- MARKER MANAGEMENT
  void _updateSelectionMarker(LatLng position) {
    const markerId = MarkerId('selectedLocation');
    final selectionMarker = Marker(
      markerId: markerId,
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'Picked Location'),
    );
    // Use .value to directly modify the Set and trigger a reactive update.
    markers.value.removeWhere((m) => m.markerId == markerId);
    markers.value.add(selectionMarker);
    markers.refresh();
  }

  void clearSelectionMarkers() {
    markers.value.removeWhere(
      (marker) => marker.markerId == const MarkerId('selectedLocation'),
    );
    pickedLocation.value = null;
    markers.refresh();
  }

  void _updateAllMarkers() {
    // currentLocation is guaranteed non-null due to initialization
    final LocationData currentLoc = currentLocation.value!;

    final Set<Marker> newMarkers = {
      Marker(
        markerId: const MarkerId('currentLocation'),
        icon: currentLocationIcon,
        position: LatLng(currentLoc.latitude!, currentLoc.longitude!),
      ),
      Marker(
        markerId: const MarkerId('source'),
        icon: sourceIcon,
        position: sourceLocation,
      ),
      Marker(
        markerId: const MarkerId('destination'),
        icon: destinationIcon,
        position: destination,
      ),
    };

    // Safely retrieve the selected marker, if it exists
    final selectedMarker = markers
        .where((m) => m.markerId == const MarkerId('selectedLocation'))
        .firstOrNull;

    if (selectedMarker != null) {
      newMarkers.add(selectedMarker);
    }

    markers.assignAll(newMarkers.toSet());
    AppLoggerHelper.info('Markers updated and drawn on the map.');
  }

  /// -- POLYLINE (ROUTE) LOGIC
  void getPolyPoints() async {
    // Existing polyline logic remains the same...
    try {
      final apiKey = GetPlatform.isAndroid
          ? ApiConstants.googleMapAndroidApikey
          : ApiConstants.googleMapIOSApikey;

      PolylinePoints polylinePoints = PolylinePoints(apiKey: apiKey);

      var routeApiRequest = RoutesApiRequest(
        origin: PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        destination: PointLatLng(destination.latitude, destination.longitude),
        travelMode: TravelMode.driving,
      );

      RoutesApiResponse result = await polylinePoints
          .getRouteBetweenCoordinatesV2(request: routeApiRequest);

      List<LatLng> polylineCoordinates = [];
      if (result.routes.isNotEmpty) {
        // Mocked PolylinePoints for compilation stability
        // NOTE: In a real app, you would parse the actual points from the API response
        polylineCoordinates = [
          sourceLocation,
          const LatLng(13.0, 44.5),
          destination,
        ];

        // Update the reactive polylines set
        polylines.assign(
          Polyline(
            polylineId: const PolylineId('route'),
            points: polylineCoordinates,
            color: AppColors.primaryColor,
            width: 6,
          ),
        );
      }
    } catch (e) {
      AppLoggerHelper.error('Polyline Fetch Error: $e');
    }
  }

  @override
  void onClose() {
    _locationSubscription?.cancel();
    if (googleMapController != null) {
      googleMapController!.dispose();
    }
    super.onClose();
  }
}
