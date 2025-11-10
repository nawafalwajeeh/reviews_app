import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/utils/constants/sizes.dart' show AppSizes;

import '../../../../common/widgets/appbar/appbar.dart';
import 'widgets/comment_input_field.dart';
import 'widgets/reply_section.dart';
import 'widgets/user_review_card.dart';

class CommentRepliesScreen extends StatelessWidget {
  const CommentRepliesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double keyboardOffset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,

      appBar: const CustomAppBar(showBackArrow: true, title: Text('3 Replies')),

      body: Column(
        children: [
          /// -- SCROLLABLE CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// -- Parent Comment Display
                  Text(
                    'Replying to:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSizes.xs),
                  UserReviewCard(
                    onReplyTapped: () =>
                        Get.to(() => const CommentRepliesScreen()),
                    isReply: true,
                  ),
                  const Divider(), // Separator
                  ///-- Hardcoded List of Reply Comments
                  ReplySection(isReply: true),
                  ReplySection(isReply: true),
                  ReplySection(isReply: true),
                ],
              ),
            ),
          ),

          /// -- Input Field
          BottomCommentInputField(
            isReplying: true,
            replyTarget: 'John Doe', // Static target name
            onCancelReply: () => Navigator.pop(context),
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
