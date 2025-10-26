import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../icons/circular_icon.dart';

class AppFavouriteIcon extends StatelessWidget {
  // const AppFavouriteIcon({super.key, required this.placeId});
  const AppFavouriteIcon({super.key, this.iconSize = AppSizes.iconLg, this.height = 40, this.width = 40});

  // final String placeId;
  final double iconSize;
  final double height, width;

  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(FavouritesController());
    // return Obx(
    //   () => AppCircularIcon(
    //     icon: controller.isFavorite(placeId) ? Iconsax.heart5 : Iconsax.heart,
    //     color: controller.isFavorite(placeId)
    //         ? AppColors.favoriteColor
    //         : null,
    //     onPressed: () => controller.toggleFavoritePlace(placeId),
    //   ),
    // );

    return AppCircularIcon(
      height: height,
      width: width,
      size: iconSize,
      icon: Iconsax.heart5,
      // icon: Iconsax.heart,
      color: AppColors.favoriteColor,
      onPressed: () {},
    );
  }
}
