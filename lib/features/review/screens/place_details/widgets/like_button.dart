import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

import '../../../controllers/place_controller.dart';
import '../../../controllers/place_like_controller.dart';

class PlaceLikeButton extends StatelessWidget {
  final String placeId;

  const PlaceLikeButton({super.key, required this.placeId});

  @override
  Widget build(BuildContext context) {
    // Inject and initialize the specific controller for this placeId
    final controller = Get.put(
      PlaceLikeController(placeId: placeId),
      tag: placeId,
    );

    final PlaceController sharedController = PlaceController.instance;

    return Obx(() {
      final bool isToggling = controller.isToggling.value;
      final bool isLiked = controller.isLiked.value;

      return Column(
        children: [
          // Heart Icon Button
          GestureDetector(
            // Tapping is only allowed if the controller is NOT currently toggling
            onTap: isToggling ? null : controller.toggleLike,

            child: isToggling
                ? const SizedBox(
                    width: AppSizes.iconLg,
                    height: AppSizes.iconLg,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ) // Show loading indicator
                : Icon(
                    isLiked ? Iconsax.heart5 : Iconsax.heart,
                    color: isLiked
                        ? AppColors.favoriteColor
                        : AppColors.darkGrey,
                    size: AppSizes.iconLg,
                  ),
          ),

          const SizedBox(height: 4),

          // Like Count Text
          Text(
            sharedController.formatCount(controller.likeCount.value),
            style: Theme.of(context).textTheme.labelSmall!.apply(
              color: isLiked ? AppColors.favoriteColor : AppColors.darkGrey,
            ),
          ),
        ],
      );
    });
  }
}
