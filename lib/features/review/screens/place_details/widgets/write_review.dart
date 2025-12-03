import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:reviews_app/features/review/models/custom_questions_model.dart';
import 'package:reviews_app/localization/app_localizations.dart';
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
                                  // ? 'Your Review (Submitted)'
                                  ? AppLocalizations.of(
                                      context,
                                    ).yourReviewSubmitted
                                  : controller.existingReviewId.isNotEmpty &&
                                        controller.isEditing.value
                                  // ? 'Edit Your Review'
                                  // : 'Write a Review',
                                  ? AppLocalizations.of(context).editReview
                                  : AppLocalizations.of(context).writeReview,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        if (controller.existingReviewId.isNotEmpty &&
                            !controller.isEditing.value)
                          IconButton(
                            onPressed: () => _showDeleteConfirmationDialog(
                              controller,
                              context,
                            ),
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
                      // 'Rate your experience *',
                      AppLocalizations.of(context).rateExperience,
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
                          // hintText: 'Share your experience... *',
                          hintText: AppLocalizations.of(
                            context,
                          ).shareExperience,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        // validator: (value) {
                        //   if (controller.isTextFieldEnabled &&
                        //       (value == null || value.trim().isEmpty)) {
                        //     // return 'Review text is required.';
                        //     return AppLocalizations.of(
                        //       context,
                        //     ).validationReviewTextRequired;
                        //   }
                        //   return null;
                        // },
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
                    _buildActionButtons(controller, context),
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
          // 'Additional Questions',
          AppLocalizations.of(context).additionalQuestions,
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
          _buildAnswerInput(controller, question, context),
        ],
      ),
    );
  }

  Widget _buildAnswerInput(
    ReviewController controller,
    CustomQuestion question,
    BuildContext context,
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
                // label: const Text('Yes'),
                label: Text(AppLocalizations.of(context).yes),
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
                // label: const Text('No'),
                label: Text(AppLocalizations.of(context).no),
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
          decoration: InputDecoration(
            // hintText: 'Type your answer...',
            hintText: AppLocalizations.of(context).typeYourAnswer,
            border: OutlineInputBorder(),
          ),
        );
    }
  }

  // Keep the existing _buildActionButtons, _showDeleteConfirmationDialog methods
  Widget _buildActionButtons(
    ReviewController controller,
    BuildContext context,
  ) {
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
                      : () =>
                            _showDeleteConfirmationDialog(controller, context),
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
                      : Text(
                          // 'Delete',
                          AppLocalizations.of(context).deleteReview,
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
                    : Text(_getPrimaryButtonText(controller, context)),
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

  String _getPrimaryButtonText(
    ReviewController controller,
    BuildContext context,
  ) {
    final hasExistingReview = controller.existingReviewId.isNotEmpty;
    final isEditing = controller.isEditing.value;

    // if (hasExistingReview && !isEditing) return 'Edit Review';
    // if (hasExistingReview && isEditing) return 'Update Review';
    // return 'Submit Review';

    if (hasExistingReview && !isEditing) {
      return AppLocalizations.of(context).editReview;
    }
    if (hasExistingReview && isEditing) {
      return AppLocalizations.of(context).updateReview;
    }
    return AppLocalizations.of(context).submitReview;
  }

  void _showDeleteConfirmationDialog(
    ReviewController controller,
    BuildContext context,
  ) {
    Get.dialog(
      AlertDialog(
        // title: const Text('Delete Review'),
        title: Text(AppLocalizations.of(context).deleteReview),
        // content: const Text(
        //   'Are you sure you want to delete your review? This action cannot be undone.',
        // ),
        content: Text(AppLocalizations.of(context).deleteReviewConfirmation),
        actions: [
          // TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteReview();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            // child: const Text('Delete'),
            child: Text(AppLocalizations.of(context).deleteReview),
          ),
        ],
      ),
    );
  }
}
