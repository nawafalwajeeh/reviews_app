import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/place/category/category_grid_list.dart';
import '../../../../common/widgets/shimmers/category_grid_shimmer.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/category_controller.dart';
import 'add_new_category.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = CategoryController.instance;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: () => Get.to(() => const AddNewCategoryScreen()),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      appBar: const CustomAppBar(
        showBackArrow: true,
        title: Text('All Categories'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),

          child: Obx(() {
            // 1. HANDLE LOADING STATE
            if (controller.isLoading.value) {
              // Show a loading shimmer appropriate for a full list (e.g., 6 items)
              return const CategoryGridShimmer(
                itemCount: 20,
                crossAxisCount: 4,
              );
            }

            // 2. HANDLE EMPTY/ERROR STATE
            if (controller.allCategories.isEmpty) {
              return Center(
                child: Text(
                  'No categories found.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            // 3. SHOW DATA (No limit applied here, showing all)
            return CategoryGridList(categories: controller.allCategories);
          }),
        ),
      ),
    );
  }
}
