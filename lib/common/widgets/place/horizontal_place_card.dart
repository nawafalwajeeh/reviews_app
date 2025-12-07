import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/place/favourite_icon/favourite_icon.dart';
import 'package:reviews_app/common/widgets/texts/category_name_text.dart';
import 'package:reviews_app/common/widgets/texts/place_title_text.dart';
import 'package:reviews_app/data/services/localization/localization_service.dart';
import 'package:reviews_app/features/review/screens/place_details/place_details.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/enums.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../features/review/models/place_model.dart';
import 'rating/place_rating_badge.dart';

class PlaceCardHorizontal extends StatelessWidget {
  final PlaceModel place;
  final double?
  height; // Still allowing height to be set, but we'll manage content
  final bool showEditOptions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PlaceCardHorizontal({
    super.key,
    required this.place,
    this.height = 180,
    this.showEditOptions = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    const double cardWidth = 360;
    const double imageHeightRatio = 0.65;
    final double imageSectionWidth = cardWidth * imageHeightRatio;
    final double detailsSectionWidth = cardWidth * (1 - imageHeightRatio);

    return GestureDetector(
      onTap: () => Get.to(() => PlaceDetailsScreen(place: place)),
      child: Container(
        height: height,
        width: cardWidth,
        margin: const EdgeInsets.only(right: AppSizes.md),
        decoration: BoxDecoration(
          color: dark ? AppColors.darkerGrey : AppColors.light,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkGrey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// -- Thumbnail Image Section
            SizedBox(
              width: imageSectionWidth,
              child: Stack(
                children: [
                  /// -- Main Image
                  ClipRRect(
                    borderRadius: !LocalizationService.instance.isRTL()
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(AppSizes.cardRadiusLg),
                            bottomLeft: Radius.circular(AppSizes.cardRadiusLg),
                          )
                        : const BorderRadius.only(
                            topRight: Radius.circular(AppSizes.cardRadiusLg),
                            bottomRight: Radius.circular(AppSizes.cardRadiusLg),
                          ),
                    child: CachedNetworkImage(
                      imageUrl: place.thumbnail,
                      height: double.infinity, // Fill available height
                      width: double.infinity, // Fill available width
                      fit: BoxFit.cover, // Cover the entire area
                      placeholder: (context, url) =>
                          Container(color: AppColors.lightGrey),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: AppColors.grey,
                          size: 40,
                        ),
                      ),
                    ),
                  ),

                  /// -- Gradient Overlay (for title readability)
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          dark
                              ? AppColors.dark.withValues(alpha: 0.4)
                              : AppColors.black.withValues(alpha: 0.2),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppSizes.cardRadiusLg),
                        bottomLeft: Radius.circular(AppSizes.cardRadiusLg),
                      ),
                    ),
                  ),

                  /// -- Rating Badge (Top Left)
                  Positioned(
                    left: AppSizes.sm,
                    top: AppSizes.sm,
                    child: PlaceRatingBadge(rating: place.averageRating),
                  ),

                  /// -- Favourite Icon (Top Right)
                  Positioned(
                    right: AppSizes.sm,
                    top: AppSizes.sm,
                    child: AppFavouriteIcon(placeId: place.id),
                  ),

                  if (showEditOptions)
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: _buildEditDeleteButtons(),
                    ),

                  /// -- Place Title and Location (Overlayed at the Bottom)
                  Positioned(
                    left: AppSizes.md, // Increased padding
                    right: AppSizes.md, // Increased padding
                    bottom: AppSizes.md, // Increased padding
                    child: PlaceTitleText(
                      title: place.title,
                      // location: place.location,
                      // location: place.address.toString(),
                      location: place.address.shortAddress,
                      isVerified: true, // Assuming verification status
                      placeTitleSize: TextSizes.small,
                      isDarkBackground: true,
                    ),
                  ),
                ],
              ),
            ),

            /// -- Details Section (Category, Description, Button)
            SizedBox(
              width: detailsSectionWidth,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// -- Top part: Category, Description
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // CategoryNameText(categoryId: place.categoryId),
                         CategoryNameText(
                          categoryId: place.categoryId,
                          textColor: AppHelperFunctions.isDarkMode(context)
                              ? AppColors.textWhite
                              : AppColors.primaryColor,
                        ),

                        const SizedBox(height: AppSizes.xs),
                        Text(
                          place.description,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.darkGrey,
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ),

                    /// -- View Details Button
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(
                            AppSizes.borderRadiusLg,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          // 'View Details',
                          AppLocalizations.of(context).viewDetails,
                          style: Theme.of(context).textTheme.labelLarge?.apply(
                            color: AppColors.white,
                            fontWeightDelta: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
