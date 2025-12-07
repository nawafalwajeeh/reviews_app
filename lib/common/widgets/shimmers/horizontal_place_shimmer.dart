import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/shimmers/shimmer_effect.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

class AppHorizontalPlaceShimmer extends StatelessWidget {
  const AppHorizontalPlaceShimmer({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.spaceBtwSections),
      height: 120,
      child: ListView.separated(
        itemCount: itemCount,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSizes.spaceBtwItems),
        itemBuilder: (context, index) => const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Image
            AppShimmerEffect(width: 120, height: 120),
            SizedBox(width: AppSizes.spaceBtwItems),

            /// Text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: AppSizes.spaceBtwItems / 2),
                AppShimmerEffect(width: 160, height: 15),
                SizedBox(height: AppSizes.spaceBtwItems / 2),
                AppShimmerEffect(width: 110, height: 15),
                SizedBox(height: AppSizes.spaceBtwItems / 2),
                AppShimmerEffect(width: 80, height: 15),
                Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
