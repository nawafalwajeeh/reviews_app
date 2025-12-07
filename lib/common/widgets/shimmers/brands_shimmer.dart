import 'package:flutter/widgets.dart';
import 'package:reviews_app/common/widgets/layouts/grid_layout.dart';
import 'package:reviews_app/common/widgets/shimmers/shimmer_effect.dart';

class BrandsShimmer extends StatelessWidget {
  const BrandsShimmer({super.key, this.itemCount = 4});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AppGridLayout(
      itemCount: itemCount,
      mainAxisExtent: 80,
      itemBuilder: (_, _) => AppShimmerEffect(width: 300, height: 80),
    );
  }
}
