import 'package:flutter/material.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

import '../../../localization/app_localizations.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../appbar/appbar.dart';
import '../icons/circular_icon.dart';

class CustomHeader extends StatelessWidget {
  const CustomHeader({
    super.key,
    required this.title,
    required this.icon,
    // this.padding = const EdgeInsets.symmetric(vertical: AppSizes.xs),
    this.isFavorite = false,
    this.onPressed,
    this.iconBackgroundColor,
    this.favoriteCount,
  });

  final String title;
  final IconData icon;
  // final EdgeInsetsGeometry padding;
  final bool isFavorite;
  final VoidCallback? onPressed;
  final Color? iconBackgroundColor;
  final int? favoriteCount;

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    final selectedIconBackgroundColor = dark
        ? AppColors.grey
        : AppColors.darkerGrey;

    return CustomAppBar(
      title: Column(
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),

          if (isFavorite) ...[
            const SizedBox(height: AppSizes.xs),
            Text(
              // '$favoriteCount places saved',
              AppLocalizations.of(context).placesSaved(favoriteCount ?? 0),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
      actions: [
        AppCircularIcon(
          icon: icon,
          color: dark ? AppColors.dark : AppColors.light,
          backgroundColor: iconBackgroundColor ?? selectedIconBackgroundColor,
          onPressed: onPressed,
        ),
      ],
    );
  }
}
