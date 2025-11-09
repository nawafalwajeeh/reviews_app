import 'package:flutter/material.dart';
import 'package:reviews_app/features/review/controllers/category_controller.dart';

import '../../../utils/constants/colors.dart';

class CategoryNameText extends StatelessWidget {
  final String categoryId;

  const CategoryNameText({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    // We instantiate the repository here to fetch the data.
    final controller = CategoryController.instance;

    return FutureBuilder<String>(
      // Call the method to asynchronously fetch the name
      future: controller.getCategoryName(categoryId),
      builder: (context, snapshot) {
        // Show a small loading indicator while fetching
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 80,
            child: LinearProgressIndicator(color: AppColors.primaryColor),
          );
        }

        // Handle error state
        if (snapshot.hasError) {
          return Text(
            'Error Loading',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
          );
        }

        // Display the retrieved category name
        final categoryName = snapshot.data ?? 'Category Not Found';

        return Text(
          categoryName,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.primaryColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
