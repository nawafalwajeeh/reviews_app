import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reviews_app/common/widgets/custom_shapes/containers/primary_header_container.dart';
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
            top: 0,
            left: 0,
            right: 0,
            // Use the calculated, fixed height for the PrimaryHeaderContainer
            height: _headerHeight,
            child: AppPrimaryHeaderContainer(
              child: Column(
                children: [
                  // Reduced top spacing for a more compact look
                  SizedBox(height: AppSizes.lg),

                  // Wrap SearchContainer in Padding to keep it off the edges
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.defaultSpace,
                    ),
                    child: AppSearchContainer(text: 'Search for location'),
                  ),

                  // Reduced bottom spacing inside the header
                  SizedBox(height: AppSizes.spaceBtwItems),
                ],
              ),
            ),
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

//------------------------------
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:reviews_app/common/widgets/custom_shapes/containers/primary_header_container.dart';
// import 'package:reviews_app/common/widgets/custom_shapes/containers/search_container.dart';
// import 'package:reviews_app/utils/constants/colors.dart';
// import 'package:reviews_app/utils/constants/sizes.dart';

// import '../../controllers/map_controller.dart';

// class MapScreen extends StatelessWidget {
//   const MapScreen({super.key});

//   // Define the height of the container *before* the curve starts.
//   // We'll set this generously and let the internal clipper handle the curve.
//   static const double _headerContentHeight = 170.0; // Adjusted for content
//   static const double _overlapAmount =
//       35.0; // How much the map overlaps the header

//   @override
//   Widget build(BuildContext context) {
//     // Initialize the MapController and make it available across the screen
//     final controller = MapController.instance;

//     return Scaffold(
//       backgroundColor: AppColors.white,
//       body: Stack(
//         children: [
//           /// -- Header & Search Bar
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             height: _headerContentHeight + 80,
//             // height: _headerHeight, // Forces the header to a fixed height
//             child: const AppPrimaryHeaderContainer(
//               child: Column(
//                 children: [
//                   SizedBox(height: AppSizes.lg * 1.5),
//                   AppSearchContainer(text: 'Search for location'),
//                   SizedBox(height: AppSizes.spaceBtwSections),
//                 ],
//               ),
//             ),
//           ),

//           /// -- Map Area (Expanded)
//           // Use Obx to listen to the reactive state variables
//           Positioned.fill(
//             // top: _headerHeight - 25,
//             top: _headerContentHeight + _overlapAmount,
//             child: Obx(() {
//               // Check if initial location data is available
//               if (controller.currentLocation.value == null) {
//                 return Center(
//                   child: CircularProgressIndicator(
//                     color: AppColors.primaryColor,
//                   ),
//                 );
//               }

//               // Once location data is ready, display the map
//               return GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: LatLng(
//                     controller.currentLocation.value!.latitude!,
//                     controller.currentLocation.value!.longitude!,
//                   ),
//                   zoom: 13.5,
//                 ),
//                 // Markers are updated automatically when markers.value changes in the controller
//                 markers: controller.markers,

//                 // Polylines are updated automatically when polylines.value changes
//                 polylines: controller.polylines,

//                 // Pass the map controller instance to the GetX controller
//                 onMapCreated: controller.onMapCreated,

//                 // Optional: Show default controls
//                 myLocationEnabled: true,
//                 zoomControlsEnabled: false,
//                 mapType: MapType.normal,
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
// }
