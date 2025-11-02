import 'package:flutter/material.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

class AppGridLayout extends StatelessWidget {
  const AppGridLayout({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    // this.mainAxisExtent = 288,
    this.mainAxisExtent,
    this.childAspectRatio,
    this.mainAxisSpacing = AppSizes.gridViewSpacing,
    this.crossAxisSpacing = AppSizes.gridViewSpacing,
  });

  final int itemCount;
  final int crossAxisCount;
  final double? mainAxisExtent;
  final double? childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final Widget? Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: itemCount,
      // padding: EdgeInsets.zero,
      padding: const EdgeInsets.all(AppSizes.sm),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisExtent: mainAxisExtent,
        childAspectRatio: mainAxisExtent == null ? childAspectRatio ?? 1.0 : 0,
      ),
      shrinkWrap: true,
      itemBuilder: itemBuilder,
    );
  }
}
