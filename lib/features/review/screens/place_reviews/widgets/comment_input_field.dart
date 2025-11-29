import 'package:flutter/material.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/image_strings.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';

class BottomCommentInputField extends StatelessWidget {
  final String currentUserAvatar = AppImages.user;
  final VoidCallback onCancelReply;
  final Function(String)
  onSend; // Changed from VoidCallback to Function(String)
  final bool isReplying;
  final String? replyTarget;
  final bool isLoading; // Added isLoading parameter

  const BottomCommentInputField({
    super.key,
    required this.onCancelReply,
    required this.onSend,
    this.isReplying = false,
    this.replyTarget,
    this.isLoading = false, // Added with default value
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    final TextEditingController controller = TextEditingController();
    final appLocalizations = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: dark ? AppColors.dark : AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.grey.withValues(
              alpha: 0.5,
            ), // Fixed: changed withValues to withOpacity
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.only(
        top: AppSizes.sm,
        bottom: AppSizes.sm,
        left: AppSizes.defaultSpace,
        right: AppSizes.defaultSpace,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Reply Target Notification
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

          /// Input Field Row
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
                          // ? 'Type your reply...'
                          // : 'Add a new comment...',
                          ? appLocalizations.typeYourReply
                          : appLocalizations.addNewComment,
                      suffixIcon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: const Icon(
                                Icons.send,
                                size: 20,
                                color: AppColors.primaryColor,
                              ),
                              onPressed: () {
                                if (controller.text.isNotEmpty && !isLoading) {
                                  onSend(
                                    controller.text.trim(),
                                  ); // Pass the text
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
