import 'package:flutter/material.dart';
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

    return Column(
      children: [
        LabeledTextField(
          label: 'Place Name',
          hint: 'Enter the name of this place',
          controller: controller.descriptionController,
        ),
        const SizedBox(height: AppSizes.spaceBtwInputFields),
        LabeledDropdown(
          label: 'Category',
          items: const [
            'Restaurant',
            'Cafe',
            'Park',
            'Museum',
            'Shopping',
            'Entertainment',
          ],
          onChanged: (value) =>
              controller.selectedCategoryId.value = value ?? '',
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
