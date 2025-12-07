import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/place/favourite_icon/favourite_icon.dart';
import 'package:reviews_app/common/widgets/texts/category_name_text.dart';
import 'package:reviews_app/common/widgets/texts/place_title_text.dart';
import 'package:reviews_app/features/review/screens/place_details/place_details.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/enums.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../features/review/models/place_model.dart';
import 'rating/place_rating_badge.dart';

class PlaceCard extends StatelessWidget {
  final PlaceModel place;
  final bool showEditOptions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PlaceCard({
    super.key,
    required this.place,
    this.showEditOptions = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: () => Get.to(() => PlaceDetailsScreen(place: place)),
      child: Container(
        decoration: BoxDecoration(
          color: dark ? AppColors.darkerGrey : AppColors.grey,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: AppColors.dark,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: place.thumbnail,
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.transparent, Color(0x80000000)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  // Rating Badge (Top Left)
                  Positioned(
                    left: 16,
                    top: 16,
                    child: PlaceRatingBadge(rating: place.averageRating),
                  ),

                  // Heart Icon (Top Right - Fixed Position)
                  Positioned(
                    right: 16,
                    top: 16,
                    child: AppFavouriteIcon(placeId: place.id),
                  ),

                  // Edit/Delete Buttons (Bottom Right)
                  if (showEditOptions)
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: _buildEditDeleteButtons(),
                    ),

                  // Place Title (Bottom Left)
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: PlaceTitleText(
                      title: place.title,
                      location: place.address.shortAddress,
                      isVerified: true,
                      placeTitleSize: TextSizes.medium,
                      isDarkBackground: true,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              // Reduced vertical padding from 18 to 14 to prevent 6.0 pixel overflow ***
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Category Name (Moved up)
                        CategoryNameText(
                          categoryId: place.categoryId,
                          textColor: AppHelperFunctions.isDarkMode(context)
                              ? AppColors.textWhite
                              : AppColors.primaryColor,
                        ),
                        // ReactiveCategoryNameText(categoryId: place.categoryId),
                        const SizedBox(height: AppSizes.sm),

                        /// Creator Avatar and Name
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: CachedNetworkImage(
                                imageUrl: place.creatorAvatarUrl,
                                placeholder: (context, url) =>
                                    const Icon(Icons.person, size: 24),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.person, size: 24),
                                width: 24,
                                height: 24,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: AppSizes.spaceBtwItems / 2),
                            Expanded(
                              child: Text(
                                place.creatorName,
                                style: Theme.of(context).textTheme.labelMedium!
                                    .apply(
                                      color: dark
                                          ? AppColors.lightGrey
                                          : AppColors.darkGrey,
                                      fontSizeFactor: 1.1,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceBtwItems / 2),

                  /// -- View Details Button
                  Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      // 'View Details',
                      AppLocalizations.of(context).viewDetails,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.apply(color: AppColors.light),
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

  Widget _buildEditDeleteButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Edit Button
          IconButton(
            icon: const Icon(Icons.edit, size: 18, color: Colors.white),
            onPressed: onEdit,
          ),

          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
