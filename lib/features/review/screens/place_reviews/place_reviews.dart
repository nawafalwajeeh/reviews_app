import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/common/widgets/place/rating/rating_indicator.dart';
import 'package:reviews_app/features/review/screens/place_reviews/widgets/user_review_card.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

import '../../../../localization/app_localizations.dart';
import '../../models/place_model.dart';
import '../../models/review_model.dart';
import '../../controllers/review_controller.dart'; // Import the controller
import 'widgets/rating_progress_indicator.dart';

class PlaceReviewsScreen extends StatelessWidget {
  final PlaceModel place;

  const PlaceReviewsScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    // 1. Initialize the controller (GetX handles lifecycle and instance).
    // Assuming place.id is available and correct.
    final controller = Get.put(ReviewController(placeId: place.id));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        showBackArrow: true,
        // title: Text('Rating & Reviews'),
        // title: Text(AppLocalizations.of(context).ratingReviews),
        title: Text(
          '${AppLocalizations.of(context).ratingReviews} & ${AppLocalizations.of(context).reviews}',
        ),
      ),
      body: Column(
        children: [
          /// -- Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Text(
                    // 'Ratings and reviews are verified and are from people who use the same type of device that you use.',
                    AppLocalizations.of(context).ratingsVerified,
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  /// Overall Rating Indicator - Use GetBuilder
                  GetBuilder<ReviewController>(
                    tag: place.id,
                    builder: (controller) {
                      final currentRating =
                          controller.currentPlaceRating.value > 0
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

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OverallPlaceRating(
                            rating: currentRating.toStringAsFixed(1),
                            totalReviews: currentReviewsCount,
                            ratingDistribution: currentRatingDistribution,
                          ),

                          /// Rating Bar Indicator
                          AppRatingBarIndicator(rating: currentRating),
                          Text(
                            // '$currentReviewsCount reviews',
                            '$currentReviewsCount ${AppLocalizations.of(context).reviews}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: AppSizes.spaceBtwSections),

                  /// User Reviews List - StreamBuilder for Real-time Data
                  StreamBuilder<List<ReviewModel>>(
                    // Assumes a public getter `reviewRepository` exists in ReviewController
                    stream: controller.reviewRepo.streamReviewsForPlace(
                      place.id,
                    ),
                    builder: (context, snapshot) {
                      // 1. Loading State
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // 2. Error State
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            // 'Error loading reviews: ${snapshot.error}',
                            AppLocalizations.of(context).errorLoadingReviews,
                          ),
                        );
                      }

                      final reviews = snapshot.data;

                      // 3. No Data State
                      if (reviews == null || reviews.isEmpty) {
                        return Center(
                          // child: Text('No reviews found for this place.'),
                          child: Text(
                            AppLocalizations.of(context).noReviewsFound,
                          ),
                        );
                      }

                      // 4. Data Loaded State - Display the List of Reviews
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSizes.spaceBtwSections),
                        itemBuilder: (_, index) {
                          final review = reviews[index];
                          // Pass the fetched ReviewModel to the UserReviewCard
                          return UserReviewCard(review: review);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
