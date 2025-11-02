import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/features/review/controllers/category_controller.dart';
import 'package:reviews_app/features/review/models/category_mapper.dart' show CategoryMapper;
import 'package:reviews_app/features/review/models/category_model.dart';
import 'package:reviews_app/features/review/screens/categories/all_categories.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

import '../../layouts/grid_layout.dart';
import 'category_card.dart';

class CategoryGridList extends StatelessWidget {
  final List<CategoryModel> categories;
  // Optional limit: if provided, only show this many items (e.g., 8 for Home Screen)
  final int? limit; 
  
  const CategoryGridList({
    super.key,
    required this.categories,
    this.limit,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Determine if we need to show the 'More' button (limit is set AND we have more items)
    final bool shouldShowMore = limit != null && categories.length > limit!;

    // 2. Determine the number of items to display (either the limit or the full length)
    final int displayCount = shouldShowMore ? limit! : categories.length;

    return AppGridLayout(
      itemCount: displayCount,
      crossAxisCount: 4, // 4 columns for compact category display
      childAspectRatio: 0.85, // Ratio for taller category cards
      mainAxisSpacing: AppSizes.spaceBtwItems, 
      crossAxisSpacing: AppSizes.spaceBtwItems, 

      itemBuilder: (context, index) {
        
        // --- LOGIC TO SWAP LAST ITEM FOR 'MORE' BUTTON ---
        // If limit is active AND this is the last available slot (index == limit - 1)
        if (shouldShowMore && index == limit! - 1) {
          return CategoryCard(
            title: 'More',
            icon: Icons.more_horiz_rounded,
            gradientColors: const [Color(0xFFBEE6D8), Color(0xFFA0C1FF)], // Hardcoded colors
            iconColor: const Color(0xFF2D3A64),
            // Navigate to the full list of categories
            onTap: () => Get.to(() => const AllCategoriesScreen()), 
          );
        }
        
        // --- NORMAL CATEGORY DISPLAY ---
        final category = categories[index];

        return CategoryCard(
          title: category.name,
          icon: CategoryMapper.getIcon(category.iconKey),
          gradientColors: CategoryMapper.getGradientColors(category.gradientKey),
          iconColor: CategoryMapper.getIconColor(category.iconColorValue),
          onTap: () {
            Get.snackbar(
              'Selected',
              'Navigating to ${category.name}',
              snackPosition: SnackPosition.BOTTOM,
            );
            // Replace with actual navigation logic
          },
        );
      },
    );
  }
}


//-----Original code----------------------
// import 'package:flutter/material.dart';
// import 'package:reviews_app/features/review/models/category_model.dart';
// import 'package:reviews_app/utils/constants/sizes.dart';
// import '../../../../features/review/models/category_mapper.dart';
// import '../../layouts/grid_layout.dart';
// import 'category_card.dart';

// class CategoriesListWidget extends StatelessWidget {
//   const CategoriesListWidget({super.key, required this.categories, this.limit = -1});

//   final List<CategoryModel> categories;
//   final int limit;


//   @override
//   Widget build(BuildContext context) {

    
//     return AppGridLayout(
//       itemCount: limit != -1 ? categories.take(limit).toList().length: categories.length,
//       crossAxisCount: 4, // 4 columns for compact category display
//       childAspectRatio: 0.85, // Ratio for taller category cards
//       mainAxisSpacing: AppSizes.spaceBtwItems, // Tighter row spacing
//       crossAxisSpacing: AppSizes.spaceBtwItems, // Tighter column spacing

//       itemBuilder: (context, index) {
//         // Use the CategoryModel data and the Mapper to build the card
//         final category = categories[index];
//         return CategoryCard(
//           title: category.name,
//           // Map the stored key string to an IconData object
//           icon: CategoryMapper.getIcon(category.iconKey),
//           // Map the stored key string to a List<Color> object
//           gradientColors: CategoryMapper.getGradientColors(
//             category.gradientKey,
//           ),
//           // Map the stored int value to a Color object
//           iconColor: CategoryMapper.getIconColor(category.iconColorValue),
//           onTap: () {},
//         );
//       },
//     );
//   }
// }
