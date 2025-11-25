import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

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

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.white,
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
                Row(
                  children: [
                    Icon(Iconsax.filter, color: AppColors.primaryColor),
                    const SizedBox(width: AppSizes.sm),
                    Text(
                      'Filter by Category',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    if (selectedCategoryId.isNotEmpty)
                      TextButton(
                        onPressed: () => onCategorySelected(''),
                        child: Text(
                          'Clear',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.primaryColor),
                        ),
                      ),
                  ],
                ),
                // Debug info
                Obx(
                  () => Text(
                    '${mapController.displayedPlaces.length} places displayed',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.darkGrey),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Categories List
          Expanded(
            child: Obx(() {
              if (categoryController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
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
                    name: 'All Categories',
                    icon: Iconsax.category,
                    isSelected: selectedCategoryId.isEmpty,
                    count: mapController.placeController.places.length,
                    onTap: () => onCategorySelected(''),
                  ),

                  const SizedBox(height: AppSizes.sm),
                  const Divider(),
                  const SizedBox(height: AppSizes.sm),

                  // Categories list with counts
                  ...categoryController.allCategories.map((category) {
                    final count = categoryCounts[category.id] ?? 0;
                    return _buildCategoryItem(
                      context,
                      id: category.id,
                      name: category.name,
                      icon: CategoryMapper.getIcon(category.iconKey),
                      isSelected: selectedCategoryId == category.id,
                      count: count,
                      onTap: () {
                        if (count > 0) {
                          onCategorySelected(category.id);
                        } else {
                          Get.snackbar(
                            'No Places',
                            'No places found in ${category.name} category',
                            backgroundColor: AppColors.warning,
                          );
                        }
                      },
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
          color: isSelected ? AppColors.primaryColor : AppColors.darkGrey,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.darkGrey),
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
