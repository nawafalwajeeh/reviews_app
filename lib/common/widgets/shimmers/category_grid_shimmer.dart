import 'package:flutter/material.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

import 'category_card_shimmer.dart';

/// A Grid view for the category shimmer effect, using the existing grid layout structure.
class CategoryGridShimmer extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;

  const CategoryGridShimmer({
    super.key,
    this.itemCount = 8,
    this.crossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    // We use a standard GridView here, assuming AppGridLayout is a wrapper around it.
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSizes.spaceBtwItems,
        mainAxisSpacing: AppSizes.spaceBtwItems,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        return const CategoryCardShimmer();
      },
    );
  }
}