import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../data/repositories/place/place_repository.dart';
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

class PlaceDetailsScreen extends StatefulWidget {
  const PlaceDetailsScreen({super.key, required this.place});

  final PlaceModel place;

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  late Stream<PlaceModel> _placeStream;

  @override
  void initState() {
    super.initState();
    _placeStream = PlaceRepository.instance.streamSinglePlace(widget.place.id);
  }

  Future<void> _refreshPlace() async {
    setState(() {
      _placeStream = PlaceRepository.instance.streamSinglePlace(
        widget.place.id,
      );
    });
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final userId = AuthenticationRepository.instance.getUserID;
    final creatorId = widget.place.userId;
    Get.put(
      ReviewController(
        placeId: widget.place.id,
        placeOwnerId: widget.place.userId,
        placeName: widget.place.title,
      ),
      tag: widget.place.id,
    );

    debugPrint('UserId: $userId, creatorId: $creatorId');

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: StreamBuilder<PlaceModel>(
        key: ValueKey(_placeStream),
        stream: _placeStream,
        initialData: widget.place,
        builder: (context, snapshot) {
          final currentPlace = snapshot.data ?? widget.place;

          return RefreshIndicator(
            onRefresh: _refreshPlace,
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// -- Place Image Slider & Custom AppBar
                      PlaceImageSlider(place: currentPlace),

                      /// -- Details Content Section
                      Padding(
                        padding: const EdgeInsets.all(AppSizes.defaultSpace),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// -- Place Metadata (Title, Location, Category)
                            PlaceMetadata(place: currentPlace),
                            const SizedBox(height: AppSizes.spaceBtwItems),

                            /// -- Rating, Share, and **Like Widget**
                            _buildRatingSectionWithGetBuilder(currentPlace),
                            const SizedBox(height: AppSizes.spaceBtwItems),

                            Align(
                              alignment: Alignment.center,
                              child: PlaceLikeButton(placeId: currentPlace.id),
                            ),

                            const SizedBox(height: AppSizes.spaceBtwSections),

                            /// -- Overview & Description
                            AppSectionHeading(
                              title: AppLocalizations.of(context).description,
                              showActionButton: false,
                            ),

                            const SizedBox(height: AppSizes.spaceBtwItems),

                            ReadMoreText(
                              currentPlace.description,
                              trimLines: 2,
                              trimMode: TrimMode.Line,
                              trimCollapsedText: AppLocalizations.of(
                                context,
                              ).showMore,
                              trimExpandedText: AppLocalizations.of(
                                context,
                              ).showLess,
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
                            if (currentPlace.latitude != 0.0 &&
                                currentPlace.longitude != 0.0)
                              Column(
                                children: [
                                  PlaceMapSection(
                                    latitude: currentPlace.latitude,
                                    longitude: currentPlace.longitude,
                                    placeName: currentPlace.title,
                                    rating: currentPlace.averageRating,
                                    categoryId: currentPlace.categoryId,
                                  ),
                                  const SizedBox(
                                    height: AppSizes.spaceBtwSections,
                                  ),
                                ],
                              ),

                            /// -- Tags Section
                            AppSectionHeading(
                              title: AppLocalizations.of(context).tags,
                              showActionButton: false,
                            ),

                            AmenitiesSection(tags: currentPlace.tags ?? []),
                            const SizedBox(height: AppSizes.spaceBtwSections),

                            /// -- Review Section
                            WriteReviewWithQuestionsSection(
                              placeId: currentPlace.id,
                              place: currentPlace,
                            ),

                            const SizedBox(height: AppSizes.spaceBtwItems),

                            /// -- Barcode Section
                            if (currentPlace.barcodeData.isNotEmpty)
                              Column(
                                children: [
                                  BarcodeSection(place: currentPlace),
                                  const SizedBox(
                                    height: AppSizes.spaceBtwItems,
                                  ),
                                ],
                              ),

                            const Divider(),

                            /// -- Navigation Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () => Get.to(
                                    () =>
                                        PlaceReviewsScreen(place: currentPlace),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(Icons.arrow_back_ios, size: 18),
                                      AppSectionHeading(
                                        title: AppLocalizations.of(
                                          context,
                                        ).reviews,
                                        showActionButton: false,
                                      ),
                                    ],
                                  ),
                                ),

                                InkWell(
                                  onTap: () => Get.to(
                                    () => PlaceCommentsScreen(
                                      place: currentPlace,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      AppSectionHeading(
                                        title: AppLocalizations.of(
                                          context,
                                        ).comments,
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
        },
      ),
    );
  }

  /// GetBuilder for only rating-related data
  Widget _buildRatingSectionWithGetBuilder(PlaceModel currentPlace) {
    return GetBuilder<ReviewController>(
      tag: currentPlace.id,
      builder: (controller) {
        // Use controller data if available, otherwise use initial place data
        final currentRating = controller.currentPlaceRating.value > 0
            ? controller.currentPlaceRating.value
            : currentPlace.averageRating;

        final currentRatingDistribution =
            controller.currentPlaceRatingDistribution.isNotEmpty
            ? controller.currentPlaceRatingDistribution
            : currentPlace.ratingDistribution;

        final currentReviewsCount =
            controller.currentPlaceReviewsCount.value > 0
            ? controller.currentPlaceReviewsCount.value
            : currentPlace.reviewsCount;

        // Create a temporary place with updated rating data
        final updatedPlace = currentPlace.copyWith(
          averageRating: currentRating,
          ratingDistribution: currentRatingDistribution,
          reviewsCount: currentReviewsCount,
        );

        return RatingAndShareWidget(place: updatedPlace);
      },
    );
  }
}
