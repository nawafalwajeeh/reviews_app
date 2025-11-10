import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:reviews_app/common/widgets/place/rating/rating_indicator.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/image_strings.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

class UserReviewCard extends StatelessWidget {
  // Hardcoded values for the review content
  final String userName = 'John Doe';
  final String userAvatar = AppImages.userProfileImage1;
  final double rating = 4.0;
  final String reviewText =
      'The user interface of the app is quite intuitive. I was able to navigate and make purchases seamlessly. Great job! This is a longer review to test the ReadMoreText widget.';
  final String date = '01 Nov, 2025';
  final int likesCount = 12;
  final int repliesCount = 3;

  // REQUIRED: Callback function to trigger navigation
  final VoidCallback onReplyTapped;

  // Optional flag to control styling if this card is used inside CommentRepliesScreen
  final bool isReply;

  const UserReviewCard({
    super.key,
    required this.onReplyTapped,
    this.isReply = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// User Profile, Name, and Options
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(userAvatar), // Static avatar
                ),
                const SizedBox(width: AppSizes.spaceBtwItems),
                Text(
                  userName,
                  style: Theme.of(context).textTheme.titleLarge,
                ), // Static name
              ],
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
          ],
        ),
        const SizedBox(height: AppSizes.spaceBtwItems),

        /// Rating and Date (Hidden for nested replies)
        if (!isReply)
          Row(
            children: [
              const AppRatingBarIndicator(rating: 4), // Static rating
              const SizedBox(width: AppSizes.spaceBtwItems),
              Text(
                date,
                style: Theme.of(context).textTheme.bodyMedium,
              ), // Static date
            ],
          ),
        if (!isReply) const SizedBox(height: AppSizes.spaceBtwItems),

        /// Review Text
        ReadMoreText(
          reviewText, // Static text
          trimLines: 2,
          trimExpandedText: ' show less',
          trimCollapsedText: ' show more',
          trimMode: TrimMode.Line,
          moreStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
          lessStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: AppSizes.spaceBtwItems),

        /// Actions: Like, Dislike, and Reply
        Padding(
          padding: const EdgeInsets.only(left: AppSizes.sm),
          child: Row(
            children: [
              /// Like Button (Static count)
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.thumb_up_alt_outlined,
                  size: 18,
                  color: AppColors.grey,
                ),
                label: Text(
                  likesCount.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: AppSizes.spaceBtwItems),

              /// Dislike Button (Static count)
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.thumb_down_alt_outlined,
                  size: 18,
                  color: AppColors.grey,
                ),
                label: Text('0', style: Theme.of(context).textTheme.bodyMedium),
              ),
              const SizedBox(width: AppSizes.spaceBtwItems),

              /// Reply Button (Triggers navigation)
              // if (!isReply) // Only show the count/icon on top-level comments
              TextButton.icon(
                onPressed:
                    onReplyTapped, // This single button opens the replies screen
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  size: 18,
                  color: AppColors.darkGrey,
                ),
                label: Text(
                  repliesCount
                      .toString(), // Show the hardcoded count beside the icon
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.spaceBtwSections),
      ],
    );
  }
}
