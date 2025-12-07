// screens/place_comments_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/common/widgets/place/rating/rating_indicator.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../controllers/comment_controller.dart';
import '../../models/place_model.dart';
import '../place_reviews/widgets/comment_input_field.dart';
import 'widgets/comment_card.dart';

import 'widgets/rating_progress_indicator.dart'; // Add this import

class PlaceCommentsScreen extends StatelessWidget {
  final PlaceModel place;

  const PlaceCommentsScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final CommentController commentController = Get.put(CommentController());
    final double keyboardOffset = MediaQuery.of(context).viewInsets.bottom;

    // Initialize comments when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      commentController.initializeComments(place.id);
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      // appBar: const CustomAppBar(showBackArrow: true, title: Text('Comments')),
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(AppLocalizations.of(context).comments),
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
                  /// Title (EXACTLY like your reviews screen)
                  // const Text(
                  //   'Ratings and reviews are verified and are from people who use the same type of device that you use.',
                  // ),
                  Text(AppLocalizations.of(context).ratingsVerified),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  OverallPlaceRating(
                    rating: place.averageRating.toStringAsFixed(1),
                    totalReviews: place.reviewsCount,
                    ratingDistribution:
                        place.ratingDistribution, // PASS REAL DATA
                  ),

                  /// Rating Bar Indicator
                  AppRatingBarIndicator(rating: place.averageRating),
                  Text(
                    // '${place.reviewsCount} reviews',
                    '${place.reviewsCount} ${AppLocalizations.of(context).reviews}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  const SizedBox(height: AppSizes.spaceBtwSections),

                  /// Comments List
                  _buildCommentsSection(commentController, context),
                ],
              ),
            ),
          ),

          /// -- Comment Input Field
          Obx(() {
            return BottomCommentInputField(
              isReplying: false,
              onCancelReply: () {},
              onSend: (text) {
                commentController.addComment(text);
              },
              isLoading: commentController.isLoading,
            );
          }),

          if (keyboardOffset == 0)
            SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(
    CommentController commentController,
    BuildContext context,
  ) {
    final locale = AppLocalizations.of(context);
    return Obx(() {
      if (commentController.isLoading && commentController.comments.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (commentController.comments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.comment, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                // 'No comments yet',
                locale.noCommentsYet,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                // 'Be the first to comment!',
                locale.beFirstToComment,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // 'Comments (${commentController.comments.length})',
            '${locale.comments} (${commentController.comments.length})',

            style: Theme.of(Get.context!).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSizes.spaceBtwItems),

          ListView.builder(
            itemCount: commentController.comments.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final comment = commentController.comments[index];
              return CommentCard(comment: comment);
            },
          ),
        ],
      );
    });
  }
}
