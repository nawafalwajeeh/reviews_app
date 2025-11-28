import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/place/category/category_grid_list.dart';
import '../../../../../common/widgets/shimmers/category_grid_shimmer.dart';
import '../../../../../localization/app_localizations.dart';
import '../../../controllers/category_controller.dart';

class HomeCategories extends StatelessWidget {
  const HomeCategories({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure the controller is initialized or fetched
    final controller = CategoryController.instance;

    // Use Obx to listen to the reactive loading state
    return Obx(() {
      if (controller.isLoading.value) {
        return const CategoryGridShimmer(itemCount: 8, crossAxisCount: 4);
      }

      
      if (controller.allCategories.isEmpty) {
        return Center(
          child: Text(
            // 'No Categories Found!',
            AppLocalizations.of(context).noCategoriesFound,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      }

      // 3. SHOW ACTUAL DATA WHEN LOADED
      return CategoryGridList(
        categories: controller.allCategories,
        limit: 8, // Limit to 8 items for the home screen
      );
    });
  }
}
