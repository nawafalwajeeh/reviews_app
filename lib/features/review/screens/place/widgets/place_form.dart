import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/features/review/controllers/category_controller.dart';
import 'package:reviews_app/features/review/controllers/place_controller.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'label_chip.dart';
import 'label_drop_down.dart';
import 'label_location_picker.dart';
import 'label_text_field.dart';

class PlaceForm extends StatelessWidget {
  const PlaceForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = PlaceController.instance;
    final categoryController = CategoryController.instance;

    return Column(
      children: [
        LabeledTextField(
          label: 'Place Name',
          hint: 'Enter the name of this place',
          controller: controller.titleController,
        ),
        const SizedBox(height: AppSizes.spaceBtwInputFields),
        LabeledDropdown(
          label: 'Category',
          items: categoryController.categoryNames,
          // items: const [
          //   'Restaurant',
          //   'Cafe',
          //   'Park',
          //   'Museum',
          //   'Shopping',
          //   'Entertainment',
          // ],
          // onChanged: (value) =>
          //     controller.selectedCategoryId.value = value ?? '',
          // When a name is selected (value), we must find the corresponding ID
          onChanged: (String? selectedName) {
            if (selectedName != null) {
              // 1. Find the CategoryModel in the list that matches the selected name.
              final matchingCategory = categoryController.categoryModels
                  .firstWhereOrNull(
                    (category) => category.name == selectedName,
                  );

              // 2. If a match is found, update the controller's ID variable.
              if (matchingCategory != null) {
                controller.selectedCategoryId.value = matchingCategory.id;
              } else {
                // Handle case where category isn't found (shouldn't happen if lists match)
                controller.selectedCategoryId.value = '';
              }
            } else {
              controller.selectedCategoryId.value = '';
            }
          },
        ),
        const SizedBox(height: AppSizes.spaceBtwInputFields),
        LabeledLocationPicker(label: 'Location'),
        const SizedBox(height: AppSizes.spaceBtwInputFields),
        LabeledTextField(
          label: 'Description',
          hint: 'Tell us what makes this place special...',
          maxLines: 4,
          controller: controller.descriptionController,
        ),
        const SizedBox(height: AppSizes.spaceBtwInputFields),
        LabeledChips(
          label: 'Tags',
          tags: const [
            'Family Friendly',
            'Pet Friendly',
            'Outdoor',
            'Indoor',
            'Romantic',
            'Budget Friendly',
            'Luxury',
          ],
          selectedTags: controller.selectedTags,
          onSelected: controller.toggleTag,
        ),
      ],
    );
  }
}
