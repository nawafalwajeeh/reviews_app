import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/common/widgets/place/horizontal_place_card.dart';
import 'package:reviews_app/common/widgets/shimmers/horizontal_place_shimmer.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/features/review/controllers/category_controller.dart';
import 'package:reviews_app/features/review/models/category_model.dart';
import 'package:reviews_app/features/review/models/place_model.dart';
import 'package:reviews_app/utils/helpers/cloud_helper_functions.dart';

import '../../../../common/widgets/place/category/category_card.dart';
import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../controllers/place_controller.dart';
import '../../models/category_mapper.dart';
import '../place/edit_place.dart';

class CategoryPlacesScreen extends StatelessWidget {
  const CategoryPlacesScreen({super.key, required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    // Get the category controller instance
    final controller = CategoryController.instance;

    // Determine the current authenticated user's ID
    final currentUserId = AuthenticationRepository.instance.getUserID;

    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          category.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.spaceBtwSections * 4),
              // Category Card Banner
              Center(
                child: CategoryCard(
                  height: 120,
                  width: 120,
                  titleSize: 100,
                  title: category.name,
                  icon: CategoryMapper.getIcon(category.iconKey),
                  gradientColors: CategoryMapper.getGradientColors(
                    category.gradientKey,
                  ),
                  iconColor: CategoryMapper.getIconColor(
                    category.iconColorValue,
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.spaceBtwSections),

              // --- StreamBuilder for Real-Time Updates ---
              // Changed from FutureBuilder to StreamBuilder to listen for real-time changes
              StreamBuilder(
                // Assuming 'streamCategoryPlaces' returns a Stream<List<PlaceModel>>
                stream: controller.streamCategoryPlaces(
                  categoryId: category.id,
                ),
                builder: (context, snapshot) {
                  const loader = AppHorizontalPlaceShimmer();

                  final widget = AppCloudHelperFunctions.checkMultiRecordState(
                    snapshot: snapshot,
                    loader: loader,
                  );
                  // If the state is loading, error, or no data, return the widget.
                  if (widget != null) return widget;

                  final categoryPlaces = snapshot.data!;

                  return SizedBox(
                    height: 180,
                    child: ListView.builder(
                      itemCount: categoryPlaces.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(
                        left: AppSizes.defaultSpace,
                      ),
                      itemBuilder: (context, index) {
                        final place = categoryPlaces[index];

                        // Determine if the current user is the creator of the place
                        final creatorId = place.userId;
                        final isCreator = creatorId == currentUserId;

                        debugPrint(
                          'currentUserId: $currentUserId, creatorId: $creatorId ,isCreator: $isCreator',
                        );

                        return PlaceCardHorizontal(
                          place: place,
                          showEditOptions: isCreator,

                          onEdit: () {
                            // Only navigate to edit screen if the user is the creator
                            if (isCreator) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditPlaceScreen(place: place),
                                ),
                              );
                            }
                          },

                          onDelete: () => isCreator
                              ? PlaceController.instance
                                // Make sure this delete method can trigger a UI refresh (e.g., by modifying the stream's source)
                                .deletePlaceWithConfirmation(place)
                              : () {}, // Do nothing if not creator
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSizes.spaceBtwSections),
            ],
          ),
        ),
      ),
    );
  }
}

//----------------------------------
// // ...existing code...
// import 'package:flutter/material.dart';
// import 'package:reviews_app/common/widgets/appbar/appbar.dart';
// import 'package:reviews_app/common/widgets/place/horizontal_place_card.dart';
// import 'package:reviews_app/common/widgets/shimmers/horizontal_place_shimmer.dart';
// import 'package:reviews_app/utils/constants/sizes.dart';
// import 'package:reviews_app/features/review/controllers/category_controller.dart';
// import 'package:reviews_app/features/review/models/category_model.dart';
// import 'package:reviews_app/features/review/models/place_model.dart';
// import 'package:reviews_app/utils/helpers/cloud_helper_functions.dart';

// import '../../../../common/widgets/place/category/category_card.dart';
// import '../../../../data/repositories/authentication/authentication_repository.dart';
// import '../../controllers/place_controller.dart';
// import '../../models/category_mapper.dart';
// import '../place/edit_place.dart';

// class CategoryPlacesScreen extends StatelessWidget {
//   const CategoryPlacesScreen({super.key, required this.category});

//   final CategoryModel category;

//   @override
//   Widget build(BuildContext context) {
//     final controller = CategoryController.instance;

//     return Scaffold(
//       appBar: CustomAppBar(
//         showBackArrow: true,
//         title: Text(
//           category.name,
//           style: Theme.of(context).textTheme.headlineSmall,
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(AppSizes.defaultSpace),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: AppSizes.spaceBtwSections * 4),
//               // Category Card Banner
//               Center(
//                 child: CategoryCard(
//                   height: 120,
//                   width: 120,
//                   titleSize: 100,
//                   title: category.name,
//                   icon: CategoryMapper.getIcon(category.iconKey),
//                   gradientColors: CategoryMapper.getGradientColors(
//                     category.gradientKey,
//                   ),
//                   iconColor: CategoryMapper.getIconColor(
//                     category.iconColorValue,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: AppSizes.spaceBtwSections),

//               FutureBuilder<List<PlaceModel>>(
//                 future: controller.getCategoryPlaces(
//                   categoryId: category.id,
//                   limit: -1,
//                 ),
//                 builder: (context, snapshot) {
//                   const loader = AppHorizontalPlaceShimmer();

//                   final widget = AppCloudHelperFunctions.checkMultiRecordState(
//                     snapshot: snapshot,
//                     loader: loader,
//                   );
//                   if (widget != null) return widget;

//                   final categoryPlaces = snapshot.data!;

//                   return SizedBox(
//                     height: 180,
//                     child: ListView.builder(
//                       itemCount: categoryPlaces.length,
//                       shrinkWrap: true,
//                       scrollDirection: Axis.horizontal,
//                       padding: const EdgeInsets.only(
//                         left: AppSizes.defaultSpace,
//                       ),
//                       itemBuilder: (context, index) {
//                         final place = categoryPlaces[index];

//                         bool isCreator = false;
//                         final creatorId = place.userId;
//                         final currentUserId =
//                             AuthenticationRepository.instance.getUserID;

//                         if (creatorId == currentUserId) {
//                           isCreator = true;
//                         }

//                         debugPrint(
//                           'currentUserId: $currentUserId, creatorId: $creatorId ,isCreator: $isCreator',
//                         );

//                         return PlaceCardHorizontal(
//                           place: place,
//                           showEditOptions: isCreator,

//                           onEdit: () {
//                             if (isCreator) {
//                               Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       EditPlaceScreen(place: place),
//                                 ),
//                               );
//                             }
//                           },

//                           onDelete: () => isCreator
//                               ? PlaceController.instance
//                                     .deletePlaceWithConfirmation(place)
//                               : () {},
//                         );
//                       },
//                     ),
//                   );
//                 },
//               ),

//               const SizedBox(height: AppSizes.spaceBtwSections),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
