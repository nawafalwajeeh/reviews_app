import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/features/review/controllers/category_controller.dart';
import 'package:reviews_app/features/review/controllers/place_controller.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';
import '../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../../utils/validators/validation.dart';
import 'place_address_section.dart';
import 'place_payment_section.dart';
import 'label_chip.dart';

class PlaceForm extends StatelessWidget {
  final bool isEditMode;

  const PlaceForm({super.key, this.isEditMode = false});

  @override
  Widget build(BuildContext context) {
    final controller = PlaceController.instance;
    final categoryController = CategoryController.instance;

    return Column(
      children: [
        TextFormField(
          controller: controller.titleController,
          validator: (value) =>
              AppValidator.validateEmptyText('Place Name', value),
          decoration: InputDecoration(
            labelText: 'Place Name',
            hintText: 'Enter the name of this place',
          ),
        ),
        const SizedBox(height: AppSizes.spaceBtwInputFields),

        // Obx(
        //   () => DropdownButtonFormField(
        //     decoration: InputDecoration(
        //       border: OutlineInputBorder(
        //         borderSide: BorderSide(
        //           width: 1,
        //           color: AppHelperFunctions.isDarkMode(context)
        //               ? AppColors.grey
        //               : AppColors.darkGrey,
        //         ),
        //       ),
        //     ),
        //     initialValue: controller.selectedCategoryId.value.isNotEmpty
        //         ? categoryController.categoryModels
        //               .firstWhereOrNull(
        //                 (cat) => cat.id == controller.selectedCategoryId.value,
        //               )
        //               ?.name
        //         : categoryController.selectedCategoryName.value,
        //     onChanged: (String? selectedName) {
        //       if (selectedName != null) {
        //         final matchingCategory = categoryController.categoryModels
        //             .firstWhereOrNull(
        //               (category) => category.name == selectedName,
        //             );
        //         if (matchingCategory != null) {
        //           controller.selectedCategoryId.value = matchingCategory.id;
        //         } else {
        //           controller.selectedCategoryId.value = '';
        //         }
        //       } else {
        //         controller.selectedCategoryId.value = '';
        //       }
        //     },
        //     items: categoryController.categoryNames
        //         .map(
        //           (option) =>
        //               DropdownMenuItem(value: option, child: Text(option)),
        //         )
        //         .toList(),
        //   ),
        // ),
        Obx(() {
          // 1. Get the current value from the controller.
          // This value must be null or match an item in the list.
          final String? currentDropdownValue =
              controller.selectedCategoryName.value.isEmpty
              ? null
              : controller.selectedCategoryName.value;

          return DropdownButtonFormField<String>(
            // Use 'value' instead of 'initialValue'.
            // This is necessary when the value changes based on the state.
            initialValue: currentDropdownValue,

            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1,
                  color: AppHelperFunctions.isDarkMode(context)
                      ? AppColors.grey
                      : AppColors.darkGrey,
                ),
              ),
            ),

            // Ensure the onChanged logic updates the Name AND the ID.
            onChanged: (String? selectedName) {
              // Update the name variable
              controller.selectedCategoryName.value = selectedName ?? '';

              if (selectedName != null) {
                final matchingCategory = categoryController.categoryModels
                    .firstWhereOrNull(
                      (category) => category.name == selectedName,
                    );

                // Update the ID variable
                controller.selectedCategoryId.value =
                    matchingCategory?.id ?? '';
              } else {
                controller.selectedCategoryId.value = '';
              }
            },

            items: categoryController.categoryNames
                .map(
                  (option) =>
                      DropdownMenuItem(value: option, child: Text(option)),
                )
                .toList(),
          );
        }),

        const SizedBox(height: AppSizes.spaceBtwInputFields),
        // LabeledLocationPicker(label: 'Location'),

        /// Billing Section
        AppRoundedContainer(
          padding: const EdgeInsets.all(AppSizes.md),
          showBorder: true,
          backgroundColor: AppHelperFunctions.isDarkMode(context)
              ? AppColors.black
              : AppColors.white,
          child: Column(
            spacing: AppSizes.spaceBtwItems,
            children: [
              /// Payment Methods
              const PlacePaymentSection(),
              const Divider(),

              /// Address
              const PlaceAddressSection(),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.spaceBtwInputFields),
        TextFormField(
          maxLines: 4,
          controller: controller.descriptionController,
          validator: (value) =>
              AppValidator.validateEmptyText('Place Name', value),

          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'Tell us what makes this place special...',
          ),
        ),

        const SizedBox(height: AppSizes.spaceBtwInputFields),

        /// Phone Number
        TextFormField(
          controller: controller.phoneController,
          validator: (value) => AppValidator.validatePhoneNumber(value),
          decoration: InputDecoration(
            labelText: 'Phone Number',
            hintText: 'Enter your phone number',
          ),
        ),
        const SizedBox(height: AppSizes.spaceBtwInputFields),

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
