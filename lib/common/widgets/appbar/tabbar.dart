import 'package:flutter/material.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/device/device_utility.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  /// If you want to add a backgroundColor to tabs you have to wrap them in Material Widget
  /// To do that we need [PreferredSizeWidget] and that's why created custom class
  const CustomTabBar({super.key, required this.tabs});

  final List<Widget> tabs;
  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);

    return Material(
      color: dark ? AppColors.black : AppColors.white,
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          color: AppColors.primaryColor,
        ),
        labelPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceBtwItems,
        ),
        indicatorPadding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 6,
        ),
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.darkGrey,
        labelStyle: Theme.of(
          context,
        ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: Theme.of(context).textTheme.titleSmall,
        indicatorWeight: 0.1,
        tabs: tabs,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppDeviceUtils.getAppBarHeight());
}
