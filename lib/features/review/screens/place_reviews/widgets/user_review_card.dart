import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:reviews_app/common/widgets/place/rating/rating_indicator.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';
import '../../../models/review_model.dart'; // Import the ReviewModel

class UserReviewCard extends StatelessWidget {
  /// We now require a ReviewModel to display actual data
  final ReviewModel review;

  const UserReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    // final dark = AppHelperFunctions.isDarkMode(context);

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
      ],
    );
  }
}
