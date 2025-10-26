import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:reviews_app/utils/constants/api_constants.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/logging/logger.dart';

class MapController extends GetxController {
  static MapController get instance => Get.find();

  /// Variables
  // Location data, starts as null
  final currentLocation = Rx<LocationData?>(null);

  // Set of Markers to display on the map
  final markers = <Marker>{}.obs;

  // Set of Polylines to display the route
  final polylines = <Polyline>{}.obs;

  // Storage for the stream subscription to cancel it on dispose
  StreamSubscription<LocationData>? _locationSubscription;

  // Google Map Controller instance (now private)
  final mapControllerCompleter = Completer<GoogleMapController>();
  GoogleMapController? _googleMapController; // Made private for safer access

  /// -- Static/ Helper Variables
  static const LatLng sourceLocation = LatLng(13.57952, 44.02091);
  static const LatLng destination = LatLng(12.77944, 45.03667);

  // Marker Icons (Initial marker objects)
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  /// -- Lifecycle and Initialization
  @override
  void onInit() {
    super.onInit();
    // These functions now handle waiting for the map controller internally.
    getCurrentLocation();
    getPolyPoints();
  }

  /// -- Location and Camera Logic
  void onMapCreated(GoogleMapController controller) {
    // Prevent "Bad state: Future already completed" error during hot restart.
    if (!mapControllerCompleter.isCompleted) {
      _googleMapController = controller;
      mapControllerCompleter.complete(controller);
      AppLoggerHelper.info("MapController successfully created and completed.");
      // Perform initial camera animation here if needed.
    }
  }

  void getCurrentLocation() async {
    final location = Location();
    GoogleMapController? mapController;

    // Wait for the map to be created before trying to animate the initial camera.
    try {
      mapController = await mapControllerCompleter.future;
    } catch (e) {
      AppLoggerHelper.error(
        'Map was disposed before location could be fetched.',
      );
      return;
    }

    // Check/Request Permissions and Initial Fetch ---
    try {
      LocationData initialLocation = await location.getLocation();
      currentLocation.value = initialLocation;

      AppLoggerHelper.info(
        'Initial location fetched: ${initialLocation.latitude}, ${initialLocation.longitude}',
      );

      // Use the awaited controller to animate the camera immediately after finding location
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 13.5,
            target: LatLng(
              initialLocation.latitude!,
              initialLocation.longitude!,
            ),
          ),
        ),
      );
    } on PlatformException catch (e) {
      AppLoggerHelper.error(
        'Initial Location Fetch Error: ${e.message} (Code: ${e.code})',
      );
      return;
    }

    // Start the live listener
    _locationSubscription = location.onLocationChanged.listen(
      (newLocation) {
        currentLocation.value = newLocation;

        // Now it is safe to use the mapController here.
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 13.5,
              target: LatLng(newLocation.latitude!, newLocation.longitude!),
            ),
          ),
        );
        _updateAllMarkers();
      },
      // Exception Handling for the Stream
      onError: (error) {
        if (error is PlatformException) {
          AppLoggerHelper.error(
            'Live Location Stream Platform Error: ${error.message} (Code: ${error.code})',
          );
        } else {
          AppLoggerHelper.error('Live Location Stream General Error: $error');
        }
      },
      cancelOnError: false,
    );
  }

  /// -- Polyline (Route) Logic
  void getPolyPoints() async {
    // Wait for map controller to be ready (though not strictly needed for the API call,
    // it ensures the whole process is correctly synchronized).

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
        for (var route in result.routes) {
          if (route.polylinePoints != null) {
            for (var point in route.polylinePoints!) {
              polylineCoordinates.add(LatLng(point.latitude, point.longitude));
            }
          }
        }

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

  /// -- Central Marker Update Function
  void _updateAllMarkers() {
    if (currentLocation.value == null) return;

    markers.assignAll({
      Marker(
        markerId: const MarkerId('currentLocation'),
        icon: currentLocationIcon,
        position: LatLng(
          currentLocation.value!.latitude!,
          currentLocation.value!.longitude!,
        ),
      ),
      // Source Marker
      Marker(
        markerId: const MarkerId('source'),
        icon: sourceIcon,
        position: sourceLocation,
      ),
      // Destination Marker (Place of interest)
      Marker(
        markerId: const MarkerId('destination'),
        icon: destinationIcon,
        position: destination,
      ),
    });
  }

  @override
  void onClose() {
    _locationSubscription?.cancel();
    AppLoggerHelper.warning("Location stream subscription cancelled.");

    // Call dispose on the heavy map object itself.
    if (_googleMapController != null) {
      _googleMapController!.dispose();
      AppLoggerHelper.info("Disposing mapController to prevent memory leak.");
    }
    super.onClose();
  }
}
