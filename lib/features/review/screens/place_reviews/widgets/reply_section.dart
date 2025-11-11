import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/features/review/screens/place_reviews/reply_screen.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'user_review_card.dart';

class ReplySection extends StatelessWidget {
  const ReplySection({
    super.key,
    // required this.review,
    this.isReply = false,
  });

  // final ReviewModel review;
  final bool isReply;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: isReply ? AppSizes.defaultSpace : 0),
      child: UserReviewCard(
        onReplyTapped: () => Get.to(() => CommentRepliesScreen()),
        isReply: isReply,
      ),
    );
  }
}
