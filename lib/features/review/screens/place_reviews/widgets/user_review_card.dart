import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:reviews_app/common/widgets/place/rating/rating_indicator.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/enums.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';
import '../../../../../localization/app_localizations.dart';
import '../../../models/question_answer_model.dart';
import '../../../models/review_model.dart'; // Import the ReviewModel

class UserReviewCard extends StatelessWidget {
  /// We now require a ReviewModel to display actual data
  final ReviewModel review;

  const UserReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);

    // Assuming AppHelperFunctions has a method to format DateTime
    final formattedDate = AppHelperFunctions.getFormattedDate(review.timestamp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Display user avatar (using the userAvatar URL from the model)
                CircleAvatar(
                  backgroundImage: NetworkImage(review.userAvatar),
                  onBackgroundImageError: (exception, stackTrace) =>
                      const Icon(Icons.person), // Fallback icon
                ),
                const SizedBox(width: AppSizes.spaceBtwItems),
                // Display user name
                Text(
                  review.userName,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  maxLines: 2,
                  // style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
          ],
        ),
        const SizedBox(height: AppSizes.spaceBtwItems),

        /// Review Details
        Row(
          children: [
            // Display rating
            AppRatingBarIndicator(rating: review.rating),
            const SizedBox(width: AppSizes.spaceBtwItems),
            // Display date
            Text(formattedDate, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: AppSizes.spaceBtwItems),

        // Display review text
        ReadMoreText(
          review.reviewText,
          trimLines: 2,
          // trimExpandedText: ' show less',
          // trimCollapsedText: ' show more',
          trimExpandedText: txt.showLess,
          trimCollapsedText: txt.showMore,
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

        /// Custom Question Answers Section (NEW)
        if (review.questionAnswers.isNotEmpty)
          _buildQuestionAnswersSection(context, dark),
      ],
    );
  }

  /// Build Question Answers Section
  Widget _buildQuestionAnswersSection(BuildContext context, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Section Title
        Text(
          // 'Additional Answers:',
          txt.additionalAnswers,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: dark ? AppColors.light : AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: AppSizes.sm),

        /// Question Answers List
        ...review.questionAnswers.map(
          (qa) => Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Question
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        qa.question,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                /// Answer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
                  decoration: BoxDecoration(
                    color: dark ? AppColors.darkerGrey : AppColors.grey,
                    borderRadius: BorderRadius.circular(AppSizes.sm),
                    border: Border.all(
                      color: dark ? AppColors.darkGrey : AppColors.lightGrey,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _formatAnswer(qa),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: dark ? AppColors.light : AppColors.dark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Format Answer Based on Question Type
  String _formatAnswer(QuestionAnswer qa) {
    // if (qa.answer == null) return 'Not answered';
    if (qa.answer == null) return txt.notAnswered;

    switch (qa.type) {
      case QuestionType.rating:
        final rating = qa.answer is double ? qa.answer as double : 0.0;
        // return '${rating.toStringAsFixed(1)} ${rating == 1 ? 'star' : 'stars'}';
        return '${rating.toStringAsFixed(1)} ${rating == 1 ? txt.star : txt.stars}';
      case QuestionType.yesOrNo:
        final answer = qa.answer is bool ? qa.answer as bool : false;
        // return answer ? 'Yes' : 'No';
        return answer ? txt.yes : txt.no;
      case QuestionType.text:
        final textAnswer = qa.answer?.toString() ?? '';
        // return textAnswer.isEmpty ? 'Not answered' : textAnswer;
        return textAnswer.isEmpty ? txt.notAnswered : textAnswer;
    }
  }
}
