import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:reviews_app/features/review/screens/categories/category_places.dart'
    show CategoryPlacesScreen;
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';
import '../../../../features/review/models/category_model.dart'
    show CategoryModel;

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  final Color iconColor;
  final VoidCallback? onTap;
  final double height;
  final double width;
  final double titleSize;

  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.gradientColors,
    required this.iconColor,
    this.height = 60,
    this.width = 60,
    this.titleSize = 55,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap:
          onTap ??
          () => Get.to(
            () => CategoryPlacesScreen(category: CategoryModel.empty()),
          ),
      child: Column(
        children: [
          AppRoundedContainer(
            width: width,
            height: height,
            radius: AppSizes.cardRadiusLg,
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
            child: Icon(icon, color: iconColor, size: AppSizes.iconMd),
          ),
          const SizedBox(height: AppSizes.spaceBtwItems / 2),
          SizedBox(
            width: titleSize,
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: Theme.of(context).textTheme.labelMedium?.apply(
                color: dark ? AppColors.white : AppColors.dark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
