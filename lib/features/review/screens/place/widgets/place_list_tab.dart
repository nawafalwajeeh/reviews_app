import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/utils/constants/sizes.dart' show AppSizes;

import '../../../../../common/widgets/place/place_card.dart';
import '../../../../../common/widgets/shimmers/big_card_shimmer.dart'
    show PlaceCardShimmer;
import '../../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../controllers/place_controller.dart';
import '../edit_place.dart';

// --- NEW HELPER WIDGET ---
/// A stateless wrapper that executes a callback immediately after the first frame
/// is built, preventing 'setState during build' errors for initial data loading.
class StatelessInitWrapper extends StatelessWidget {
  const StatelessInitWrapper({
    super.key,
    required this.onInit,
    required this.child,
  });

  final VoidCallback onInit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // CRITICAL: Schedule the state-changing call for the next frame.
    // This allows the current build cycle to complete successfully.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onInit();
    });
    return child;
  }
}
// -------------------------

class PlaceListTab extends StatelessWidget {
  PlaceListTab({super.key, required this.categoryId});

  final String categoryId;

  // Get the controller instance once
  final controller = PlaceController.instance;

  @override
  Widget build(BuildContext context) {
    return StatelessInitWrapper(
      // 1. We move the problematic call here.
      onInit: () {
        controller.streamPlacesForCategory(categoryId);
      },

      // 2. The child contains the reactive UI (Obx)
      child: Obx(() {
        final categoryPlaces = controller.categoryPlaces;
        final isLoading = controller.isLoading.value;

        // 1. HANDLE LOADING STATE
        if (isLoading && categoryPlaces.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.defaultSpace,
              vertical: AppSizes.defaultSpace / 2,
            ),
            child: PlaceCardShimmer(),
          );
        }

        // 2. HANDLE NO DATA FOUND STATE
        if (categoryPlaces.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.defaultSpace),
              child: Text(
                'No places found in this category.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // 3. DATA FOUND STATE (Success)
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.defaultSpace,
            vertical: AppSizes.defaultSpace / 2,
          ),
          itemCount: categoryPlaces.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSizes.spaceBtwSections),
          itemBuilder: (context, index) {
            final place = categoryPlaces[index];

            // Determine if the current user is the creator
            bool isCreator =
                (place.userId == AuthenticationRepository.instance.getUserID);

            return PlaceCard(
              place: place,
              showEditOptions: isCreator,
              onEdit: () {
                if (isCreator) {
                  controller.initializeEditForm(place);
                  Get.to(() => EditPlaceScreen(place: place));
                }
              },
              onDelete: () {
                if (isCreator) {
                  controller.deletePlaceWithConfirmation(place);
                }
              },
            );
          },
        );
      }),
    );
  }
}

//--------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:get/get.dart'; // Needed for GetX reactive widgets
// import 'package:reviews_app/utils/constants/sizes.dart' show AppSizes;
// import '../../../../../common/widgets/place/place_card.dart';
// import '../../../../../common/widgets/shimmers/big_card_shimmer.dart'
//     show PlaceCardShimmer;
// import '../../../../../data/repositories/authentication/authentication_repository.dart';
// import '../../../controllers/place_controller.dart';
// import '../edit_place.dart';

// class PlaceListTab extends StatelessWidget {
//   PlaceListTab({super.key, required this.categoryId});

//   final String categoryId;

//   // Get the controller instance once
//   final controller = PlaceController.instance;

//   @override
//   Widget build(BuildContext context) {
//     // 1. CRITICAL: Initialize the stream.
//     // Calling this here ensures the data stream starts whenever this tab is visible/built.
//     // The controller handles cancellation internally when a new categoryId comes in.
//     controller.streamPlacesForCategory(categoryId);

//     // 2. Use Obx to listen to the observable list in the controller.
//     return Obx(() {
//       final categoryPlaces = controller.categoryPlaces;
//       final isLoading = controller.isLoading.value;

//       // 1. HANDLE LOADING STATE
//       if (isLoading && categoryPlaces.isEmpty) {
//         return const Padding(
//           padding: EdgeInsets.symmetric(
//             horizontal: AppSizes.defaultSpace,
//             vertical: AppSizes.defaultSpace / 2,
//           ),
//           child: PlaceCardShimmer(),
//         );
//       }

//       // 2. HANDLE NO DATA FOUND STATE
//       if (categoryPlaces.isEmpty) {
//         return const Center(
//           child: Padding(
//             padding: EdgeInsets.all(AppSizes.defaultSpace),
//             child: Text(
//               'No places found in this category.',
//               textAlign: TextAlign.center,
//             ),
//           ),
//         );
//       }

//       // 3. DATA FOUND STATE (Success)
//       // This ListView rebuilds automatically when 'categoryPlaces' changes
//       return ListView.separated(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.symmetric(
//           horizontal: AppSizes.defaultSpace,
//           vertical: AppSizes.defaultSpace / 2,
//         ),
//         itemCount: categoryPlaces.length,
//         separatorBuilder: (_, __) =>
//             const SizedBox(height: AppSizes.spaceBtwSections),
//         itemBuilder: (context, index) {
//           final place = categoryPlaces[index];

