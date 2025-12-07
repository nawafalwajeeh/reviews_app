import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/features/review/models/category_extension.dart';
import 'package:reviews_app/localization/app_localizations.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/category_controller.dart';
import '../../../controllers/place_map_controller.dart';
import '../../../models/category_mapper.dart';

class CategoryFilterSheet extends StatelessWidget {
  final Function(String) onCategorySelected;
  final String selectedCategoryId;

  const CategoryFilterSheet({
    super.key,
    required this.onCategorySelected,
    required this.selectedCategoryId,
  });

  @override
  Widget build(BuildContext context) {
    final categoryController = CategoryController.instance;
    final mapController = PlacesMapController.instance;
    final locale = AppLocalizations.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: dark ? AppColors.dark : AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.cardRadiusLg),
          topRight: Radius.circular(AppSizes.cardRadiusLg),
        ),
      ),
      child: Column(
        children: [
          // Header with debug info
          Padding(
            padding: const EdgeInsets.all(AppSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Row(
                    children: [
                      Icon(Iconsax.filter, color: AppColors.primaryColor),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        locale.filterByCategory,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: dark ? AppColors.white : AppColors.black,
                            ),
                      ),
                      const Spacer(),
                      if (mapController.selectedCategoryId.value.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            onCategorySelected('');
                            Get.back();
                          },
                          child: Text(
                            locale.clear,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.primaryColor),
                          ),
                        ),
                    ],
                  ),
                ),
                // Debug info
                Obx(
                  () => Text(
                    '${mapController.displayedPlaces.length} ${locale.placesDisplayed}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: dark ? AppColors.lightGrey : AppColors.darkGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: dark ? AppColors.darkGrey : AppColors.grey),

          // Categories List
          Expanded(
            child: Obx(() {
              if (categoryController.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }

              // Count places per category for debugging
              final categoryCounts = <String, int>{};
              for (final category in categoryController.mockCategories) {
                final count = mapController.placeController.places
                    .where((place) => place.categoryId == category.id)
                    .length;
                categoryCounts[category.id] = count;
              }

              return ListView(
                padding: const EdgeInsets.all(AppSizes.defaultSpace),
                children: [
                  // All Categories option
                  _buildCategoryItem(
                    context,
                    id: '',
                    name: locale.allCategories,
                    icon: Iconsax.category,
                    isSelected: mapController.selectedCategoryId.value.isEmpty,
                    count: mapController.placeController.places.length,
                    onTap: () {
                      onCategorySelected('');
                      Get.back();
                    },
                    dark: dark,
                  ),

                  const SizedBox(height: AppSizes.sm),
                  Divider(color: dark ? AppColors.darkGrey : AppColors.grey),
                  const SizedBox(height: AppSizes.sm),

                  // Categories list with counts
                  ...categoryController.allCategories.map((category) {
                    final count = categoryCounts[category.id] ?? 0;
                    final localizedName = category.getLocalizedName(context);

                    return _buildCategoryItem(
                      context,
                      id: category.id,
                      name: localizedName,
                      icon: CategoryMapper.getIcon(category.iconKey),
                      isSelected:
                          mapController.selectedCategoryId.value == category.id,
                      count: count,
                      onTap: () {
                        if (count > 0) {
                          onCategorySelected(category.id);
                          Get.back();
                        } else {
                          Get.snackbar(
                            locale.noPlaces,
                            locale.noPlacesFoundInCategory(category.name),
                            backgroundColor: AppColors.warning,
                          );
                        }
                      },
                      dark: dark,
                    );
                  }),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context, {
    required String id,
    required String name,
    required IconData icon,
    required bool isSelected,
    required int count,
    required VoidCallback onTap,
    required bool dark,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor
              : AppColors.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.white : AppColors.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        name,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected
              ? AppColors.primaryColor
              : (dark ? AppColors.lightGrey : AppColors.darkGrey),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: dark ? AppColors.lightGrey : AppColors.darkGrey,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          if (isSelected)
            Icon(Iconsax.tick_circle, color: AppColors.primaryColor, size: 16),
        ],
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
