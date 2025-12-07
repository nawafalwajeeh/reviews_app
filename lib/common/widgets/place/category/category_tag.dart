import 'package:flutter/material.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

import '../../../../data/services/category/category_translation_service.dart';

class CategoryTagWidget extends StatelessWidget {
  const CategoryTagWidget({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    debugPrint('Text: $text');
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusSm),
      ),
      child: Text(
        // text,
        CategoryTranslationService().getTranslatedNameInContext(text, context),
        style: Theme.of(
          context,
        ).textTheme.labelLarge!.apply(color: AppColors.primaryColor),
      ),
    );
  }
}
