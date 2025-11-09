import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/tabbar.dart';
import '../../../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../../../common/widgets/headers/custom_header.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/category_controller.dart';
import '../gallery/gallery.dart';
import 'add_new_place.dart';
import 'widgets/place_list_tab.dart';

class AllPlacesScreen extends StatelessWidget {
  const AllPlacesScreen({super.key});

  // Calculate the total height of the fixed header components
  static const double _kHeaderHeight = 70.0; // CustomHeader height
  static const double _kSearchHeight = 56.0; // AppSearchContainer height
  static const double _kTabBarHeight = 48.0; // CustomTabBar height
  static const double _kTotalExpandedHeight =
      _kHeaderHeight + _kSearchHeight + _kTabBarHeight;

  @override
  Widget build(BuildContext context) {
    final controller = CategoryController.instance;

    debugPrint('CategoryModels:  ${controller.categoryModels}');

    return DefaultTabController(
      length: controller.categoryModels.length,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.to(() => const AddNewPlaceScreen()),
          backgroundColor: AppColors.primaryColor,
          child: const Icon(Icons.add, color: AppColors.white),
        ),

        // 1. Replace the Column with NestedScrollView
        body: NestedScrollView(
          headerSliverBuilder: (_, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading:
                    false, // Prevents back button conflict
                expandedHeight:
                    _kTotalExpandedHeight, // Total height of content when fully expanded
                floating:
                    true, // Header can reappear as soon as user scrolls down slightly
                pinned: true, // The TabBar will remain pinned at the top
                // 2. Add the custom content to the flexible space
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Column(
                    children: [
                      // Header - Note: This needs to adjust for system status bar height
                      CustomHeader(
                        title: 'Discover Places',
                        icon: Iconsax.image,
                        onPressed: () =>
                            Get.to(() => const ImageGalleryScreen()),
                      ),

                      // Search Container
                      const AppSearchContainer(text: 'Search for place'),
                      const SizedBox(height: AppSizes.spaceBtwItems / 2),
                    ],
                  ),
                ),

                // 3. Pin the TabBar to the bottom of the SliverAppBar
                bottom: CustomTabBar(
                  tabs: controller.categoryNames
                      .map((name) => Tab(text: name))
                      .toList(),
                ),
              ),
            ];
          },

          // TabBarView becomes the body and scrolls independently
          body: TabBarView(
            children: controller.categoryModels.map((categoryModel) {
              return PlaceListTab(
                categoryFilter: categoryModel.id,
                futureMethod: controller.getCategoryPlaces(
                  categoryId: categoryModel.id,
                  limit: -1,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// -------Original code-----------------
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:reviews_app/common/widgets/appbar/tabbar.dart';
// import 'package:reviews_app/common/widgets/custom_shapes/containers/search_container.dart';
// import 'package:reviews_app/common/widgets/headers/custom_header.dart';
// import 'package:reviews_app/utils/constants/colors.dart';
// import 'package:reviews_app/utils/constants/sizes.dart';
// import '../../controllers/category_controller.dart';
// import '../gallery/gallery.dart';
// import 'add_new_place.dart';
// import 'widgets/place_list_tab.dart';

// class AllPlacesScreen extends StatelessWidget {
//   const AllPlacesScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = CategoryController.instance;

//     return DefaultTabController(
//       length: controller.categories.length,
//       child: Scaffold(
//         floatingActionButton: FloatingActionButton(
//           onPressed: () => Get.to(() => const AddNewPlaceScreen()),
//           backgroundColor: AppColors.primaryColor,
//           child: const Icon(Icons.add, color: AppColors.white),
//         ),
//         body: Column(
//           children: [
//             CustomHeader(
//               title: 'Discover Places',
//               icon: Iconsax.image,
//               onPressed: () => Get.to(() => const ImageGalleryScreen()),
//             ),
//             const SizedBox(height: AppSizes.spaceBtwItems),
//             AppSearchContainer(text: 'Search for place'),
//             const SizedBox(height: AppSizes.spaceBtwItems),
//             Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: AppSizes.defaultSpace,
//               ),
//               child: CustomTabBar(
//                 tabs: controller.categories
//                     .map((name) => Tab(text: name))
//                     .toList(),
//               ),
//             ),
//             const SizedBox(height: AppSizes.spaceBtwItems),

//             /// -- Expanded ensures TabBarView takes all remaining space
//             Expanded(
//               child: TabBarView(
//                 children: controller.categories.map((categoryName) {
//                   // final categoryId = controller;
//                   return PlaceListTab(
//                     categoryFilter: categoryName,
//                     futureMethod: controller.getCategoryPlaces(
//                       categoryId: categoryName,
//                       limit: -1,
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
