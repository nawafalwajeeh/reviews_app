import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/common/widgets/icons/circular_icon.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/shimmers/shimmer_effect.dart';
import 'package:reviews_app/features/personalization/controllers/settings_controller.dart';
import 'package:reviews_app/features/personalization/controllers/user_controller.dart';
import 'package:reviews_app/features/review/screens/barcode/barcode_scanner.dart';
import 'package:reviews_app/routes/app_routes.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import '../../../../../localization/app_localizations.dart';
import '../../../../../utils/constants/sizes.dart';
// import '../../../../personalization/screens/locale/select_language.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());
    final settingsController = SettingsController.instance;

    return CustomAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // AppTexts.homeAppbarTitle,
            AppLocalizations.of(context).homeAppbarTitle,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.apply(color: AppColors.grey),
          ),

          Obx(() {
            if (controller.profileLoading.value) {
              return const AppShimmerEffect(width: 80, height: 15);
            } else {
              return GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.userProfile),
                child: Text(
                  controller.user.value.fullName.isNotEmpty
                      ? controller.user.value.fullName
                      : 'Gest User',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.apply(color: AppColors.white),
                ),
              );
            }
          }),
        ],
      ),
      actions: [
        AppCircularIcon(
          icon: Icons.barcode_reader,
          backgroundColor: Colors.blue[100],
          color: Colors.blue,
          size: AppSizes.iconMd,
          onPressed: () => Get.to(() => const BarcodeScannerScreen()),
        ),
        // const SizedBox(width: AppSizes.spaceBtwItems),
        // AppCircularIcon(
        //   icon: Icons.notifications_outlined,
        //   backgroundColor: Colors.blue[100],
        //   color: Colors.blue,
        //   size: AppSizes.iconMd,
        //   // onPressed: () => Get.to(() => const NotificationsScreen()),
        //   onPressed: () => Get.to(() => const SelectLanguageScreen()),
        // ),
        const SizedBox(width: AppSizes.spaceBtwItems),

        Obx(
          () => AppCircularIcon(
            icon: settingsController.themeMode == ThemeMode.dark
                ? Iconsax.moon
                : Iconsax.sun,
            backgroundColor: Colors.blue[100],
            color: Colors.blue,
            size: AppSizes.iconMd,
            onPressed: () {
              settingsController.toggleTheme(
                settingsController.themeMode == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark,
              );
            },
          ),
        ),
      ],
    );
  }
}
