// widgets/comment_widget.dart - Updated for nested replies
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:reviews_app/common/widgets/place/rating/rating_indicator.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../../controllers/comment_controller.dart';
import '../../../models/comment_model.dart';

class CommentCard extends StatelessWidget {
  final CommentModel comment;
  final bool isReply;
  final double? rating;
  final int nestLevel;

  const CommentCard({
    super.key,
    required this.comment,
    this.isReply = false,
    this.rating,
    this.nestLevel = 0,
  });

  @override
  Widget build(BuildContext context) {
    final CommentController commentController = Get.find<CommentController>();
    final String currentUserId = commentController.authRepo.getUserID;
    final bool isOwner = comment.userId == currentUserId;

    // NEW: Calculate left margin based on nest level (max 3 levels deep)
    final double leftMargin = (nestLevel * 16.0).clamp(0.0, 48.0);

    return Container(
      margin: EdgeInsets.only(left: leftMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// User Profile, Name, and Options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(comment.userAvatar),
                  ),
                  const SizedBox(width: AppSizes.spaceBtwItems),
                  Text(
                    comment.userName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              if (isOwner)
                _buildOwnerMenu(
                  commentController,
                  comment.id,
                  comment.commentText,
                )
              else
                IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
            ],
          ),
          const SizedBox(height: AppSizes.spaceBtwItems),

          /// Rating and Date (Hidden for nested replies)
          if (!isReply && rating != null)
            Row(
              children: [
                AppRatingBarIndicator(rating: rating!),
                const SizedBox(width: AppSizes.spaceBtwItems),
                Text(
                  _formatTime(comment.timestamp),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          if (!isReply && rating != null)
            const SizedBox(height: AppSizes.spaceBtwItems),

          /// Comment Text
          ReadMoreText(
            comment.commentText,
            trimLines: 2,
            // trimExpandedText: ' show less',
            trimExpandedText: AppLocalizations.of(context).showLess,
            // trimCollapsedText: ' show more',
            trimCollapsedText: AppLocalizations.of(context).showMore,
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
            child: Obx(() {
              final userReaction = commentController.getCommentReaction(
                comment.id,
              );

              return Row(
                children: [
                  /// Like Button
                  TextButton.icon(
                    onPressed: () =>
                        commentController.likeComment(comment.id, true),
                    icon: Icon(
                      Icons.thumb_up_alt_outlined,
                      size: 18,
                      color: userReaction['liked'] == true
                          ? AppColors.primaryColor
                          : AppColors.grey,
                    ),
                    label: Text(
                      comment.likes.length.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceBtwItems),

                  /// Dislike Button
                  TextButton.icon(
                    onPressed: () =>
                        commentController.likeComment(comment.id, false),
                    icon: Icon(
                      Icons.thumb_down_alt_outlined,
                      size: 18,
                      color: userReaction['disliked'] == true
                          ? AppColors.primaryColor
                          : AppColors.grey,
                    ),
                    label: Text(
                      comment.dislikes.length.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceBtwItems),

                  /// Reply Button - Show for all comments (including replies to replies)
                  TextButton.icon(
                    onPressed: () =>
                        _showReplyDialog(commentController, comment),
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      size: 18,
                      color: AppColors.darkGrey,
                    ),
                    label: Obx(() {
                      // NEW: Use total reply count including nested replies
                      final totalReplies = commentController.getTotalReplyCount(
                        comment.id,
                      );
                      return Text(
                        totalReplies.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      );
                    }),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  ),
                ],
              );
            }),
          ),

          /// Show Replies Section - Show for any comment that has replies
          Obx(() {
            final hasReplies = commentController.hasReplies(comment.id);
            final showReplies =
                commentController.showRepliesMap[comment.id] ?? false;
            final nestedReplies = commentController.getNestedReplies(
              comment.id,
            );

            if (hasReplies) {
              return Column(
                children: [
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  /// Show/Hide Replies Button
                  GestureDetector(
                    onTap: () =>
                        commentController.toggleShowReplies(comment.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            showReplies ? Icons.expand_less : Icons.expand_more,
                            size: 16,
                            color: AppColors.darkGrey,
                          ),
                          const SizedBox(width: 4),
                          Obx(() {
                            final totalReplies = commentController
                                .getTotalReplyCount(comment.id);
                            return Text(
                              '${showReplies ? 'Hide' : 'Show'} $totalReplies ${totalReplies == 1 ? 'reply' : 'replies'}',
                              // '${showReplies ? '${AppLocalizations.of(context).hide}' :  '${AppLocalizations.of(context).show}'} $totalReplies ${totalReplies == 1 ? '${AppLocalizations.of(context).reply}' : '${AppLocalizations.of(context).replies}'}',
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(
                                    color: AppColors.darkGrey,
                                    fontWeight: FontWeight.w500,
                                  ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  /// Nested Replies List
                  if (showReplies && nestedReplies.isNotEmpty)
                    Column(
                      children: [
                        const SizedBox(height: AppSizes.spaceBtwItems),
                        Column(
                          children: nestedReplies
                              .map(
                                (reply) => CommentCard(
                                  comment: reply,
                                  isReply: true,
                                  nestLevel: nestLevel + 1,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          }),

          const SizedBox(height: AppSizes.spaceBtwSections),
        ],
      ),
    );
  }

  // // ... keep the existing dialog methods unchanged ...
  // Widget _buildOwnerMenu(
  //   CommentController controller,
  //   String commentId,
  //   String currentText,
  // ) {
  //   return PopupMenuButton<String>(
  //     onSelected: (value) {
  //       switch (value) {
  //         case 'edit':
  //           _showEditDialog(controller, commentId, currentText);
  //           break;
  //         case 'delete':
  //           _showDeleteDialog(controller, commentId);
  //           break;
  //       }
  //     },
  //     itemBuilder: (context) => [
  //       const PopupMenuItem(value: 'edit', child: Text('Edit')),
  //       const PopupMenuItem(value: 'delete', child: Text('Delete')),
  //       //  PopupMenuItem(value: 'edit', child: Text(AppLocalizations.of(context).edit)),
  //       //  PopupMenuItem(value: 'delete', child: Text(AppLocalizations.of(context).delete)),
  //     ],
  //   );
  // }

  // void _showEditDialog(
  //   CommentController controller,
  //   String commentId,
  //   String currentText,
  // ) {
  //   final TextEditingController editController = TextEditingController();
  //   editController.text = currentText;

  //   showDialog(
  //     context: Get.context!,
  //     barrierDismissible: true,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Edit Comment'),
  //         content: TextField(
  //           controller: editController,
  //           maxLines: 3,
  //           decoration: const InputDecoration(
  //             hintText: 'Edit your comment...',
  //             border: OutlineInputBorder(),
  //           ),
  //           autofocus: true,
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('Cancel'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               final newText = editController.text.trim();
  //               if (newText.isNotEmpty) {
  //                 Navigator.of(context).pop();
  //                 controller.updateComment(commentId, newText);
  //               }
  //             },
  //             child: const Text('Save'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void _showDeleteDialog(CommentController controller, String commentId) {
  //   showDialog(
  //     context: Get.context!,
  //     barrierDismissible: true,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Delete Comment'),
  //         content: const Text('Are you sure you want to delete this comment?'),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('Cancel'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               controller.deleteComment(commentId);
  //             },
  //             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  //             child: const Text('Delete'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _buildOwnerMenu(
    CommentController controller,
    String commentId,
    String currentText,
  ) {
    final appLocalizations = AppLocalizations.of(Get.context!);

    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            _showEditDialog(controller, commentId, currentText);
            break;
          case 'delete':
            _showDeleteDialog(controller, commentId);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'edit', child: Text(appLocalizations.edit)),
        PopupMenuItem(value: 'delete', child: Text(appLocalizations.delete)),
      ],
    );
  }

  // In _showEditDialog method
  void _showEditDialog(
    CommentController controller,
    String commentId,
    String currentText,
  ) {
    final appLocalizations = AppLocalizations.of(Get.context!);
    final TextEditingController editController = TextEditingController();
    editController.text = currentText;

    showDialog(
      context: Get.context!,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appLocalizations.editComment),
          content: TextField(
            controller: editController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: appLocalizations.editYourComment,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(appLocalizations.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final newText = editController.text.trim();
                if (newText.isNotEmpty) {
                  Navigator.of(context).pop();
                  controller.updateComment(commentId, newText);
                }
              },
              child: Text(appLocalizations.save),
            ),
          ],
        );
      },
    );
  }

  // In _showDeleteDialog method
  void _showDeleteDialog(CommentController controller, String commentId) {
    final appLocalizations = AppLocalizations.of(Get.context!);

    showDialog(
      context: Get.context!,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appLocalizations.deleteComment),
          content: Text(appLocalizations.deleteCommentConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(appLocalizations.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.deleteComment(commentId);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(appLocalizations.delete),
            ),
          ],
        );
      },
    );
  }

  void _showReplyDialog(CommentController controller, CommentModel comment) {
    final TextEditingController replyController = TextEditingController();
    final appLocalizations = AppLocalizations.of(Get.context!);

    showDialog(
      context: Get.context!,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: const Text('Reply to comment'),
          title: Text(appLocalizations.replyToComment),
          content: TextField(
            controller: replyController,
            maxLines: 3,
            decoration: InputDecoration(
              // hintText: 'Write your reply...',
              hintText: appLocalizations.writeYourReply,
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              // child: const Text('Cancel'),
              child: Text(appLocalizations.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final replyText = replyController.text.trim();
                if (replyText.isNotEmpty) {
                  Navigator.of(context).pop();
                  controller.addComment(replyText, parentCommentId: comment.id);
                }
              },
              // child: const Text('Reply'),
              child: Text(appLocalizations.reply),
            ),
          ],
        );
      },
    );
  }

  // String _formatTime(DateTime dateTime) {
  //   final now = DateTime.now();
  //   final difference = now.difference(dateTime);

  //   if (difference.inMinutes < 1) return 'Just now';
  //   if (difference.inHours < 1) return '${difference.inMinutes}m ago';
  //   if (difference.inDays < 1) return '${difference.inHours}h ago';
  //   if (difference.inDays < 30) return '${difference.inDays}d ago';

  //   return '${difference.inDays ~/ 30}mo ago';
  // }
  String _formatTime(DateTime dateTime) {
    final appLocalizations = AppLocalizations.of(Get.context!);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return appLocalizations.justNow;
    if (difference.inHours < 1) return appLocalizations.minutesAgo;
    if (difference.inDays < 1) return appLocalizations.hoursAgo;
    if (difference.inDays < 30) return appLocalizations.daysAgo;

    return appLocalizations.monthsAgo;
  }
}
