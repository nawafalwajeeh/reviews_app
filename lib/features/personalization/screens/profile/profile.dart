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
          'Profile',
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
                      child: Text('Change Profile Picture'),
                    ),
                  ],
                ),
              ),

              /// Details
              const SizedBox(height: AppSizes.spaceBtwItems / 2),
              const Divider(),
              const SizedBox(height: AppSizes.spaceBtwItems),

              /// Heading Profile Info
              const AppSectionHeading(
                title: 'Profile Information',
                showActionButton: false,
              ),
              const SizedBox(height: AppSizes.spaceBtwItems),

              Obx(() {
                return AppProfileMenu(
                  title: 'Name',
                  // value: 'Alwajeeh',
                  value: controller.user.value.fullName,
                  onPressed: () => Get.to(() => const ChangeName()),
                );
              }),
              Obx(
                () => AppProfileMenu(
                  title: 'Username',
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
              const AppSectionHeading(
                title: 'Personal Information',
                showActionButton: false,
              ),
              const SizedBox(height: AppSizes.spaceBtwItems),

              AppProfileMenu(
                title: 'User ID',
                // value: '12345',
                value: controller.user.value.id ?? '',
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: controller.user.value.id ?? ''),
                  );
                  AppLoaders.successSnackBar(
                    title: 'Copied',
                    message: 'User ID copied to clipboard',
                  );
                },
                icon: Iconsax.copy,
              ),
              AppProfileMenu(
                title: 'E-mail',
                // value: 'coder@gmail.com',
                value: controller.user.value.email,
                onPressed: () {},
              ),
              Obx(
                () => AppProfileMenu(
                  title: 'Phone Number',
                  // value: '+967-778-228445',
                  value: controller.user.value.phoneNumber,
                  onPressed: () => Get.to(() => const ChangePhone()),
                ),
              ),
              Obx(
                () => AppProfileMenu(
                  title: 'Gender',
                  value: controller.user.value.gender.toString(),
                  onPressed: () => Get.to(() => const ChangeGender()),
                ),
              ),
              Obx(
                () => AppProfileMenu(
                  title: 'Date of Birth',
                  value: controller.user.value.birthDate != null
                      ? '${controller.user.value.birthDate!.day}/${controller.user.value.birthDate!.month}/${controller.user.value.birthDate!.year}'
                      : 'Not set',
                  onPressed: () => Get.to(() => const ChangeBirthDate()),
                ),
              ),
              const Divider(),
              const SizedBox(height: AppSizes.spaceBtwItems),

              Center(
                child: TextButton(
                  onPressed: () => controller.deleteAccountWarningPopup(),
                  child: Text(
                    'Close Account',
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
