import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/place/category/category_grid_list.dart';
import 'package:reviews_app/features/review/controllers/category_controller.dart';

class HomeCategories extends StatelessWidget {
  const HomeCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = CategoryController.instance;
    return CategoryGridList(categories: controller.mockCategories, limit: 8);
  }
}
