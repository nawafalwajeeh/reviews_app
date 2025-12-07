import 'package:flutter/material.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/colors.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';

class CommunityGuidelinesBox extends StatelessWidget {
  const CommunityGuidelinesBox({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    return Container(
      decoration: BoxDecoration(
        color: dark ? AppColors.dark : AppColors.grey,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(blurRadius: 4, color: AppColors.dark, offset: Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.all(AppSizes.defaultSpace / 2),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: dark ? AppColors.white : AppColors.primaryColor,
          ),
          const SizedBox(width: AppSizes.spaceBtwItems - 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // 'Community Guidelines',
                  AppLocalizations.of(context).communityGuidelines,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: dark ? AppColors.white : AppColors.primaryColor,
                  ),
                ),
                Text(
                  // 'Please ensure your place is appropriate and follows our community standards',
                  AppLocalizations.of(context).ensureAppropriate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? AppColors.white : AppColors.primaryColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
