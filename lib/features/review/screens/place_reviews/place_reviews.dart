import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/common/widgets/place/rating/rating_indicator.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'reply_screen.dart';
import 'widgets/comment_input_field.dart';
import 'widgets/rating_progress_indicator.dart';
import 'widgets/user_review_card.dart';

class PlaceReviewsScreen extends StatelessWidget {
  const PlaceReviewsScreen({super.key});

  // final PlaceModel place;

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
                  const OverallPlaceRating(),

                  const AppRatingBarIndicator(rating: 3.5),
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

//------First-version--------------
// import 'package:flutter/material.dart';
// import 'package:reviews_app/common/widgets/appbar/appbar.dart';
// import 'package:reviews_app/common/widgets/place/rating/rating_indicator.dart';
// import 'package:reviews_app/utils/constants/sizes.dart';
// import 'replay_screen.dart';
// import 'widgets/comment_input_field.dart';
// import 'widgets/rating_progress_indicator.dart';
// import 'widgets/user_review_card.dart';

// class PlaceReviewsScreen extends StatelessWidget {
//   const PlaceReviewsScreen({super.key});

//   // Temporary
//   // Dummy function to open the replies screen
//   void _openRepliesScreen(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const CommentRepliesScreen()),
//     );
//   }

//   // Dummy function for the main screen's bottom input field
//   void _onSendNewComment() {
//     print("New top-level comment sent.");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,

//       /// AppBar
//       appBar: CustomAppBar(
//         showBackArrow: true,
//         title: Text('Reviews & Ratings'),
//       ),

//       /// Body
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(AppSizes.defaultSpace),

//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// Title
//             const Text(
//               'Ratings and reviews are verified and are from people who use the same type of device that you use.',
//             ),
//             const SizedBox(height: AppSizes.spaceBtwItems),

//             /// Overall Product Rating
//             const OverallPlaceRating(),

//             const AppRatingBarIndicator(rating: 3.5),
//             Text('12,611', style: Theme.of(context).textTheme.bodySmall),
//             const SizedBox(height: AppSizes.spaceBtwSections),

//             /// User Reviews List
//             // const UserReviewCard(),
//             // const UserReviewCard(),
//             UserReviewCard(onReplyTapped: () => _openRepliesScreen(context)),
//             UserReviewCard(onReplyTapped: () => _openRepliesScreen(context)),
//           ],
//         ),
//       ),
//       /// Bottom Navigation Bar for new comments
//       bottomNavigationBar: BottomCommentInputField(
//         isReplying: false, // Indicates this is for a new comment, not a reply
//         onCancelReply: () {}, // Not used for new comments
//         onSend: _onSendNewComment,
//       ),
//     );
//   }
// }
