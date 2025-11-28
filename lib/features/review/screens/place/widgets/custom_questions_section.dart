import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../../../../localization/app_localizations.dart';
import '../../../controllers/place_controller.dart';
import 'custom_question_card.dart';

class CustomQuestionsSection extends StatelessWidget {
  const CustomQuestionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = PlaceController.instance;

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSizes.spaceBtwSections),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                // 'Custom Questions (Optional)',
                AppLocalizations.of(context).customQuestionsOptional,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                onPressed: controller.addCustomQuestion,
                icon: const Icon(Icons.add),
                // tooltip: 'Add Question',
                tooltip: AppLocalizations.of(context).addQuestion,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceBtwItems),

          if (controller.customQuestions.isEmpty)
            _buildEmptyState(context)
          else
            ...List.generate(controller.customQuestions.length, (index) {
              return CustomQuestionCard(index: index);
            }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity, // Ensure full width
      padding: const EdgeInsets.all(AppSizes.defaultSpace),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSizes.spaceBtwItems),
          Text(
            // 'No custom questions added',
            AppLocalizations.of(context).noCustomQuestions,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.spaceBtwItems),
          Text(
            // 'Tap the + button to add up to 4 optional questions',
              AppLocalizations.of(context).additionalQuestions,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
