import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/place/favourite_icon/favourite_icon.dart';
import 'package:reviews_app/common/widgets/texts/place_title_text.dart';
import 'package:reviews_app/features/review/screens/place_details/place_details.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/enums.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';
import '../../../utils/constants/sizes.dart';
import '../../../features/review/models/place_model.dart';
import 'rating/place_rating_badge.dart';

class PlaceCard extends StatelessWidget {
  final PlaceModel place;
  const PlaceCard({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: () => Get.to(() => PlaceDetailsScreen()),
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
                  Positioned(
                    left: 16,
                    top: 16,
                    // child: PlaceRatingBadge(place: place),
                    child: PlaceRatingBadge(rating: place.rating),
                  ),
                  Positioned(right: 16, top: 16, child: AppFavouriteIcon()),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: PlaceTitleText(
                      title: place.title,
                      location: place.location,
                      isVerified: true,
                      placeTitleSize: TextSizes.medium,
                      isDarkBackground: true,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.categoryId,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.primaryColor),
                        ),

                        const SizedBox(height: 2),
                        Text(
                          place.description,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
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
                      'View Details',
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
}
