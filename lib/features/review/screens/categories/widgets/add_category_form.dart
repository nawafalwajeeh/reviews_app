import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

import '../../../../../utils/validators/validation.dart';
import 'section_title.dart';

class AddCategoryForm extends StatelessWidget {
  const AddCategoryForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle('CATEGORY NAME'),
        const SizedBox(height: AppSizes.spaceBtwItems),
        TextFormField(
          // controller: controller.name,
          validator: (value) =>
              AppValidator.validateEmptyText('Category Name', value),
          decoration: const InputDecoration(
            prefixIcon: Icon(Iconsax.category),
            labelText: 'Category Name',
          ),
        ),
        SizedBox(height: AppSizes.spaceBtwInputFields),

        SectionTitle('DESCRIPTION'),
        const SizedBox(height: AppSizes.spaceBtwItems),
        TextFormField(
          // controller: controller.description,
          validator: (value) =>
              AppValidator.validateEmptyText('Description', value),
          textInputAction: TextInputAction.done,
          maxLines: 3,
          minLines: 3,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            prefixIcon: Icon(Iconsax.document_text),
            labelText: 'Description',
          ),
        ),
      ],
    );
  }
}
