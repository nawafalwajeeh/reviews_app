import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:reviews_app/common/widgets/list_tiles/settings_menu_tile.dart';
import 'package:reviews_app/common/widgets/list_tiles/user_profile_tile.dart';
import 'package:reviews_app/common/widgets/texts/section_heading.dart';
import 'package:reviews_app/features/authentication/screens/login/login.dart';
import 'package:reviews_app/features/personalization/controllers/settings_controller.dart';
import 'package:reviews_app/features/personalization/screens/profile/profile.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/constants/text_strings.dart';

import '../../../../data/repositories/authentication/authentication_repository.dart';
import 'widgets/settings_data.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SettingsController.instance;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Header
            AppPrimaryHeaderContainer(
              child: Column(
                children: [
                  /// AppBar
                  CustomAppBar(
                    title: Text(
                      'Account',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.apply(color: AppColors.white),
                    ),
                  ),

                  /// User Profile Card
                  UserProfileTile(
                    onTap: () => Get.to(() => const ProfileScreen()),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwSections),
                ],
              ),
            ),

            /// Body
            Padding(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              child: Column(
                children: [
                  /// Account Settings
                  const AppSectionHeading(
                    title: 'Account Settings',
                    showActionButton: false,
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  /// Tiles from [accountSettings] list
                  ...accountSettings.map(
                    (tile) => SettingsMenuTile(
                      icon: tile.icon,
                      title: tile.title,
                      subTitle: tile.subTitle,
                      onTap: tile.onTap,
                      trailing: tile.trailing,
                    ),
                  ),

                  /// App Settings
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  const AppSectionHeading(
                    title: 'App Settings',
                    showActionButton: false,
                  ),

                  /// Tiles from [appSettings] list
                  ...appSettings.map(
                    (tile) => SettingsMenuTile(
                      icon: tile.icon,
                      title: tile.title,
                      subTitle: tile.subTitle,
                      onTap: tile.onTap,
                      trailing: tile.trailing,
                    ),
                  ),

                  // Special case for Dark/Light mode switch
                  Obx(
                    () => SettingsMenuTile(
                      icon: controller.themeMode == ThemeMode.dark
                          ? Iconsax.moon
                          : Iconsax.sun,
                      title: controller.themeMode == ThemeMode.dark
                          ? 'Dark Mode'
                          : 'Light Mode',
                      subTitle: 'switch dark or light mode',
                      trailing: Switch(
                        value: controller.themeMode == ThemeMode.dark,
                        onChanged: (value) => controller.toggleTheme(
                          value ? ThemeMode.dark : ThemeMode.light,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.spaceBtwSections),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () =>
                          AuthenticationRepository.instance.logout(),
                      // onPressed: () => Get.offAll(() => const LoginScreen()),
                      child: const Text(AppTexts.logout),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
