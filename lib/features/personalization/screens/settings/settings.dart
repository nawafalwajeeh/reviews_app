import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:reviews_app/common/widgets/list_tiles/settings_menu_tile.dart';
import 'package:reviews_app/common/widgets/list_tiles/user_profile_tile.dart';
import 'package:reviews_app/common/widgets/texts/section_heading.dart';
import 'package:reviews_app/features/personalization/controllers/settings_controller.dart';
import 'package:reviews_app/features/personalization/screens/profile/profile.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../localization/app_localizations.dart';
import 'widgets/language_switch.dart';
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
                      // 'Account',
                      AppLocalizations.of(context).account,
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
                  AppSectionHeading(
                    // title: 'Account Settings',
                    title: AppLocalizations.of(context).accountSettings,
                    showActionButton: false,
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  /// Tiles from [accountSettings] list
                  ...accountSettings(context).map(
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
                  AppSectionHeading(
                    // title: 'App Settings',
                    title: AppLocalizations.of(context).appSettings,
                    showActionButton: false,
                  ),

                  /// Tiles from [appSettings] list
                  ...appSettings(context).map(
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
                      //     title: controller.themeMode == ThemeMode.dark
                      //         ? 'Dark Mode'
                      //         : 'Light Mode',
                      title: controller.themeMode == ThemeMode.dark
                          ? AppLocalizations.of(context).darkMode
                          : AppLocalizations.of(context).lightMode,
                      // subTitle: 'switch dark or light mode',
                      subTitle: AppLocalizations.of(context).switchTheme,
                      trailing: Switch(
                        value: ThemeMode.system == ThemeMode.dark
                            ? true
                            : controller.themeMode == ThemeMode.dark,
                        onChanged: (value) => controller.toggleTheme(
                          value ? ThemeMode.dark : ThemeMode.light,
                        ),
                      ),
                    ),
                  ),

                  /// Change Language Dropdown
                  LanguageSwitchWidget(),

                  /// Logout button
                  const SizedBox(height: AppSizes.spaceBtwSections),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () =>
                          AuthenticationRepository.instance.logout(),
                      // onPressed: () => Get.offAll(() => const LoginScreen()),
                      // child: const Text(AppTexts.logout),
                      child: Text(AppLocalizations.of(context).logout),
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
