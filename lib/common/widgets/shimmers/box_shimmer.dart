import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/shimmers/shimmer_effect.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

class AppBoxShimmer extends StatelessWidget {
  const AppBoxShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(child: AppShimmerEffect(width: 150, height: 110)),
            SizedBox(height: AppSizes.spaceBtwItems),
            Expanded(child: AppShimmerEffect(width: 150, height: 110)),
            SizedBox(height: AppSizes.spaceBtwItems),
            Expanded(child: AppShimmerEffect(width: 150, height: 110)),
          ],
        ),
      ],
    );
  }
}
