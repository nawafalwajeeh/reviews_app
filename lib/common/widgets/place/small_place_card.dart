import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/place/favourite_icon/favourite_icon.dart';
import 'package:reviews_app/common/widgets/texts/category_name_text.dart';
import 'package:reviews_app/features/review/screens/place_details/place_details.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/enums.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';

import '../../../utils/constants/sizes.dart';
import '../../../features/review/models/place_model.dart';
import '../texts/place_title_text.dart';
import 'rating/place_rating_badge.dart';

class SmallPlaceCard extends StatelessWidget {
  final PlaceModel place;
  const SmallPlaceCard({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: () => Get.to(() => PlaceDetailsScreen(place: place)),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: dark
              ? AppColors.darkerGrey
              : AppColors.grey.withValues(alpha: 0.50),
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: dark
                  ? AppColors.dark.withValues(alpha: 0.60)
                  : AppColors.grey.withValues(alpha: 0.80),
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// -- Thumbnail Image
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                    child: CachedNetworkImage(
                      imageUrl: place.thumbnail,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),

                  /// -- Gradient Overlay
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.black.withValues(alpha: 0.20),
                          // Make the bottom almost transparent
                          Colors.transparent,
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppSizes.cardRadiusLg,
                      ),
                    ),
                  ),

                  /// -- Rating
                  Positioned(
                    left: AppSizes.sm,
                    top: AppSizes.sm,
                    child: PlaceRatingBadge(
                      rating: place.averageRating,
                      isSmall: true,
                    ),
                  ),

                  /// -- Favourite Icon
                  Positioned(
                    right: AppSizes.sm,
                    top: AppSizes.sm,
                    child: AppFavouriteIcon(
                      iconSize: AppSizes.iconMd,
                      height: 30,
                      width: 30,
                      placeId: place.id,
                    ),
                  ),
                ],
              ),
            ),

            /// -- Category & View Details
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// -- Category Text
                  Expanded(
                    // child: Text(
                    //   place.categoryId,
                    //   style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    //     color: AppColors.primaryColor,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    //   overflow: TextOverflow.ellipsis,
                    //   maxLines: 1,
                    // ),
                    // child: CategoryNameText(categoryId: place.categoryId),
                    child: CategoryNameText(
                      categoryId: place.categoryId,
                      textColor: AppHelperFunctions.isDarkMode(context)
                          ? AppColors.textWhite
                          : AppColors.primaryColor,
                    ),
                    //  child: ReactiveCategoryNameText(categoryId: place.categoryId),
                  ),

                  /// -- Subtle button to indicate tap/view details
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: AppSizes.iconXs,
                    color: AppColors.darkGrey,
                  ),
                ],
              ),
            ),

            /// -- Title and Location
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.sm,
                0,
                AppSizes.sm,
                // AppSizes.xs,
                0,
              ),
              child: PlaceTitleText(
                title: place.title,
                // location: place.location,
                // location: place.address.toString(),
                location: place.address.shortAddress,
                isDarkBackground: false,
                isVerified: true,
                placeTitleSize: TextSizes.small,
                maxLines: 1,
                titleColor: dark ? AppColors.light : AppColors.dark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
