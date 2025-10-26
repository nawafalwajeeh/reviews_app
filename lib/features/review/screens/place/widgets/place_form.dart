import 'package:flutter/material.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'label_chip.dart';
import 'label_drop_down.dart';
import 'label_location_picker.dart';
import 'label_text_field.dart';

class PlaceForm extends StatelessWidget {
  const PlaceForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          LabeledTextField(
            label: 'Place Name',
            hint: 'Enter the name of this place',
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
          ),
          const SizedBox(height: AppSizes.spaceBtwInputFields),
          LabeledLocationPicker(label: 'Location'),
          const SizedBox(height: AppSizes.spaceBtwInputFields),
          LabeledTextField(
            label: 'Description',
            hint: 'Tell us what makes this place special...',
            maxLines: 4,
          ),
          const SizedBox(height: AppSizes.spaceBtwInputFields),
          LabeledChips(
            label: 'Tags',
            options: const [
              'Family Friendly',
              'Pet Friendly',
              'Outdoor',
              'Indoor',
              'Romantic',
              'Budget Friendly',
              'Luxury',
            ],
          ),
        ],
      ),
    );
  }
}
