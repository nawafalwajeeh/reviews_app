import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reviews_app/common/widgets/custom_shapes/containers/search_container.dart';
import 'package:reviews_app/features/review/controllers/map_controller.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

class MapScreen extends StatelessWidget {
  // Flag to enable the map location picking functionality
  final bool isPickerMode;
  const MapScreen({super.key, this.isPickerMode = false});

  // --- ADJUSTED PARAMETERS FOR CUSTOM MAP LOOK (From your design) ---
  static const double _headerContentHeight = 110.0;
  static const double _overlapAmount = 50.0;
  static const double _headerHeight = _headerContentHeight + 50.0; // 160.0
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final controller = MapController.instance;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Obx(() {
        // Wait until the controller has set a value (either actual or default)
        if (controller.currentLocation.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        debugPrint(
          'Current location: ${controller.currentLocation.value}, name: ${controller.locationName.value}',
        );

        // Define a fallback/initial position for the map widget itself
        // We will use the controller to move the camera later, but the widget needs *some* position.
        const initialMapPosition = CameraPosition(
          target: MapController.defaultLocation,
          zoom: 13.5,
        );

        return Stack(
          children: [
            // 1. Google Map Area (Clipped and Offset)
            Positioned.fill(
              // Ensure the map fills the appropriate area
              top: isPickerMode ? 0 : _headerHeight - _overlapAmount,
              child: ClipRRect(
                borderRadius: isPickerMode
                    ? BorderRadius.zero
                    : const BorderRadius.only(
                        topLeft: Radius.circular(AppSizes.cardRadiusLg),
                        topRight: Radius.circular(AppSizes.cardRadiusLg),
                      ),
                // Wrapping the map in a Container to force explicit constraints can sometimes help rendering issues
                child: Container(
                  // Give the container the size of the available space
                  color: AppColors
                      .lightGrey, // Background color while loading tiles
                  child: GoogleMap(
                    // Use a simple initial position, but rely on onMapCreated to set the final position
                    initialCameraPosition: initialMapPosition,

                    // CRITICAL FIX: The logic inside onMapCreated now handles the camera move.
                    onMapCreated: (mapCtrl) {
                      controller.onMapCreated(mapCtrl);

                      // Immediately animate to the initial/current location after map is created
                      // This prevents the map from freezing on a distant default view.
                      if (controller.currentLocation.value != null) {
                        final LatLng target = LatLng(
                          controller.currentLocation.value!.latitude!,
                          controller.currentLocation.value!.longitude!,
                        );
                        controller.googleMapController?.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(target: target, zoom: 13.5),
                          ),
                        );
                      }
                    },

                    onTap: isPickerMode ? controller.onMapTap : null,
                    markers: controller.markers.toSet(),
                    polylines: controller.polylines.toSet(),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    compassEnabled: true,
                    zoomControlsEnabled: true,
                    mapType: MapType.normal,
                  ),
                ),
              ),
            ),

            // 2. Floating Header Area (Handles Search Bar or Picker Title/Back Button)
            Positioned(
              top: AppSizes.spaceBtwSections,
              left: AppSizes.defaultSpace,
              right: AppSizes.defaultSpace,
              child: isPickerMode
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.98),
                        borderRadius: BorderRadius.circular(
                          AppSizes.cardRadiusLg,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkGrey.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.darkGrey,
                            ),
                            onPressed: () => Get.back(),
                          ),
                          Expanded(
                            child: Text(
                              'Pick Location',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const AppSearchContainer(text: 'Search for location'),
            ),

            // 3. Confirmation Button (Visible only in Picker Mode)
            if (isPickerMode)
              Positioned(
                bottom: AppSizes.defaultSpace,
                left: AppSizes.defaultSpace,
                right: AppSizes.defaultSpace,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.pickedLocation.value == null
                        ? null
                        : controller
                              .savePickedLocation, // Calls Get.back(result: LatLng)
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.md,
                      ),
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.cardRadiusLg,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Confirm Location',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

//------------------------------------
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:reviews_app/common/widgets/custom_shapes/containers/search_container.dart';
// import 'package:reviews_app/utils/constants/colors.dart';
// import 'package:reviews_app/utils/constants/sizes.dart';

// import '../../controllers/map_controller.dart';

// class MapScreen extends StatelessWidget {
//   const MapScreen({super.key});

//   // --- ADJUSTED PARAMETERS FOR COMPACT LOOK ---
//   static const double _headerContentHeight = 110.0;
//   // How much the map should overlap the header's curved bottom.
//   static const double _overlapAmount = 50.0;
//   // Total vertical space occupied by the header (110 + 50 = 160)
//   static const double _headerHeight = _headerContentHeight + 50.0;
//   // ---------------------------------------------

//   @override
//   Widget build(BuildContext context) {
//     // find the MapController
//     final controller = MapController.instance;

//     return Scaffold(
//       backgroundColor: AppColors.white,
//       body: Stack(
//         children: [
//           /// -- Header & Search Bar
//           const Positioned(
//             top: AppSizes.spaceBtwSections,
//             left: 0,
//             right: 0,
//             child: AppSearchContainer(text: 'Search for location'),
//           ),

//           /// -- Map Area (Positioned.fill to fill remaining space)
//           Positioned.fill(
//             // Position the map start slightly *above* the bottom of the header
//             // to create the overlap effect and reduce the gap.
//             top: _headerHeight - _overlapAmount,
//             child: Obx(() {
//               // Check if initial location data is available
//               if (controller.currentLocation.value == null) {
//                 return Center(
//                   child: CircularProgressIndicator(
//                     color: AppColors.primaryColor,
//                   ),
//                 );
//               }

//               /// Wrap Map in ClipRRect to apply borderRadius
//               return ClipRRect(
//                 borderRadius: const BorderRadius.all(
//                   Radius.circular(AppSizes.cardRadiusLg),
//                 ),
//                 child: GoogleMap(
//                   initialCameraPosition: CameraPosition(
//                     target: LatLng(
//                       controller.currentLocation.value!.latitude!,
//                       controller.currentLocation.value!.longitude!,
//                     ),
//                     zoom: 13.5,
//                   ),
//                   // Markers and Polylines
//                   markers: controller.markers,
//                   polylines: controller.polylines,

//                   // Pass the map controller instance to the GetX controller
//                   onMapCreated: controller.onMapCreated,

//                   // Optional: Show default controls
//                   myLocationEnabled: true,
//                   zoomControlsEnabled: true,
//                   // mapType: MapType.normal,
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
// }