//           // Determine if the current user is the creator
//           bool isCreator =
//               (place.userId == AuthenticationRepository.instance.getUserID);

//           return PlaceCard(
//             place: place,
//             showEditOptions: isCreator,
//             onEdit: () {
//               if (isCreator) {
//                 // Initialize the edit form data before navigating
//                 controller.initializeEditForm(place);
//                 // Use Get.to() for navigation
//                 Get.to(() => EditPlaceScreen(place: place));
//               }
//             },
//             onDelete: () {
//               if (isCreator) {
//                 controller.deletePlaceWithConfirmation(place);
//               }
//             },
//           );
//         },
//       );
//     });
//   }
// }

//-----------------------
// import 'package:flutter/material.dart';
// import 'package:reviews_app/utils/constants/sizes.dart' show AppSizes;
// import '../../../../../common/widgets/place/place_card.dart';
// import '../../../../../common/widgets/shimmers/big_card_shimmer.dart'
//     show PlaceCardShimmer;
// import '../../../../../data/repositories/authentication/authentication_repository.dart';
// import '../../../../../data/repositories/place/place_repository.dart';
// import '../../../controllers/place_controller.dart';
// import '../../../models/place_model.dart';
// import '../edit_place.dart';

// class PlaceListTab extends StatelessWidget {
//   const PlaceListTab({super.key, required this.categoryId});

