import 'package:flutter/material.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'shimmer_effect.dart';

class PlaceCardShimmer extends StatelessWidget {
  const PlaceCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(20);
    final bgColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkerGrey
        : AppColors.grey;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.defaultSpace,
        vertical: AppSizes.defaultSpace / 2,
      ),
      itemCount: 2,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppSizes.spaceBtwSections),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: borderRadius,
            boxShadow: const [
              BoxShadow(
                blurRadius: 8,
                color: AppColors.dark,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: borderRadius,
                      child: const AppShimmerEffect(
                        width: double.infinity,
                        height: double.infinity,
                        radius: 20,
                      ),
                    ),
                    // Top-left rating badge shimmer
                    const Positioned(
                      left: 16,
                      top: 16,
                      child: SizedBox(
                        width: 44,
                        height: 28,
                        child: AppShimmerEffect(
                          width: 44,
                          height: 28,
                          radius: 8,
                        ),
                      ),
                    ),
                    // Top-right favourite icon shimmer
                    const Positioned(
                      right: 16,
                      top: 16,
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: AppShimmerEffect(
                          width: 36,
                          height: 36,
                          radius: 18,
                        ),
                      ),
                    ),
                    // Bottom title/location shimmer (two lines)
                    const Positioned(
                      left: 16,
                      bottom: 16,
                      right: 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppShimmerEffect(width: 160, height: 18, radius: 6),
                          SizedBox(height: 6),
                          AppShimmerEffect(width: 120, height: 14, radius: 6),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    // text column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          AppShimmerEffect(
                            width: 80,
                            height: 14,
                            radius: 6,
                          ), // category
                          SizedBox(height: 8),
                          AppShimmerEffect(
                            width: double.infinity,
                            height: 12,
                            radius: 6,
                          ), // desc line 1
                          SizedBox(height: 6),
                          AppShimmerEffect(
                            width: 160,
                            height: 12,
                            radius: 6,
                          ), // desc line 2
                        ],
                      ),
                    ),

                    const SizedBox(width: AppSizes.spaceBtwItems / 2),

                    // button shimmer
                    const SizedBox(
                      height: 36,
                      width: 110,
                      child: AppShimmerEffect(
                        width: 110,
                        height: 36,
                        radius: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
