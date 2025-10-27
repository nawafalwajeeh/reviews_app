import 'package:flutter/material.dart';
import 'package:reviews_app/utils/constants/sizes.dart' show AppSizes;
import 'package:reviews_app/utils/helpers/helper_functions.dart';

import '../../../../../utils/constants/colors.dart';

class PlaceCategoryListTile extends StatelessWidget {
  final String categoryName;
  final IconData icon;
  final VoidCallback onTap;

  const PlaceCategoryListTile({
    super.key,
    required this.categoryName,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.sm,
          horizontal: AppSizes.md,
        ),
        margin: const EdgeInsets.only(bottom: AppSizes.xs),
        decoration: BoxDecoration(
          color: dark ? AppColors.darkerGrey : AppColors.light,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkGrey.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.cardRadiusSm),
                color: AppColors.softGrey,
              ),
              child: Icon(
                icon, // Uses the single, generic icon passed
                color: AppColors.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSizes.md),

            Expanded(
              child: Text(
                categoryName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: dark ? AppColors.white : AppColors.dark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: AppSizes.iconSm,
              color: AppColors.darkGrey,
            ),
          ],
        ),
      ),
    );
  }
}