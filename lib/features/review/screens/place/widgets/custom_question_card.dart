import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/localization/app_localizations.dart';

import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/place_controller.dart';

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
                      decoration: InputDecoration(
                        // labelText: 'Question',
                        labelText: AppLocalizations.of(context).question,
                        // hintText: 'Enter your question here...',
                        hintText: AppLocalizations.of(context).enterQuestion,
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
                    // tooltip: 'Remove Question',
                    tooltip: AppLocalizations.of(context).removeQuestion,
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
                          child: Text(_getQuestionTypeText(type, context)),
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
                      decoration: InputDecoration(
                        // labelText: 'Answer Type',
                        labelText: AppLocalizations.of(context).answerType,
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
                        // title: const Text('Required'),
                        title: Text(AppLocalizations.of(context).required),
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

  String _getQuestionTypeText(QuestionType type, BuildContext context) {
    switch (type) {
      case QuestionType.rating:
        // return 'Star Rating';
        return AppLocalizations.of(context).starRating;
      case QuestionType.yesOrNo:
        // return 'Yes/No';
        return AppLocalizations.of(context).yesNo;
      case QuestionType.text:
        // return 'Text Answer';
        return AppLocalizations.of(context).textAnswer;
    }
  }
}
