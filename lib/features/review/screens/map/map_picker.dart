import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reviews_app/common/widgets/custom_shapes/containers/search_container.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

import '../../controllers/map_controller.dart';

// Data model for returning location result
class MapLocationResult {
  final String address;
  final double latitude;
  final double longitude;

  MapLocationResult({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

class MapPickerScreen extends StatelessWidget {
  const MapPickerScreen({super.key});

  static const double _headerContentHeight = 110.0;
  static const double _overlapAmount = 50.0;
  static const double _headerHeight = _headerContentHeight + 50.0;

  @override
  Widget build(BuildContext context) {
    final controller = MapController.instance;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          /// -- Header & Search Bar
          Positioned(
            top: AppSizes.spaceBtwSections,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const AppSearchContainer(text: 'Search for location'),
                const SizedBox(height: AppSizes.spaceBtwItems),

                // Selection Instructions
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.defaultSpace,
                  ),
                  child: Text(
                    'Tap on the map to select a location',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.darkGrey),
                  ),
                ),
              ],
            ),
          ),

          /// -- Map Area
          Positioned.fill(
            top: _headerHeight - _overlapAmount,
            child: Obx(() {
              if (controller.currentLocation.value == null) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }

              return ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppSizes.cardRadiusLg),
                ),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      controller.currentLocation.value!.latitude!,
                      controller.currentLocation.value!.longitude!,
                    ),
                    zoom: 13.5,
                  ),
                  markers: controller.markers,
                  polylines: controller.polylines,
                  onMapCreated: controller.onMapCreated,

                  // Add tap listener for location selection
                  onTap: (LatLng position) {
                    _handleMapTap(position, controller);
                  },

                  myLocationEnabled: true,
                  zoomControlsEnabled: true,
                ),
              );
            }),
          ),

          /// -- Selection Marker
          Positioned(
            top:
                _headerHeight -
                _overlapAmount +
                MediaQuery.of(context).size.height / 2 -
                30,
            left: MediaQuery.of(context).size.width / 2 - 15,
            child: const Icon(
              Icons.location_pin,
              color: AppColors.primaryColor,
              size: 30,
            ),
          ),

          /// -- Confirm Button
          Positioned(
            bottom: AppSizes.spaceBtwSections,
            left: AppSizes.defaultSpace,
            right: AppSizes.defaultSpace,
            child: ElevatedButton(
              onPressed: () => _confirmLocationSelection(controller),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                ),
              ),
              child: const Text(
                'Confirm Location',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMapTap(LatLng position, MapController controller) {
    // Add a marker at the tapped position
    controller.markers.add(
      Marker(
        markerId: const MarkerId('selectedLocation'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Selected Location'),
      ),
    );

    // Move camera to tapped position
    controller.googleMapController?.animateCamera(
      CameraUpdate.newLatLng(position),
    );
  }

  void _confirmLocationSelection(MapController controller) async {
    try {
      // Find the selected location marker
      final selectedMarker = controller.markers.firstWhere(
        (marker) => marker.markerId == const MarkerId('selectedLocation'),
        orElse: () => throw Exception('No location selected'),
      );

      // Get the address using reverse geocoding
      final address = await _reverseGeocode(selectedMarker.position);

      // Return the result to the previous screen
      Get.back(
        result: MapLocationResult(
          address: address,
          latitude: selectedMarker.position.latitude,
          longitude: selectedMarker.position.longitude,
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Selection Required',
        'Please tap on the map to select a location first.',
        backgroundColor: AppColors.favoriteColor,
        colorText: AppColors.white,
      );
    }
  }

  Future<String> _reverseGeocode(LatLng position) async {
    // In a real app, you would use a geocoding service here
    // For now, we'll return a mock address based on coordinates

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock reverse geocoding - in real app, use Google Geocoding API or similar
      return 'Selected Location (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';

      // Real implementation would look like:
      // final coordinates = Coordinates(position.latitude, position.longitude);
      // final addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      // final first = addresses.first;
      // return "${first.addressLine}";
    } catch (e) {
      // Fallback if geocoding fails
      return 'Location at ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
    }
  }
}
