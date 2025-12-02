import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/review_controller.dart';
import '../../models/place_model.dart';
import '../place_reviews/place_comments.dart';
import '../place_reviews/place_reviews.dart';
import 'widgets/barcode_section.dart';
import 'widgets/details_image_slider.dart';
import 'widgets/like_button.dart';
import 'widgets/place_aminities.dart';
import 'widgets/place_map_section.dart';
import 'widgets/place_meta_data.dart';
import 'widgets/rating_share.dart';
import 'widgets/write_review.dart';

class PlaceDetailsScreen extends StatelessWidget {
  const PlaceDetailsScreen({super.key, required this.place});

  final PlaceModel place;

  @override
  Widget build(BuildContext context) {
    final userId = AuthenticationRepository.instance.getUserID;
    final creatorId = place.userId;
    Get.put(ReviewController(placeId: place.id), tag: place.id);

    debugPrint('UserId: $userId, creatorId: $creatorId');

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// -- Place Image Slider & Custom AppBar
                PlaceImageSlider(place: place),

                /// -- Details Content Section
                Padding(
                  padding: const EdgeInsets.all(AppSizes.defaultSpace),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// -- Place Metadata (Title, Location, Category)
                      PlaceMetadata(place: place),
                      const SizedBox(height: AppSizes.spaceBtwItems),

                      /// -- Rating, Share, and **Like Widget**
                      // RatingAndShareWidget(place: place),
                      _buildRatingSectionWithGetBuilder(),
                      const SizedBox(height: AppSizes.spaceBtwItems),

                      Align(
                        alignment: Alignment.center,
                        child: PlaceLikeButton(placeId: place.id),
                      ),

                      const SizedBox(height: AppSizes.spaceBtwSections),

                      /// -- Overview & Description
                      AppSectionHeading(
                        // title: 'Description',
                        title: AppLocalizations.of(context).description,
                        showActionButton: false,
                      ),

                      const SizedBox(height: AppSizes.spaceBtwItems),

                      ReadMoreText(
                        place.description,
                        trimLines: 2,
                        trimMode: TrimMode.Line,
                        // trimCollapsedText: ' Show more',
                        trimCollapsedText: AppLocalizations.of(
                          context,
                        ).showMore,
                        // trimExpandedText: ' Less',
                        trimExpandedText: AppLocalizations.of(context).showLess,
                        moreStyle: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        lessStyle: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: AppSizes.spaceBtwSections),

                      /// -- Map Section
                      if (place.latitude != 0.0 && place.longitude != 0.0)
                        Column(
                          children: [
                            PlaceMapSection(
                              latitude: place.latitude,
                              longitude: place.longitude,
                              placeName: place.title,
                              rating: place.averageRating,
                            ),
                            const SizedBox(height: AppSizes.spaceBtwSections),
                          ],
                        ),

                      /// -- Tags Section
                      AppSectionHeading(
                        // title: 'Tags',
                        title: AppLocalizations.of(context).tags,
                        showActionButton: false,
                      ),

                      AmenitiesSection(tags: place.tags ?? []),
                      const SizedBox(height: AppSizes.spaceBtwSections),

                      /// -- Review Section
                      WriteReviewWithQuestionsSection(
                        placeId: place.id,
                        place: place,
                      ),

                      const SizedBox(height: AppSizes.spaceBtwItems),

                      /// -- Barcode Section
                      if (place.barcodeData.isNotEmpty)
                        Column(
                          children: [
                            BarcodeSection(place: place),
                            const SizedBox(height: AppSizes.spaceBtwItems),
                          ],
                        ),

                      const Divider(),

                      /// -- Navigation Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () =>
                                Get.to(() => PlaceReviewsScreen(place: place)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.arrow_back_ios, size: 18),
                                AppSectionHeading(
                                  // title: 'Reviews',
                                  title: AppLocalizations.of(context).reviews,
                                  showActionButton: false,
                                ),
                              ],
                            ),
                          ),

                          InkWell(
                            onTap: () =>
                                Get.to(() => PlaceCommentsScreen(place: place)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppSectionHeading(
                                  // title: 'Comments',
                                  title: AppLocalizations.of(context).comments,
                                  showActionButton: false,
                                ),
                                Icon(Icons.arrow_forward_ios, size: 18),
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
        ],
      ),
    );
  }

  /// GetBuilder for only rating-related data
  Widget _buildRatingSectionWithGetBuilder() {
    return GetBuilder<ReviewController>(
      tag: place.id,
      builder: (controller) {
        // Use controller data if available, otherwise use initial place data
        final currentRating = controller.currentPlaceRating.value > 0
            ? controller.currentPlaceRating.value
            : place.averageRating;

        final currentRatingDistribution =
            controller.currentPlaceRatingDistribution.isNotEmpty
            ? controller.currentPlaceRatingDistribution
            : place.ratingDistribution;

        final currentReviewsCount =
            controller.currentPlaceReviewsCount.value > 0
            ? controller.currentPlaceReviewsCount.value
            : place.reviewsCount;

        // Create a temporary place with updated rating data
        final updatedPlace = place.copyWith(
          averageRating: currentRating,
          ratingDistribution: currentRatingDistribution,
          reviewsCount: currentReviewsCount,
        );

        return RatingAndShareWidget(place: updatedPlace);
      },
    );
  }
}
