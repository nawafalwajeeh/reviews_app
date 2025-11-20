import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/common/widgets/place/rating/rating_indicator.dart';
import 'package:reviews_app/features/review/screens/place_reviews/widgets/user_review_card.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

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
      appBar: const CustomAppBar(
        showBackArrow: true,
        title: Text('Rating & Reviews'),
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
                  const Text(
                    'Ratings and reviews are verified and are from people who use the same type of device that you use.',
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  /// Overall Rating Indicator
                  OverallPlaceRating(
                    rating: place.averageRating.toStringAsFixed(1),
                    totalReviews: place.reviewsCount,
                    ratingDistribution: place.ratingDistribution,
                  ),

                  /// Rating Bar Indicator
                  AppRatingBarIndicator(rating: place.averageRating),
                  Text(
                    '${place.reviewsCount} reviews',
                    style: Theme.of(context).textTheme.bodySmall,
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
                            'Error loading reviews: ${snapshot.error}',
                          ),
                        );
                      }

                      final reviews = snapshot.data;

                      // 3. No Data State
                      if (reviews == null || reviews.isEmpty) {
                        return const Center(
                          child: Text('No reviews found for this place.'),
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
