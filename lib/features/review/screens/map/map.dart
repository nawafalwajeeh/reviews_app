import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reviews_app/common/widgets/custom_shapes/containers/search_container.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

import '../../controllers/map_controller.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  // --- ADJUSTED PARAMETERS FOR COMPACT LOOK ---
  static const double _headerContentHeight = 110.0;
  // How much the map should overlap the header's curved bottom.
  static const double _overlapAmount = 50.0;
  // Total vertical space occupied by the header (110 + 50 = 160)
  static const double _headerHeight = _headerContentHeight + 50.0;
  // ---------------------------------------------

  @override
  Widget build(BuildContext context) {
    // find the MapController
    final controller = MapController.instance;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          /// -- Header & Search Bar
          const Positioned(
            top: AppSizes.spaceBtwSections,
            left: 0,
            right: 0,
            child: AppSearchContainer(text: 'Search for location'),
          ),

          /// -- Map Area (Positioned.fill to fill remaining space)
          Positioned.fill(
            // Position the map start slightly *above* the bottom of the header
            // to create the overlap effect and reduce the gap.
            top: _headerHeight - _overlapAmount,
            child: Obx(() {
              // Check if initial location data is available
              if (controller.currentLocation.value == null) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }

              /// Wrap Map in ClipRRect to apply borderRadius
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
                  // Markers and Polylines
                  markers: controller.markers,
                  polylines: controller.polylines,

                  // Pass the map controller instance to the GetX controller
                  onMapCreated: controller.onMapCreated,

                  // Optional: Show default controls
                  myLocationEnabled: true,
                  zoomControlsEnabled: true,
                  // mapType: MapType.normal,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
