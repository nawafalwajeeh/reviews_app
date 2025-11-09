import 'package:flutter/material.dart';

import '../../../utils/constants/sizes.dart';
import 'shimmer_effect.dart';

/// A horizontal list of shimmer elements designed to mimic the layout
/// of the HomeTrendings section (a horizontal list of cards).
class AppTrendingListShimmer extends StatelessWidget {
  const AppTrendingListShimmer({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    const double spaceBtwItems = AppSizes.spaceBtwItems;

    return SizedBox(
      height: 285, // Matches the height of your HomeTrendings container
      width: double.infinity,
      child: ListView.builder(
        // Use NeverScrollableScrollPhysics to prevent accidental scrolling of shimmer
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: EdgeInsets.zero,
        itemBuilder: (_, index) {
          // This structure mimics the padding and width of a single TrendingCard
          return Padding(
            padding: const EdgeInsets.only(right: spaceBtwItems),
            child: SizedBox(
              width: 300, // Matches the width of your TrendingCard
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Image/Main Content Placeholder (simulates the PlaceCard main image area)
                  const AppShimmerEffect(
                    width: 300,
                    height: 180, // Approximate height of the main card area
                    radius: 16,
                  ),
                  const SizedBox(height: spaceBtwItems),

                  // 2. Title Placeholder
                  // Give it some horizontal padding to match text alignment in a real card
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: AppShimmerEffect(width: 250, height: 16),
                  ),
                  const SizedBox(height: spaceBtwItems / 2),

                  // 3. Subtitle/Metadata Placeholder
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: AppShimmerEffect(width: 100, height: 12, radius: 4),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
