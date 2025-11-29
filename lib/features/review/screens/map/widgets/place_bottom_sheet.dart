import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/common/widgets/place/favourite_icon/favourite_icon.dart';
import 'package:reviews_app/common/widgets/texts/category_name_text.dart';
import 'package:reviews_app/common/widgets/texts/place_title_text.dart';
import 'package:reviews_app/features/review/models/place_model.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/enums.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../controllers/category_controller.dart';

class PlaceBottomSheet extends StatelessWidget {
  final PlaceModel place;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const PlaceBottomSheet({
    super.key,
    required this.place,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(AppSizes.defaultSpace),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: AppSizes.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.darkGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with close button
                  Row(
                    children: [
                      Expanded(
                        child: PlaceTitleText(
                          title: place.title,
                          location: place.address.shortAddress,
                          isVerified: true,
                          titleColor: AppColors.black,
                          placeTitleSize: TextSizes.medium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.close_circle),
                        onPressed: onClose,
                        color: AppColors.darkerGrey,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.md),

                  // Place thumbnail and details
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.sm),
                        child: CachedNetworkImage(
                          imageUrl: place.thumbnail,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            width: 80,
                            height: 80,
                            color: AppColors.grey,
                            child: const Icon(Iconsax.gallery),
                          ),
                        ),
                      ),

                      const SizedBox(width: AppSizes.md),

                      // Place details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Rating and reviews
                            Row(
                              children: [
                                Icon(
                                  Iconsax.star1,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: AppSizes.xs),
                                Text(
                                  place.averageRating.toStringAsFixed(1),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: AppSizes.sm),
                                Text(
                                  // '(${place.reviewsCount} reviews)',
                                  '(${place.reviewsCount} ${AppLocalizations.of(context).reviews})',

                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppColors.darkGrey),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppSizes.xs),

                            CategoryNameText(categoryId: place.categoryId),

                            const SizedBox(height: AppSizes.sm),

                            // Description preview
                            if (place.description.isNotEmpty)
                              Text(
                                place.description.length > 100
                                    ? '${place.description.substring(0, 100)}...'
                                    : place.description,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.darkGrey),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                            const SizedBox(height: AppSizes.md),

                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: onTap,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: AppSizes.sm,
                                      ),
                                      side: BorderSide(
                                        color: AppColors.primaryColor,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppSizes.cardRadiusMd,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      // 'View Details',
                                      AppLocalizations.of(context).viewDetails,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSizes.sm),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.cardRadiusMd,
                                    ),
                                  ),
                                  child: AppFavouriteIcon(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getCategoryName(String categoryId) async {
    final categoryController = CategoryController.instance;
    try {
      return await categoryController.getCategoryName(categoryId);
    } catch (e) {
      return 'Place';
    }
  }
}
