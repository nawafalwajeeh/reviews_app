import 'package:flutter/material.dart';

import '../../../utils/constants/sizes.dart';
import 'shimmer_effect.dart';

/// A single shimmer element used to simulate a single category icon card.
class CategoryCardShimmer extends StatelessWidget {
  const CategoryCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /// Simulated Icon/Image Area
        // Use AppShimmerEffect for the circular icon background
        const AppShimmerEffect(
          width: AppSizes.iconLg,
          height: AppSizes.iconLg,
          radius: AppSizes.borderRadiusLg, // Use radius to control shape/corners
        ),
        const SizedBox(height: AppSizes.spaceBtwItems / 2),

        /// Simulated Text Line (Category Name)
        // Use AppShimmerEffect for the text line
        const AppShimmerEffect(
          width: 60, // A fixed, representative width for text
          height: 10,
          radius: 4, // Smaller radius for text block
        ),
      ],
    );
  }
}
//---------------------
// import 'package:flutter/material.dart';
// import 'package:reviews_app/utils/constants/colors.dart';

// import '../../../utils/constants/sizes.dart';

// class CategoryCardShimmer extends StatelessWidget {
//   const CategoryCardShimmer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // This container simulates the background structure of your CategoryCard
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         // Simulated Icon/Image Area
//         Container(
//           width: AppSizes.iconLg,
//           height: AppSizes.iconLg,
//           decoration: BoxDecoration(
//             color: AppColors.lightGrey,
//             borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
//           ),
//         ),
//         const SizedBox(height: AppSizes.spaceBtwItems / 2),
//         // Simulated Text Line (Category Name)
//         Container(
//           width: double.infinity,
//           height: 10,
//           margin: const EdgeInsets.symmetric(horizontal: 8.0),
//           decoration: BoxDecoration(
//             color: AppColors.lightGrey,
//             borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
//           ),
//         ),
//       ],
//     );
//   }
// }

