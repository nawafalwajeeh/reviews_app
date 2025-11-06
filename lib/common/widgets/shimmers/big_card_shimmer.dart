import 'package:flutter/material.dart';

import '../../../utils/constants/sizes.dart';
import 'shimmer_effect.dart';

class PlaceCardShimmer extends StatelessWidget {
  const PlaceCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // The Container size aligns with the full width of the screen, as the original card does.
    return Padding(
      // Add padding equivalent to AppSizes.defaultSpace if this is used in a ListView builder
      // or similar context where vertical spacing is needed between shimmers.
      padding: const EdgeInsets.only(bottom: AppSizes.spaceBtwSections),
      child: Column(
        children: [
          // 1. Image Section (Height: 200, Rounded)
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Stack(
              children: [
                // The main image shimmer effect
                const AppShimmerEffect(
                  width: double.infinity,
                  height: 200,
                  radius: 20, // Matches the parent card's border radius
                ),

                // Placeholder for Rating Badge (Positioned at top left: 16, 16)
                const Positioned(
                  left: 16,
                  top: 16,
                  child: AppShimmerEffect(
                    width: 50,
                    height: 20,
                    radius: AppSizes.sm,
                  ),
                ),

                // Placeholder for Favourite Icon (Positioned at top right: 16, 16)
                const Positioned(
                  right: 16,
                  top: 16,
                  child: AppShimmerEffect(width: 32, height: 32, radius: 16),
                ),

                // Placeholder for Title and Location Text (Positioned at bottom left: 16, 16)
                const Positioned(
                  left: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppShimmerEffect(width: 180, height: 20), // Title
                      SizedBox(height: AppSizes.xs),
                      AppShimmerEffect(width: 120, height: 16), // Location
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Details Section (Mimics Padding: horizontal: 20, vertical: 18)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Column (Category and Description)
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Text (Line 1 - Primary Color Text)
                      AppShimmerEffect(width: 90, height: 15),
                      SizedBox(height: 2),
                      // Description Text (Line 2 - Body Small)
                      AppShimmerEffect(width: 160, height: 12),
                    ],
                  ),
                ),

                const SizedBox(width: AppSizes.spaceBtwItems / 2),

                // Right Button (View Details Button, Height: 36)
                const AppShimmerEffect(
                  width: 110, // Width roughly matching 'View Details' button
                  height: 36,
                  radius: 18, // Half of height for rounded caps
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
