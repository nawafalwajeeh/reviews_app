import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/features/review/models/category_mapper.dart'
    show CategoryMapper;
import 'package:reviews_app/features/review/models/category_model.dart';
import 'package:reviews_app/features/review/screens/categories/all_categories.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

import '../../../../data/services/category/category_translation_service.dart';
import '../../../../features/review/screens/categories/category_places.dart';
import '../../../../localization/app_localizations.dart';
import '../../layouts/grid_layout.dart';
import 'category_card.dart';

class CategoryGridList extends StatelessWidget {
  final List<CategoryModel> categories;
  final int? limit;

  const CategoryGridList({super.key, required this.categories, this.limit});

  @override
  Widget build(BuildContext context) {
    final bool shouldShowMore = limit != null && categories.length > limit!;
    final int displayCount = shouldShowMore ? limit! : categories.length;

    return AppGridLayout(
      itemCount: displayCount,
      crossAxisCount: 4,
      childAspectRatio: 0.85,
      mainAxisSpacing: AppSizes.spaceBtwItems,
      crossAxisSpacing: AppSizes.spaceBtwItems,
      itemBuilder: (context, index) {
        if (shouldShowMore && index == limit! - 1) {
          return CategoryCard(
            // title: 'More',
            title: AppLocalizations.of(context).viewAll,
            icon: Icons.more_horiz_rounded,
            gradientColors: const [
              Color(0xFFBEE6D8),
              Color(0xFFA0C1FF),
            ], // Hardcoded colors
            iconColor: const Color(0xFF2D3A64),
            onTap: () => Get.to(() => const AllCategoriesScreen()),
          );
        }

        final category = categories[index];

        return CategoryCard(
          // title: category.name,
          title: CategoryTranslationService().getTranslatedNameInContext(
            category.name,
            context,
          ),
          icon: CategoryMapper.getIcon(category.iconKey),
          gradientColors: CategoryMapper.getGradientColors(
            category.gradientKey,
          ),
          iconColor: CategoryMapper.getIconColor(category.iconColorValue),
          onTap: () {
            Get.to(() => CategoryPlacesScreen(category: category));
          },
        );
      },
    );
  }
}
