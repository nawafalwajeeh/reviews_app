import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/shimmers/shimmer_effect.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

class GalleryShimmer extends StatelessWidget {
  const GalleryShimmer({
    super.key,
    this.count = 3,
    this.crossAxisCount = 3,
    this.itemHeight = 100,
    this.aspectRatio = 0.7,
  });

  final int count;
  final int crossAxisCount;
  final double itemHeight;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    if (crossAxisCount > 1) {
      // Grid Shimmer (for All Photos)
      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: count,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: AppSizes.defaultSpace,
          crossAxisSpacing: AppSizes.defaultSpace,
          childAspectRatio: aspectRatio,
        ),
        itemBuilder: (_, __) => const AppShimmerEffect(width: double.infinity, height: 180),
      );
    } else {
      // Horizontal Shimmer (for Collections or other horizontal lists)
      return SizedBox(
        height: itemHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: count,
          separatorBuilder: (_, __) => const SizedBox(width: AppSizes.defaultSpace),
          itemBuilder: (_, __) => AppShimmerEffect(width: itemHeight * 1.5, height: itemHeight),
        ),
      );
    }
  }
}