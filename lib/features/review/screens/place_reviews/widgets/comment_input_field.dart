// --- widgets/bottom_comment_input_field.dart ---
import 'package:flutter/material.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/image_strings.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';

class BottomCommentInputField extends StatelessWidget {
  final String currentUserAvatar = AppImages.user;
  final VoidCallback onCancelReply;
  final VoidCallback onSend;
  final bool isReplying;
  final String? replyTarget;

  const BottomCommentInputField({
    super.key,
    required this.onCancelReply,
    required this.onSend,
    this.isReplying = false,
    this.replyTarget,
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    final TextEditingController controller = TextEditingController();

    return Container(
      decoration: BoxDecoration(
        color: dark ? AppColors.dark : AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.grey.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.only(
        top: AppSizes.sm,
        bottom: AppSizes
            .sm, // Removed MediaQuery.of(context).padding.bottom calculation
        left: AppSizes.defaultSpace,
        right: AppSizes.defaultSpace,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Reply Target Notification (omitted for brevity, assume content remains the same)
          if (isReplying && replyTarget != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: Row(
                children: [
                  Text(
                    'Replying to $replyTarget',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onCancelReply,
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),

          /// Input Field Row (omitted for brevity, assume content remains the same)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// -- Current User Avatar
              CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage(currentUserAvatar),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Form(
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: isReplying
                          ? 'Type your reply...'
                          : 'Add a new comment...',
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.send,
                          size: 20,
                          color: AppColors.primaryColor,
                        ),
                        onPressed: () {
                          if (controller.text.isNotEmpty) {
                            onSend();
                            controller.clear();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