//   final String categoryId;

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<PlaceModel>>(
//       future: PlaceRepository.instance.getPlacesForCategory(
//         categoryId,
//         limit: -1,
//       ),
//       builder: (_, snapshot) {
//         // 1. HANDLE LOADING STATE
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Padding(
//             padding: EdgeInsets.symmetric(
//               horizontal: AppSizes.defaultSpace,
//               vertical: AppSizes.defaultSpace / 2,
//             ),
//             child: PlaceCardShimmer(),
//           );
//         }

//         // 2. HANDLE ERROR STATE (Display a friendly, hidden error message)
//         if (snapshot.hasError) {
//           // Display a generic error message as requested, DO NOT show the exception details
//           return const Center(
//             child: Padding(
//               padding: EdgeInsets.all(AppSizes.defaultSpace),
//               child: Text(
//                 'Failed to load data. Please check your network or try again later.',
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           );
//         }

//         // 3. HANDLE NO DATA FOUND STATE (The FIX for empty data)
//         final filteredPlaces = snapshot.data;
//         if (filteredPlaces == null || filteredPlaces.isEmpty) {
//           // Display "No data found" as requested by the user.
//           return const Center(
//             child: Padding(
//               padding: EdgeInsets.all(AppSizes.defaultSpace),
//               child: Text('No data found.', textAlign: TextAlign.center),
//             ),
//           );
//         }

//         // 4. DATA FOUND STATE (Success)
//         // Return the successful list view (ListView.separated)
//         return ListView.separated(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.symmetric(
//             horizontal: AppSizes.defaultSpace,
//             vertical: AppSizes.defaultSpace / 2,
//           ),
//           itemCount: filteredPlaces.length,
//           separatorBuilder: (_, _) =>
//               const SizedBox(height: AppSizes.spaceBtwSections),
//           itemBuilder: (context, index) {
//             final place = filteredPlaces[index];

//             bool isCreator = false;
//             final creatorId = place.userId;
//             final currentUserId = AuthenticationRepository.instance.getUserID;

//             if (creatorId == currentUserId) {
//               isCreator = true;
//             }

//             debugPrint(
//               'currentUserId: $currentUserId, creatorId: $creatorId ,isCreator: $isCreator',
//             );

//             return PlaceCard(
//               place: place,
//               showEditOptions: isCreator,
//               onEdit: () {
//                 if (isCreator) {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => EditPlaceScreen(place: place),
//                     ),
//                   );
//                 }
//               },

//               onDelete: () => isCreator
//                   ? PlaceController.instance.deletePlaceWithConfirmation(place)
//                   : () {},
//             );
//           },
//         );
//       },
//     );
//   }
// }

//----------Current code-----------
// import 'package:flutter/material.dart';
// import 'package:reviews_app/data/repositories/authentication/authentication_repository.dart';
// import 'package:reviews_app/data/repositories/place/place_repository.dart';
// import 'package:reviews_app/utils/constants/sizes.dart' show AppSizes;

// import '../../../../../common/widgets/place/place_card.dart';
// import '../../../../../common/widgets/shimmers/big_card_shimmer.dart';
// import '../../../controllers/place_controller.dart';
// import '../../../models/place_model.dart';
// import '../edit_place.dart';

// class PlaceListTab extends StatelessWidget {
//   const PlaceListTab({super.key, required this.categoryId});

//   // final String categoryFilter;
//   final String categoryId;
//   // final Query? query;
//   // final Future<List<PlaceModel>>? futureMethod;

//   @override
//   Widget build(BuildContext context) {
//     // Note: Removed the reliance on 'AppCloudHelperFunctions.checkMultiRecordState'
//     // as it was likely triggering the erroneous errorSnackBar on empty data.

//     return FutureBuilder<List<PlaceModel>>(
//       // future: futureMethod,
//       future: PlaceRepository.instance.getPlacesForCategory(
//         categoryId,
//         limit: -1,
//       ),
//       builder: (_, snapshot) {
//         // 1. HANDLE LOADING STATE
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Padding(
//             padding: EdgeInsets.symmetric(
//               horizontal: AppSizes.defaultSpace,
//               vertical: AppSizes.defaultSpace / 2,
//             ),
//             child: PlaceCardShimmer(),
//           );
//         }

//         // 2. HANDLE ERROR STATE (Fallback for unhandled exceptions in the controller)
//         if (snapshot.hasError) {
//           // Display the error directly in the widget body, DO NOT use a SnackBar here.
//           return Center(
//             child: Padding(
//               padding: const EdgeInsets.all(AppSizes.defaultSpace),
//               child: Text(
//                 'An error occurred: ${snapshot.error.toString()}',
//                 textAlign: TextAlign.center,
//                 style: Theme.of(
//                   context,
//                 ).textTheme.bodyMedium?.copyWith(color: Colors.red),
//               ),
//             ),
//           );
//         }

//         // 3. HANDLE NO DATA FOUND STATE (The FIX)
//         final filteredPlaces = snapshot.data;
//         if (filteredPlaces == null || filteredPlaces.isEmpty) {
//           // This is a successful completion with an empty list.
//           // Display a friendly message, but DO NOT call any global SnackBar/Toast.
//           return const Center(
//             child: Padding(
//               padding: EdgeInsets.all(AppSizes.defaultSpace),
//               child: Text(
//                 'No places found in this category. Try adding one!',
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           );
//         }

//         // 4. DATA FOUND STATE (Success)
//         // Return the successful list view (ListView.separated)
//         return ListView.separated(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.symmetric(
//             horizontal: AppSizes.defaultSpace,
//             vertical: AppSizes.defaultSpace / 2,
//           ),
//           itemCount: filteredPlaces.length,
//           separatorBuilder: (_, _) =>
//               const SizedBox(height: AppSizes.spaceBtwSections),
//           itemBuilder: (context, index) {
//             final place = filteredPlaces[index];
//             // return PlaceCard(place: place);
//             bool isCreator = false;
//             final creatorId = place.userId;
//             final currentUserId = AuthenticationRepository.instance.getUserID;
//             if (creatorId == currentUserId) {
//               isCreator = true;
//             }
//             debugPrint('currentUserId: $currentUserId, isCreator: $isCreator');
//             return PlaceCard(
//               place: place,
//               showEditOptions: isCreator,
//               // onEdit: isCreator
//               //     ? () => Get.to(() => EditPlaceScreen(place: place))
//               //     : () {},
//               onEdit: () {
//                 if (isCreator) {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => EditPlaceScreen(place: place),
//                     ),
//                   );
//                 }
//               },

//               onDelete: () => isCreator
//                   ? PlaceController.instance.deletePlaceWithConfirmation(place)
//                   : () {},
//             );
//           },
//         );
//       },
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:reviews_app/common/widgets/place/place_card.dart';
// import 'package:reviews_app/common/widgets/shimmers/big_card_shimmer.dart';
// import 'package:reviews_app/utils/constants/sizes.dart';
// import 'package:reviews_app/utils/helpers/cloud_helper_functions.dart'; // Import the helper function
// import '../../../models/place_model.dart';

// class PlaceListTab extends StatelessWidget {
//   const PlaceListTab({super.key, this.futureMethod});

//   final Future<List<PlaceModel>>? futureMethod;

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<PlaceModel>>(
//       future: futureMethod,
//       builder: (_, snapshot) {
//         const loader = PlaceCardShimmer();
//         final widget = AppCloudHelperFunctions.checkMultiRecordState(
//           snapshot: snapshot,
//           loader: loader,
//         );

//         // Return appropriate widget based on snapshot state (Shimmer, Empty, Error)
//         if (widget != null) {
//           // Wrap the result in padding to match the original list padding
//           return Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: AppSizes.defaultSpace,
//               vertical: AppSizes.defaultSpace / 2,
//             ),
//             child: widget,
//           );
//         }

//         // Data Found (Success)
//         final filteredPlaces = snapshot.data!;

//         // Return the successful list view (ListView.separated)
//         return ListView.separated(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.symmetric(
//             horizontal: AppSizes.defaultSpace,
//             vertical: AppSizes.defaultSpace / 2,
//           ),
//           itemCount: filteredPlaces.length,
//           separatorBuilder: (_, _) =>
//               const SizedBox(height: AppSizes.spaceBtwSections),
//           itemBuilder: (context, index) {
//             final place = filteredPlaces[index];
//             return PlaceCard(place: place);
//           },
//         );
//       },
//     );
//   }
// }
