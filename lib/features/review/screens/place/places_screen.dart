import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/common/widgets/appbar/tabbar.dart';
import 'package:reviews_app/common/widgets/custom_shapes/containers/search_container.dart';
import 'package:reviews_app/common/widgets/headers/custom_header.dart';
import 'package:reviews_app/features/review/controllers/place_controller.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../gallery/gallery.dart';
import 'add_new_place.dart';
import 'widgets/place_list_tab.dart';

class AllPlacesScreen extends StatelessWidget {
  const AllPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PlaceController());

    return DefaultTabController(
      length: controller.categories.length,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.to(() => const AddNewPlaceScreen()),
          backgroundColor: AppColors.primaryColor,
          child: const Icon(Icons.add, color: AppColors.white),
        ),
        body: Column(
          children: [
            CustomHeader(
              title: 'Discover Places',
              icon: Iconsax.image,
              onPressed: () => Get.to(() => const ImageGalleryScreen()),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            AppSearchContainer(text: 'Search for place'),
            const SizedBox(height: AppSizes.spaceBtwItems),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.defaultSpace,
              ),
              child: CustomTabBar(
                tabs: controller.categories
                    .map((name) => Tab(text: name))
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),

            /// -- Expanded ensures TabBarView takes all remaining space
            Expanded(
              child: TabBarView(
                children: controller.categories.map((categoryName) {
                  return PlaceListTab(categoryFilter: categoryName);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
