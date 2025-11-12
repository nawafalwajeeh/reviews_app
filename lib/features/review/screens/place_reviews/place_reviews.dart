// screens/place_comments_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/common/widgets/place/rating/rating_indicator.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../controllers/comment_controller.dart';
import '../../models/place_model.dart';
import '../place_reviews/widgets/comment_input_field.dart';
import 'widgets/comment_card.dart';

import 'widgets/rating_progress_indicator.dart'; // Add this import

class PlaceReviewsScreen extends StatelessWidget {
  final PlaceModel place;

  const PlaceReviewsScreen({super.key, required this.place});

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
                  /// Title (EXACTLY like your reviews screen)
                  const Text(
                    'Ratings and reviews are verified and are from people who use the same type of device that you use.',
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  OverallPlaceRating(
                    rating: place.rating.toStringAsFixed(1),
                    totalReviews: place.reviewsCount,
                    ratingDistribution:
                        place.ratingDistribution, // PASS REAL DATA
                  ),

                  /// Rating Bar Indicator
                  AppRatingBarIndicator(rating: place.rating),
                  Text(
                    '${place.reviewsCount} reviews',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  const SizedBox(height: AppSizes.spaceBtwSections),

                  /// Comments List
                  _buildCommentsSection(commentController),
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

  Widget _buildCommentsSection(CommentController commentController) {
    return Obx(() {
      if (commentController.isLoading && commentController.comments.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (commentController.comments.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.comment, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No comments yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                'Be the first to comment!',
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
            'Comments (${commentController.comments.length})',
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

//-----------------------------
// // In your PlaceCommentsScreen
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../../common/widgets/appbar/appbar.dart';
// import '../../../../utils/constants/sizes.dart';
// import '../../controllers/comment_controller.dart';
// import '../../models/place_model.dart';
// import 'widgets/comment_card.dart';
// import 'widgets/comment_input_field.dart';
// import 'widgets/rating_progress_indicator.dart';

// class PlaceReviewsScreen extends StatelessWidget {
//   final PlaceModel place;

//   const PlaceReviewsScreen({super.key, required this.place});

//   @override
//   Widget build(BuildContext context) {
//     final CommentController commentController = Get.put(CommentController());

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: const CustomAppBar(
//         showBackArrow: true,
//         title: Text('Rating & Reviews'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(AppSizes.defaultSpace),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   /// Reviews Section Header
//                   const Text(
//                     'Ratings and reviews are verified and are from people who use the same type of device that you use.',
//                   ),
//                   const SizedBox(height: AppSizes.spaceBtwItems),

//                   /// Overall Place Rating with real data
//                   OverallPlaceRating(
//                     rating: place.rating.toStringAsFixed(1),
//                     totalReviews: place.reviewsCount,
//                   ),

//                   const SizedBox(height: AppSizes.spaceBtwSections),

//                   /// Comments Section
//                   _buildCommentsSection(commentController),
//                 ],
//               ),
//             ),
//           ),

//           /// Comment Input Field
//           Obx(() {
//             return BottomCommentInputField(
//               isReplying: false,
//               onCancelReply: () {},
//               onSend: (text) {
//                 commentController.addComment(text);
//               },
//               isLoading: commentController.isLoading,
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   Widget _buildCommentsSection(CommentController commentController) {
//     return Obx(() {
//       if (commentController.isLoading && commentController.comments.isEmpty) {
//         return const Center(child: CircularProgressIndicator());
//       }

//       if (commentController.comments.isEmpty) {
//         return const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.comment, size: 64, color: Colors.grey),
//               SizedBox(height: 16),
//               Text(
//                 'No comments yet',
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//               Text(
//                 'Be the first to comment!',
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ],
//           ),
//         );
//       }

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Comments (${commentController.comments.length})',
//             style: Theme.of(Get.context!).textTheme.headlineSmall,
//           ),
//           const SizedBox(height: AppSizes.spaceBtwItems),

//           ListView.builder(
//             itemCount: commentController.comments.length,
//             physics: const NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             itemBuilder: (context, index) {
//               final comment = commentController.comments[index];
//               return CommentCard(comment: comment);
//             },
//           ),
//         ],
//       );
//     });
//   }
// }
//-----------------------
// // screens/place_comments_screen.dart - Exact Match Version
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:reviews_app/common/widgets/appbar/appbar.dart';
// import 'package:reviews_app/common/widgets/place/rating/rating_indicator.dart';
// import 'package:reviews_app/utils/constants/sizes.dart';
// import '../../controllers/comment_controller.dart';
// import '../../models/place_model.dart';
// import '../place_reviews/widgets/rating_progress_indicator.dart';
// import 'widgets/comment_input_field.dart';
// import 'widgets/comment_card.dart';

// class PlaceReviewsScreen extends StatelessWidget {
//   final PlaceModel place;

//   const PlaceReviewsScreen({super.key, required this.place});

//   @override
//   Widget build(BuildContext context) {
//     final CommentController commentController = Get.put(CommentController());
//     final double keyboardOffset = MediaQuery.of(context).viewInsets.bottom;

//     // Initialize comments when screen loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       commentController.initializeComments(place.id);
//     });

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: const CustomAppBar(
//         showBackArrow: true,
//         title: Text('Reviews & Ratings'),
//       ),
//       body: Column(
//         children: [
//           /// -- Scrollable Content
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(AppSizes.defaultSpace),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   /// Title
//                   const Text(
//                     'Ratings and reviews are verified and are from people who use the same type of device that you use.',
//                   ),
//                   const SizedBox(height: AppSizes.spaceBtwItems),

//                   /// Overall Place Rating
//                   OverallPlaceRating(rating: place.rating.toStringAsFixed(1)),

//                   /// Rating Bar Indicator
//                   AppRatingBarIndicator(rating: place.rating),
//                   Text('12,611', style: Theme.of(context).textTheme.bodySmall),
//                   const SizedBox(height: AppSizes.spaceBtwSections),

//                   /// Comments List (Replacing the UserReviewsList from reviews screen)
//                   _buildCommentsSection(commentController),
//                 ],
//               ),
//             ),
//           ),

//           /// -- Comment Input Field
//           Obx(() {
//             return BottomCommentInputField(
//               isReplying: false,
//               onCancelReply: () {},
//               onSend: (text) {
//                 commentController.addComment(text);
//               },
//               isLoading: commentController.isLoading,
//             );
//           }),

//           // Add padding for the home indicator/system bottom bar when the keyboard is closed
//           if (keyboardOffset == 0)
//             SizedBox(height: MediaQuery.of(context).padding.bottom),
//         ],
//       ),
//     );
//   }

//   /// Build Comments Section (Replaces UserReviewsList from reviews screen)
//   Widget _buildCommentsSection(CommentController commentController) {
//     return Obx(() {
//       if (commentController.isLoading && commentController.comments.isEmpty) {
//         return const Center(child: CircularProgressIndicator());
//       }

//       if (commentController.comments.isEmpty) {
//         return const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.comment, size: 64, color: Colors.grey),
//               SizedBox(height: 16),
//               Text(
//                 'No comments yet',
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//               Text(
//                 'Be the first to comment!',
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ],
//           ),
//         );
//       }

//       return ListView.builder(
//         itemCount: commentController.comments.length,
//         physics: const NeverScrollableScrollPhysics(),
//         shrinkWrap: true,
//         itemBuilder: (context, index) {
//           final comment = commentController.comments[index];
//           return CommentCard(
//             comment: comment,
//             // Optional: Add rating if you want stars for comments
//             // rating: 4.0,
//           );
//         },
//       );
//     });
//   }
// }
