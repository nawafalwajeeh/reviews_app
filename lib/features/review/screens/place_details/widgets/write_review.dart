// START OF USER'S ORIGINAL DESIGN WITH LOGIC INJECTION AND GETBUILDER WRAPPER
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

import '../../../controllers/review_controller.dart';

class WriteReviewSection extends StatelessWidget {
  final String placeId;

  const WriteReviewSection({super.key, required this.placeId});

  @override
  Widget build(BuildContext context) {
    // Initialize and inject the controller with the required placeId, using a tag
    // to ensure correct instance retrieval if used multiple times.
    final controller = Get.put(
      ReviewController(placeId: placeId),
      tag: placeId,
    );

    // CRUCIAL FIX: Use GetBuilder to listen for manual controller.update() calls.
    // This ensures the entire form, including the TextFormField (which uses a standard
    // TextEditingController), refreshes instantly when fetchExistingReview() runs.
    return GetBuilder<ReviewController>(
      tag: placeId,
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha:0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: controller.formKey, // Bind the form key for validation
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   
                    Obx(
                      () => Text(
                        controller.existingReviewId.isNotEmpty &&
                                !controller.isEditing.value
                            ? 'Your Review (Submitted)'
                            : controller.existingReviewId.isNotEmpty &&
                                  controller.isEditing.value
                            ? 'Edit Your Review'
                            : 'Write a Review',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Rate your experience',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
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
                          // Bind rating update to the controller
                          onRatingUpdate: controller.setRating,
                          // CONTROL: Ignore gestures if not in editing mode
                          ignoreGestures: !controller.isEditing.value,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: controller
                          .reviewTextController, // Bind text controller
                      maxLines: 4,
                      // CONTROL: Set enabled/disabled based on editing state
                      enabled: controller.isEditing.value,
                      decoration: InputDecoration(
                        hintText: 'Share your experience...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                      // Validator only runs when editing is enabled
                      validator: (value) {
                        if (controller.isEditing.value &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Review text is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: Obx(() {
                        final isEditing = controller.isEditing.value;
                        final isLoading = controller.isLoading.value;
                        final hasExistingReview =
                            controller.existingReviewId.isNotEmpty;

                        // Determine button action and text
                        final VoidCallback? onPressedAction = isLoading
                            ? null // Disabled while loading
                            : hasExistingReview && !isEditing
                            ? controller
                                  .enableEditing // Existing review, show EDIT
                            : controller
                                  .submitReview; // New review OR editing existing, show SUBMIT/UPDATE

                        final String buttonText =
                            hasExistingReview && !isEditing
                            ? 'Edit Review'
                            : hasExistingReview && isEditing
                            ? 'Update Review'
                            : 'Submit Review';

                        return ElevatedButton(
                          onPressed: onPressedAction,
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
                              : Text(
                                  buttonText,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}



