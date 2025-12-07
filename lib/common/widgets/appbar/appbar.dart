import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/common/widgets/icons/circular_icon.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/device/device_utility.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';

import '../../../data/services/localization/localization_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.leadingIcon,
    this.actions,
    this.leadingOnPressed,
    this.showBackArrow = false,
    this.centerTitle = false,
  });

  final Widget? title;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final localizationService = LocalizationService.instance;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: AppBar(
        title: title,
        centerTitle: centerTitle,
        automaticallyImplyLeading: false,
        leading: showBackArrow
            ? IconButton(
                // onPressed: () => Get.back(),
                onPressed: () {
                  // if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                  // }
                },
                icon: AppCircularIcon(
                  icon: localizationService.isRTL()
                      ? Iconsax.arrow_right
                      : Iconsax.arrow_left,
                  color: AppHelperFunctions.isDarkMode(context)
                      ? AppColors.white
                      : AppColors.dark,
                ),
              )
            : leadingIcon != null
            ? IconButton(
                onPressed: leadingOnPressed,
                icon: Icon(
                  leadingIcon,
                  color: AppHelperFunctions.isDarkMode(context)
                      ? AppColors.white
                      : AppColors.dark,
                ),
              )
            : null,
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppDeviceUtils.getAppBarHeight());
}
