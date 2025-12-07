import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/shimmers/shimmer_effect.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: itemCount,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, _) =>
            const SizedBox(width: AppSizes.spaceBtwItems),
        itemBuilder: (context, index) => const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Image
            AppShimmerEffect(width: 55, height: 55, radius: 55),
            SizedBox(height: AppSizes.spaceBtwItems / 2),

            /// Text
            AppShimmerEffect(width: 55, height: 8),
          ],
        ),
      ),
    );
  }
}
