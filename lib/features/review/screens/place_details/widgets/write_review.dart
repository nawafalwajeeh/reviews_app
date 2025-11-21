import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:reviews_app/features/review/models/custom_questions_model.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../controllers/review_controller.dart';
import '../../../models/place_model.dart';

class WriteReviewWithQuestionsSection extends StatelessWidget {
  final String placeId;
  final PlaceModel place;

  const WriteReviewWithQuestionsSection({
    super.key,
    required this.placeId,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(ReviewController(placeId: placeId), tag: placeId);

    return GetBuilder<ReviewController>(
      tag: placeId,
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header (same as before)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Obx(
                            () => Text(
                              controller.existingReviewId.isNotEmpty &&
                                      !controller.isEditing.value
                                  ? 'Your Review (Submitted)'
                                  : controller.existingReviewId.isNotEmpty &&
                                        controller.isEditing.value
                                  ? 'Edit Your Review'
                                  : 'Write a Review',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        if (controller.existingReviewId.isNotEmpty &&
                            !controller.isEditing.value)
                          IconButton(
                            onPressed: () =>
                                _showDeleteConfirmationDialog(controller),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // MANDATORY Rating Section
                    Text(
                      'Rate your experience *',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Obx(
                        () => RatingBar.builder(
                          initialRating: controller.rating.value,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 36,
                          unratedColor: Colors.grey[300],
                          itemBuilder: (context, _) =>
                              const Icon(Icons.star, color: Color(0xFFFFCC00)),
                          onRatingUpdate: controller.setRating,
                          ignoreGestures: !controller.isRatingEnabled,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Review Text (mandatory)
                    Obx(() {
                      return TextFormField(
                        controller: controller.reviewTextController,
                        maxLines: 4,
                        enabled: controller.isTextFieldEnabled,
                        decoration: InputDecoration(
                          hintText: 'Share your experience... *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        validator: (value) {
                          if (controller.isTextFieldEnabled &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Review text is required.';
                          }
                          return null;
                        },
                      );
                    }),
                    const SizedBox(height: 16),

                    // Custom Questions Section (if place has them)
                    if (place.customQuestions != null &&
                        place.customQuestions!.isNotEmpty)
                      _buildCustomQuestionsSection(
                        context,
                        controller,
                        place.customQuestions!,
                      ),

                    // Action Buttons
                    _buildActionButtons(controller),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomQuestionsSection(
    BuildContext context,
    ReviewController controller,
    List<CustomQuestion> questions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Additional Questions',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...questions.map(
          (question) => _buildQuestionWidget(context, controller, question),
        ),
      ],
    );
  }

  Widget _buildQuestionWidget(
    BuildContext context,
    ReviewController controller,
    CustomQuestion question,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question + (question.isRequired ? ' *' : ''),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildAnswerInput(controller, question),
        ],
      ),
    );
  }

  Widget _buildAnswerInput(
    ReviewController controller,
    CustomQuestion question,
  ) {
    switch (question.type) {
      case QuestionType.rating:
        return Obx(() {
          final currentRating =
              controller.getQuestionAnswer(question.id) as double? ?? 0.0;
          return RatingBar.builder(
            initialRating: currentRating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 30,
            itemBuilder: (context, _) =>
                const Icon(Icons.star, color: Colors.amber, size: 20),
            onRatingUpdate: (rating) {
              controller.setQuestionAnswer(
                question.id,
                question.question,
                question.type,
                rating,
              );
            },
          );
        });
      case QuestionType.yesOrNo:
        return Obx(() {
          final currentAnswer =
              controller.getQuestionAnswer(question.id) as bool?;
          return Row(
            children: [
              ChoiceChip(
                label: const Text('Yes'),
                selected: currentAnswer == true,
                onSelected: (selected) {
                  controller.setQuestionAnswer(
                    question.id,
                    question.question,
                    question.type,
                    true,
                  );
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('No'),
                selected: currentAnswer == false,
                onSelected: (selected) {
                  controller.setQuestionAnswer(
                    question.id,
                    question.question,
                    question.type,
                    false,
                  );
                },
              ),
            ],
          );
        });
      case QuestionType.text:
        return TextFormField(
          maxLines: 3,
          onChanged: (value) {
            controller.setQuestionAnswer(
              question.id,
              question.question,
              question.type,
              value,
            );
          },
          decoration: const InputDecoration(
            hintText: 'Type your answer...',
            border: OutlineInputBorder(),
          ),
        );
    }
  }

  // Keep the existing _buildActionButtons, _showDeleteConfirmationDialog methods
  Widget _buildActionButtons(ReviewController controller) {
    return Obx(() {
      final isEditing = controller.isEditing.value;
      final isLoading = controller.isLoading.value;
      final hasExistingReview = controller.existingReviewId.isNotEmpty;

      return SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            if (hasExistingReview && isEditing)
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () => _showDeleteConfirmationDialog(controller),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                ),
              ),
            if (hasExistingReview && isEditing) const SizedBox(width: 12),
            Expanded(
              flex: hasExistingReview && isEditing ? 2 : 1,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : _getPrimaryButtonAction(controller),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : Text(_getPrimaryButtonText(controller)),
              ),
            ),
          ],
        ),
      );
    });
  }

  VoidCallback? _getPrimaryButtonAction(ReviewController controller) {
    if (controller.isLoading.value) return null;
    return controller.existingReviewId.isNotEmpty && !controller.isEditing.value
        ? controller.enableEditing
        : controller.submitReviewWithQuestions;
  }

  String _getPrimaryButtonText(ReviewController controller) {
    final hasExistingReview = controller.existingReviewId.isNotEmpty;
    final isEditing = controller.isEditing.value;

    if (hasExistingReview && !isEditing) return 'Edit Review';
    if (hasExistingReview && isEditing) return 'Update Review';
    return 'Submit Review';
  }

  void _showDeleteConfirmationDialog(ReviewController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Review'),
        content: const Text(
          'Are you sure you want to delete your review? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteReview();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

//---------Original code----------
// // START OF USER'S ORIGINAL DESIGN WITH LOGIC INJECTION AND GETBUILDER WRAPPER
// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:get/get.dart';
// import '../../../controllers/review_controller.dart';

// class WriteReviewSection extends StatelessWidget {
//   final String placeId;

//   const WriteReviewSection({super.key, required this.placeId});

//   @override
//   Widget build(BuildContext context) {
//     Get.put(ReviewController(placeId: placeId), tag: placeId);

//     return GetBuilder<ReviewController>(
//       tag: placeId,
//       builder: (controller) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Theme.of(
//                 context,
//               ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Form(
//                 key: controller.formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     /// Header with Delete Button
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Obx(
//                             () => Text(
//                               controller.existingReviewId.isNotEmpty &&
//                                       !controller.isEditing.value
//                                   ? 'Your Review (Submitted)'
//                                   : controller.existingReviewId.isNotEmpty &&
//                                         controller.isEditing.value
//                                   ? 'Edit Your Review'
//                                   : 'Write a Review',
//                               style: Theme.of(context).textTheme.titleLarge
//                                   ?.copyWith(fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                         ),

//                         /// DELETE BUTTON - Only show when user has a submitted review
//                         if (controller.existingReviewId.isNotEmpty &&
//                             !controller.isEditing.value)
//                           IconButton(
//                             onPressed: () =>
//                                 _showDeleteConfirmationDialog(controller),
//                             icon: const Icon(
//                               Icons.delete_outline,
//                               color: Colors.red,
//                             ),
//                             tooltip: 'Delete Review',
//                           ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),

//                     Text(
//                       'Rate your experience',
//                       style: Theme.of(
//                         context,
//                       ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
//                     ),
//                     const SizedBox(height: 8),

//                     /// Rating Stars
//                     Center(
//                       child: Obx(
//                         () => RatingBar.builder(
//                           initialRating: controller.rating.value,
//                           minRating: 1,
//                           direction: Axis.horizontal,
//                           allowHalfRating: true,
//                           itemCount: 5,
//                           itemSize: 36,
//                           unratedColor: Colors.grey[300],
//                           itemBuilder: (context, _) =>
//                               const Icon(Icons.star, color: Color(0xFFFFCC00)),
//                           onRatingUpdate: controller.setRating,
//                           ignoreGestures:
//                               !controller.isRatingEnabled, // Use helper method
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     /// Review Text Field
//                     Obx(() {
//                       return TextFormField(
//                         controller: controller.reviewTextController,
//                         maxLines: 4,
//                         enabled:
//                             controller.isTextFieldEnabled, // Use helper method
//                         decoration: InputDecoration(
//                           hintText: 'Share your experience...',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                           filled: true,
//                           fillColor: Theme.of(context).colorScheme.surface,
//                         ),
//                         validator: (value) {
//                           // Only validate when the field is enabled (editing or new review)
//                           if (controller.isTextFieldEnabled &&
//                               (value == null || value.trim().isEmpty)) {
//                             return 'Review text is required.';
//                           }
//                           return null;
//                         },
//                       );
//                     }),
//                     const SizedBox(height: 16),

//                     /// Action Buttons (Submit/Update/Edit/Delete)
//                     _buildActionButtons(controller),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   /// Build the appropriate action buttons based on state
//   Widget _buildActionButtons(ReviewController controller) {
//     return Obx(() {
//       final isEditing = controller.isEditing.value;
//       final isLoading = controller.isLoading.value;
//       final hasExistingReview = controller.existingReviewId.isNotEmpty;

//       return SizedBox(
//         width: double.infinity,
//         child: Row(
//           children: [
//             /// DELETE BUTTON - Only show when editing an existing review
//             if (hasExistingReview && isEditing)
//               Expanded(
//                 flex: 1,
//                 child: OutlinedButton(
//                   onPressed: isLoading
//                       ? null
//                       : () => _showDeleteConfirmationDialog(controller),
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     side: const BorderSide(color: Colors.red),
//                   ),
//                   child: isLoading
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : const Text(
//                           'Delete',
//                           style: TextStyle(color: Colors.red),
//                         ),
//                 ),
//               ),

//             if (hasExistingReview && isEditing) const SizedBox(width: 12),

//             /// SUBMIT/UPDATE/EDIT BUTTON
//             Expanded(
//               flex: hasExistingReview && isEditing ? 2 : 1,
//               child: ElevatedButton(
//                 onPressed: isLoading
//                     ? null
//                     : _getPrimaryButtonAction(controller),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: isLoading
//                     ? const SizedBox(
//                         width: 24,
//                         height: 24,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 3,
//                           color: Colors.white,
//                         ),
//                       )
//                     : Text(
//                         _getPrimaryButtonText(controller),
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   /// Get the primary button action based on state
//   VoidCallback? _getPrimaryButtonAction(ReviewController controller) {
//     final hasExistingReview = controller.existingReviewId.isNotEmpty;
//     final isEditing = controller.isEditing.value;

//     if (controller.isLoading.value) return null;

//     return hasExistingReview && !isEditing
//         ? controller
//               .enableEditing // Show EDIT button
//         : controller.submitReview; // Show SUBMIT/UPDATE button
//   }

//   /// Get the primary button text based on state
//   String _getPrimaryButtonText(ReviewController controller) {
//     final hasExistingReview = controller.existingReviewId.isNotEmpty;
//     final isEditing = controller.isEditing.value;

//     if (hasExistingReview && !isEditing) {
//       return 'Edit Review';
//     } else if (hasExistingReview && isEditing) {
//       return 'Update Review';
//     } else {
//       return 'Submit Review';
//     }
//   }

//   /// Show delete confirmation dialog
//   void _showDeleteConfirmationDialog(ReviewController controller) {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Delete Review'),
//         content: const Text(
//           'Are you sure you want to delete your review? This action cannot be undone.',
//         ),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               controller.deleteReview();
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }
// }
