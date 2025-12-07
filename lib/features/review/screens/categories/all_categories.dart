import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/place/category/category_grid_list.dart';
import '../../../../common/widgets/shimmers/category_grid_shimmer.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/category_controller.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = CategoryController.instance;

    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        // title: Text('All Categories'),
        title: Text(AppLocalizations.of(context).allCategories),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),

          child: Obx(() {
            // HANDLE LOADING STATE
            if (controller.isLoading.value) {
              // Show a loading shimmer appropriate for a full list (e.g., 6 items)
              return const CategoryGridShimmer(
                itemCount: 20,
                crossAxisCount: 4,
              );
            }

            // HANDLE EMPTY/ERROR STATE
            if (controller.allCategories.isEmpty) {
              return Center(
                child: Text(
                  // 'No categories found.',
                  AppLocalizations.of(context).noCategoriesFound,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            // SHOW DATA (No limit applied here, showing all)
            return CategoryGridList(categories: controller.allCategories);
          }),
        ),
      ),
    );
  }
}
