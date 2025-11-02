import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/place/category/category_grid_list.dart';
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
          child: CategoryGridList(categories: controller.mockCategories),
        ),
      ),
    );
  }
}
