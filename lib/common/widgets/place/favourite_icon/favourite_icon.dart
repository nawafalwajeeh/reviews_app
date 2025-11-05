import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../../../features/review/controllers/favourite_controller.dart';
import '../../icons/circular_icon.dart';

class AppFavouriteIcon extends StatelessWidget {
  const AppFavouriteIcon({
    super.key,
    // required this.placeId,
    this.placeId = '',
    this.iconSize = AppSizes.iconLg,
    this.height = 40,
    this.width = 40,
  });

  final String placeId;
  final double iconSize;
  final double height, width;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FavouritesController());
    return Obx(
      () => AppCircularIcon(
        icon: controller.isFavorite(placeId) ? Iconsax.heart5 : Iconsax.heart,
        color: controller.isFavorite(placeId) ? AppColors.favoriteColor : null,
        onPressed: () => controller.toggleFavoritePlaces(placeId),
      ),
    );
  }
}
