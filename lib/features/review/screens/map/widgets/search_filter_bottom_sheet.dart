import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';
import '../../../controllers/place_map_controller.dart';

class SearchFilterBottomSheet extends StatelessWidget {
  const SearchFilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = PlacesMapController.instance;
    final locale = AppLocalizations.of(context);
    final dark = AppHelperFunctions.isDarkMode(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: dark ? AppColors.dark : AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.cardRadiusLg),
          topRight: Radius.circular(AppSizes.cardRadiusLg),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSizes.defaultSpace),
            child: Row(
              children: [
                Icon(Iconsax.filter, color: AppColors.primaryColor),
                const SizedBox(width: AppSizes.sm),
                Text(
                  locale.searchFilters,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: dark ? AppColors.white : AppColors.black,
                  ),
                ),
                const Spacer(),
                Obx(
                  () => controller.searchFilters.value.hasActiveFilters
                      ? TextButton(
                          onPressed: () => controller.clearAllFilters(),
                          child: Text(
                            locale.clearFilters,
                            style: TextStyle(color: AppColors.primaryColor),
                          ),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: dark ? AppColors.darkGrey : AppColors.grey),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              children: [
                // Distance Radius Section
                _buildSectionHeader(
                  context,
                  locale.distanceRadius,
                  Icons.radar,
                  dark,
                ),
                const SizedBox(height: AppSizes.md),
                _buildDistanceRadiusOptions(context, controller, locale, dark),

                const SizedBox(height: AppSizes.spaceBtwSections),

                // Area Filter Section
                _buildSectionHeader(
                  context,
                  locale.filterByArea,
                  Iconsax.map_1,
                  dark,
                ),
                const SizedBox(height: AppSizes.md),
                _buildAreaFilterOptions(context, controller, locale, dark),

                const SizedBox(height: AppSizes.spaceBtwSections),

                // Quick Filters Section
                _buildSectionHeader(
                  context,
                  locale.quickFilters,
                  Iconsax.flash_1,
                  dark,
                ),
                const SizedBox(height: AppSizes.md),
                _buildQuickFilters(context, controller, locale, dark),

                const SizedBox(height: AppSizes.lg),

                // Apply Button
                Obx(
                  () => ElevatedButton(
                    onPressed: () {
                      controller.applyFilters();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.cardRadiusMd,
                        ),
                      ),
                    ),
                    child: Text(
                      controller.searchFilters.value.hasActiveFilters
                          ? '${locale.applyFilters} (${controller.searchFilters.value.activeFilterCount})'
                          : locale.applyFilters,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    bool dark,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor),
        const SizedBox(width: AppSizes.sm),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: dark ? AppColors.white : AppColors.dark,
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceRadiusOptions(
    BuildContext context,
    PlacesMapController controller,
    AppLocalizations locale,
    bool dark,
  ) {
    final radiusOptions = [
      {'label': locale.within1km, 'value': 1000.0},
      {'label': locale.within5km, 'value': 5000.0},
      {'label': locale.within10km, 'value': 10000.0},
      {'label': locale.within25km, 'value': 25000.0},
      {'label': locale.within50km, 'value': 50000.0},
      {'label': locale.anyDistance, 'value': null},
    ];

    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: radiusOptions.map((option) {
        return Obx(() {
          final isSelected = option['value'] == null
              ? !controller.searchFilters.value.enableDistanceFilter
              : controller.searchFilters.value.radiusInMeters ==
                    option['value'];

          return FilterChip(
            label: Text(
              option['label'] as String,
              style: TextStyle(
                color: isSelected
                    ? AppColors.white
                    : (dark ? AppColors.lightGrey : AppColors.darkGrey),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              if (option['value'] == null) {
                controller.setDistanceRadius(null);
              } else {
                controller.setDistanceRadius(option['value'] as double);
              }
            },
            backgroundColor: dark
                ? AppColors.darkerGrey
                : AppColors.primaryColor.withValues(alpha: 0.05),
            selectedColor: AppColors.primaryColor,
            checkmarkColor: AppColors.white,
            side: BorderSide(
              color: isSelected
                  ? AppColors.primaryColor
                  : (dark ? AppColors.darkGrey : AppColors.grey),
            ),
          );
        });
      }).toList(),
    );
  }

  Widget _buildAreaFilterOptions(
    BuildContext context,
    PlacesMapController controller,
    AppLocalizations locale,
    bool dark,
  ) {
    return Column(
      children: [
        // Search in This Area button
        Obx(() {
          final isActive = controller.searchFilters.value.enableAreaFilter;
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryColor
                    : AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
              ),
              child: Icon(
                Iconsax.scan,
                color: isActive ? AppColors.white : AppColors.primaryColor,
                size: 20,
              ),
            ),
            title: Text(
              locale.searchInThisArea,
              style: TextStyle(
                color: dark ? AppColors.lightGrey : AppColors.dark,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            trailing: Switch(
              value: isActive,
              onChanged: (value) => controller.toggleAreaFilter(),
              activeThumbColor: AppColors.primaryColor,
            ),
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }

  Widget _buildQuickFilters(
    BuildContext context,
    PlacesMapController controller,
    AppLocalizations locale,
    bool dark,
  ) {
    final quickFilters = [
      {
        'label': locale.nearbyOnly,
        'icon': Iconsax.location,
        'getter': () => controller.searchFilters.value.nearbyOnly,
        'setter': () => controller.toggleNearbyFilter(),
      },
      {
        'label': locale.highestRated,
        'icon': Iconsax.star1,
        'getter': () => controller.searchFilters.value.highestRatedOnly,
        'setter': () => controller.toggleHighestRatedFilter(),
      },
      {
        'label': locale.mostPopular,
        'icon': Iconsax.heart,
        'getter': () => controller.searchFilters.value.mostPopularOnly,
        'setter': () => controller.toggleMostPopularFilter(),
      },
      {
        'label': locale.recentlyAdded,
        'icon': Iconsax.clock,
        'getter': () => controller.searchFilters.value.recentlyAddedOnly,
        'setter': () => controller.toggleRecentlyAddedFilter(),
      },
    ];

    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: quickFilters.map((filter) {
        return Obx(() {
          final isSelected = (filter['getter'] as Function)();
          return FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  filter['icon'] as IconData,
                  size: 16,
                  color: isSelected
                      ? AppColors.white
                      : (dark ? AppColors.lightGrey : AppColors.darkGrey),
                ),
                const SizedBox(width: 6),
                Text(
                  filter['label'] as String,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.white
                        : (dark ? AppColors.lightGrey : AppColors.darkGrey),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
            selected: isSelected,
            onSelected: (selected) => (filter['setter'] as Function)(),
            backgroundColor: dark
                ? AppColors.darkerGrey
                : AppColors.primaryColor.withValues(alpha: 0.05),
            selectedColor: AppColors.primaryColor,
            checkmarkColor: AppColors.white,
            side: BorderSide(
              color: isSelected
                  ? AppColors.primaryColor
                  : (dark ? AppColors.darkGrey : AppColors.grey),
            ),
          );
        });
      }).toList(),
    );
  }
}
