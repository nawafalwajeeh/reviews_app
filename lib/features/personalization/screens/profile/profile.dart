import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/common/widgets/images/circular_image.dart';
import 'package:reviews_app/common/widgets/shimmers/shimmer_effect.dart';
import 'package:reviews_app/common/widgets/texts/section_heading.dart';
import 'package:reviews_app/features/personalization/screens/profile/widgets/change_dob.dart';
import 'package:reviews_app/features/personalization/screens/profile/widgets/change_gender.dart';
import 'package:reviews_app/features/personalization/screens/profile/widgets/change_phone_number.dart';
import 'package:reviews_app/features/personalization/screens/profile/widgets/profile_menu.dart';
import 'package:reviews_app/utils/constants/image_strings.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../../../localization/app_localizations.dart' show AppLocalizations;
import '../../../../utils/popups/loaders.dart';
import '../../controllers/user_controller.dart';
import 'widgets/change_name.dart';
import 'widgets/change_username.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;

    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          // 'Profile',
          AppLocalizations.of(context).profile,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            children: [
              /// Profile Picture
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Obx(() {
                      final networkImage = controller.user.value.profilePicture;
                      final isNetwork =
                          networkImage.isNotEmpty &&
                          networkImage.startsWith('http');
                      final image = isNetwork ? networkImage : AppImages.user;

                      return controller.imageUploading.value
                          ? AppShimmerEffect(width: 88, height: 88, radius: 88)
                          : AppCircularImage(
                              width: 80,
                              height: 80,
                              isNetworkImage: networkImage.isNotEmpty,
                              // image: AppImages.user,
                              image: image,
                            );
                    }),
                    TextButton(
                      onPressed: () => controller.uploadUserProfilePicture(),
                      // child: Text('Change Profile Picture'),
                      child: Text(
                        AppLocalizations.of(context).changeProfilePicture,
                      ),
                    ),
                  ],
                ),
              ),

              /// Details
              const SizedBox(height: AppSizes.spaceBtwItems / 2),
              const Divider(),
              const SizedBox(height: AppSizes.spaceBtwItems),

              /// Heading Profile Info
              AppSectionHeading(
                // title: 'Profile Information',
                title: AppLocalizations.of(context).profileInformation,
                showActionButton: false,
              ),
              const SizedBox(height: AppSizes.spaceBtwItems),

              Obx(() {
                return AppProfileMenu(
                  // title: 'Name',
                  title: AppLocalizations.of(context).name,
                  // value: 'Alwajeeh',
                  value: controller.user.value.fullName,
                  onPressed: () => Get.to(() => const ChangeName()),
                );
              }),
              Obx(
                () => AppProfileMenu(
                  // title: 'Username',
                  title: AppLocalizations.of(context).username,
                  // value: 'Top_coder',
                  value: controller.user.value.userName,
                  onPressed: () => Get.to(() => const ChangeUsername()),
                ),
              ),
              const SizedBox(height: AppSizes.spaceBtwItems),

              const SizedBox(height: AppSizes.spaceBtwItems / 2),
              const Divider(),
              const SizedBox(height: AppSizes.spaceBtwItems),

              /// Heading Personal Info
              AppSectionHeading(
                // title: 'Personal Information',
                title: AppLocalizations.of(context).personalInformation,
                showActionButton: false,
              ),
              const SizedBox(height: AppSizes.spaceBtwItems),

              AppProfileMenu(
                // title: 'User ID',
                title: AppLocalizations.of(context).userId,
                // value: '12345',
                value: controller.user.value.id ?? '',
                isArrowIcon: false,
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: controller.user.value.id ?? ''),
                  );
                  AppLoaders.successSnackBar(
                    // title: 'Copied',
                    title: AppLocalizations.of(context).copied,
                    // message: 'User ID copied to clipboard',
                    message: AppLocalizations.of(context).userIdCopied,
                  );
                },
                icon: Iconsax.copy,
              ),
              Obx(() {
                final userEmail = controller.user.value.email;
                return AppProfileMenu(
                  // title: 'E-mail',
                  title: AppLocalizations.of(context).email,
                  // value: 'coder@gmail.com',
                  value: userEmail,
                  isArrowIcon: false,
                  onPressed: () {
                    // Only attempt to copy if the email is valid (not the placeholder)
                    if (userEmail.isNotEmpty) {
                      Clipboard.setData(ClipboardData(text: userEmail));
                      AppLoaders.successSnackBar(
                        title: AppLocalizations.of(context).copied,
                        message: AppLocalizations.of(
                          context,
                        ).copied, // Should probably be a different message key
                      );
                    }
                  },
                  icon: Iconsax.copy,
                );
              }),
              Obx(
                () => AppProfileMenu(
                  // title: 'Phone Number',
                  title: AppLocalizations.of(context).phoneNumber,
                  // value: '+967-778-228445',
                  value: controller.user.value.phoneNumber,
                  onPressed: () => Get.to(() => const ChangePhone()),
                ),
              ),
              Obx(
                () => AppProfileMenu(
                  // title: 'Gender',
                  title: AppLocalizations.of(context).gender,
                  value: controller.user.value.gender.toString(),
                  onPressed: () => Get.to(() => const ChangeGender()),
                ),
              ),
              Obx(
                () => AppProfileMenu(
                  // title: 'Date of Birth',
                  title: AppLocalizations.of(context).dateOfBirth,
                  value: controller.user.value.birthDate != null
                      ? '${controller.user.value.birthDate!.day}/${controller.user.value.birthDate!.month}/${controller.user.value.birthDate!.year}'
                      // : 'Not set',
                      : AppLocalizations.of(context).notSet,
                  onPressed: () => Get.to(() => const ChangeBirthDate()),
                ),
              ),
              const Divider(),
              const SizedBox(height: AppSizes.spaceBtwItems),

              Center(
                child: TextButton(
                  onPressed: () => controller.deleteAccountWarningPopup(),
                  child: Text(
                    // 'Close Account',
                    AppLocalizations.of(context).closeAccount,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
