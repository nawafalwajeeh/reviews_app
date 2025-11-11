import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/common/widgets/place/rating/rating_indicator.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../models/place_model.dart';
import 'reply_screen.dart';
import 'widgets/comment_input_field.dart';
import 'widgets/rating_progress_indicator.dart';
import 'widgets/user_review_card.dart';

class PlaceReviewsScreen extends StatelessWidget {
  const PlaceReviewsScreen({super.key, required this.place});

  final PlaceModel place;

  @override
  Widget build(BuildContext context) {
    final double keyboardOffset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: true,

      appBar: const CustomAppBar(
        showBackArrow: true,
        title: Text('Reviews & Ratings'),
      ),
      body: Column(
        children: [
          /// -- Scrollable Content (Takes up remaining vertical space)
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

                  /// Overall Place Rating
                  OverallPlaceRating(rating: place.rating.toStringAsFixed(1)),

                  // const AppRatingBarIndicator(rating: 3.5),
                  AppRatingBarIndicator(rating: place.rating),
                  Text('12,611', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: AppSizes.spaceBtwSections),

                  /// User Reviews List
                  ListView.builder(
                    itemCount: 4,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (_, index) {
                      return UserReviewCard(
                        onReplyTapped: () =>
                            Get.to(() => const CommentRepliesScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          /// -- Input Field
          BottomCommentInputField(
            isReplying: false,
            onCancelReply: () {},
            onSend: () {},
          ),

          // Add padding for the home indicator/system bottom bar when the keyboard is closed
          if (keyboardOffset == 0)
            SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
