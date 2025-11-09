import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/common/widgets/icons/circular_icon.dart';
import 'package:reviews_app/common/widgets/images/circular_image.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/image_strings.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

import '../../../features/personalization/controllers/user_controller.dart';
import '../shimmers/shimmer_effect.dart';

class UserProfileTile extends StatelessWidget {
  const UserProfileTile({
    super.key,
    this.imageUrl = AppImages.user,
    this.userName = '',
    this.email = '',
    this.onTap,
  });
  final String imageUrl, userName;
  final String email;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;

    return Obx(() {
      final networkImage = controller.user.value.profilePicture;
      final isNetwork =
          networkImage.isNotEmpty && networkImage.startsWith('http');
      final image = isNetwork ? networkImage : AppImages.user;

      return ListTile(
        leading: controller.profileLoading.value
            ? const AppShimmerEffect(width: 50, height: 50, radius: 50)
            : AppCircularImage(
                isNetworkImage: isNetwork,
                image: image,
                height: 50,
                width: 50,
                padding: 0,
              ),
        title: Text(
          controller.user.value.fullName.isNotEmpty
              ? controller.user.value.fullName
              : 'Guest User',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.apply(color: AppColors.white),
        ),
        subtitle: Text(
          controller.user.value.email.isNotEmpty
              ? controller.user.value.email
              : 'guest@gmail.com',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.apply(color: AppColors.white),
        ),
        trailing: AppCircularIcon(
          backgroundColor: Colors.transparent,
          size: AppSizes.iconMd,
          icon: Iconsax.edit,
          color: AppColors.white,
          onPressed: onTap,
        ),
      );
    });
  }
}
