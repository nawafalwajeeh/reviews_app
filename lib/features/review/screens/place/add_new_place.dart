import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../../../utils/constants/enums.dart';
import '../../controllers/place_controller.dart';
import 'widgets/add_photo_box.dart';
import 'widgets/place_form.dart';
import 'widgets/guid_lines_box.dart';

class AddNewPlaceScreen extends StatelessWidget {
  const AddNewPlaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = PlaceController.instance;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(
          leadingIcon: Icons.clear,
          leadingOnPressed: () => Get.back(),
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline_rounded, color: AppColors.darkGrey),
              onPressed: () {},
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.defaultSpace,
            ),
            child: Form(
              key: controller.placeFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  Text(
                    'Create New Place',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'Share your favorite spot with the community',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  AddPhotoBox(),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  PlaceForm(),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  // Custom Questions Section
                  CustomQuestionsSection(),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  CommunityGuidelinesBox(),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  /// -- Create Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller.createPlace(),
                      child: Text('Create Place'),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwSections),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
                'Custom Questions (Optional)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                onPressed: controller.addCustomQuestion,
                icon: const Icon(Icons.add),
                tooltip: 'Add Question',
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
            'No custom questions added',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.spaceBtwItems),
          Text(
            'Tap the + button to add up to 4 optional questions',
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

class CustomQuestionCard extends StatelessWidget {
  final int index;

  const CustomQuestionCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final controller = PlaceController.instance;

    // Ensure we don't go out of bounds
    if (index >= controller.customQuestions.length) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity, // Ensure full width
      margin: const EdgeInsets.only(bottom: AppSizes.spaceBtwItems),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Important: Use min size
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.questionControllers[index],
                      decoration: const InputDecoration(
                        labelText: 'Question',
                        hintText: 'Enter your question here...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      onChanged: (value) {
                        if (index < controller.customQuestions.length) {
                          controller.updateQuestion(
                            index,
                            value,
                            controller.questionTypes[index].value,
                            controller.questionRequired[index].value,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceBtwItems),
                  IconButton(
                    onPressed: () {
                      if (index < controller.customQuestions.length) {
                        controller.removeCustomQuestion(index);
                      }
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Remove Question',
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceBtwItems),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<QuestionType>(
                      initialValue: index < controller.questionTypes.length
                          ? controller.questionTypes[index].value
                          : QuestionType.yesOrNo,
                      items: QuestionType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getQuestionTypeText(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null &&
                            index < controller.customQuestions.length) {
                          controller.questionTypes[index].value = value;
                          controller.updateQuestion(
                            index,
                            controller.questionControllers[index].text,
                            value,
                            controller.questionRequired[index].value,
                          );
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Answer Type',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceBtwItems),
                  SizedBox(
                    width: 120, // Fixed width for checkbox
                    child: Obx(
                      () => CheckboxListTile(
                        title: const Text('Required'),
                        value: index < controller.questionRequired.length
                            ? controller.questionRequired[index].value
                            : false,
                        onChanged: (value) {
                          if (index < controller.customQuestions.length) {
                            controller.questionRequired[index].value =
                                value ?? false;
                            controller.updateQuestion(
                              index,
                              controller.questionControllers[index].text,
                              controller.questionTypes[index].value,
                              value ?? false,
                            );
                          }
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getQuestionTypeText(QuestionType type) {
    switch (type) {
      case QuestionType.rating:
        return 'Star Rating';
      case QuestionType.yesOrNo:
        return 'Yes/No';
      case QuestionType.text:
        return 'Text Answer';
    }
  }
}
