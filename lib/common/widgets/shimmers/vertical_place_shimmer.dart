import 'package:flutter/material.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../layouts/grid_layout.dart';
import 'shimmer_effect.dart';

class AppVerticalPlaceShimmer extends StatelessWidget {
  const AppVerticalPlaceShimmer({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AppGridLayout(
      itemCount: itemCount,
      crossAxisCount: 2,
      mainAxisExtent: 250, // Matching the favorite screen's card height
      childAspectRatio: 1.0,
      itemBuilder: (_, _) => const SizedBox(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image/Thumbnail Shimmer
            AppShimmerEffect(
              width: 180,
              height: 180,
              radius: AppSizes.cardRadiusLg,
            ),
            SizedBox(height: AppSizes.spaceBtwItems / 2),

            // Title Line 1 Shimmer
            AppShimmerEffect(width: 160, height: 15),
            SizedBox(height: AppSizes.spaceBtwItems / 2),

            // Title Line 2 (or details) Shimmer
            AppShimmerEffect(width: 100, height: 15),
          ],
        ),
      ),
    );
  }
}
