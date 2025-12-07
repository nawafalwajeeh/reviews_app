import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/device/device_utility.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';

import '../../../../features/review/controllers/search_controller.dart';

class AppSearchContainer extends StatelessWidget {
  const AppSearchContainer({
    super.key,
    required this.text,
    this.showBackground = true,
    this.icon = Iconsax.search_normal,
    this.showBorder = true,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSizes.defaultSpace,
    ),
  });

  final String text;
  final IconData? icon;
  final bool showBackground, showBorder;
  final void Function()? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    // final searchController = AppSearchController.instance;
    final searchController = Get.put(AppSearchController());
    final dark = AppHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Container(
          width: AppDeviceUtils.getScreenWidth(context),
          padding: const EdgeInsets.all(AppSizes.md - 4),
          decoration: BoxDecoration(
            color: showBackground
                ? dark
                      ? AppColors.dark
                      : AppColors.light
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
            border: showBorder ? BoxBorder.all(color: AppColors.grey) : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: dark ? AppColors.darkerGrey : AppColors.grey),
              const SizedBox(width: AppSizes.spaceBtwItems),
              Expanded(
                child: Obx(
                  () => Text(
                    searchController.searchQuery.value.isNotEmpty
                        ? searchController.searchQuery.value
                        : text,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              Icon(
                Icons.mic,
                color: dark ? AppColors.darkerGrey : AppColors.grey,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
