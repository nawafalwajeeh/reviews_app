import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/features/review/controllers/category_controller.dart';
import 'package:reviews_app/features/review/controllers/place_controller.dart';
import 'package:reviews_app/features/review/models/category_extension.dart';
import 'package:reviews_app/features/review/models/tag_test_localization.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';
import '../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../../data/services/tag/tag_translation_service.dart';
import '../../../../../localization/app_localizations.dart';
import '../../../../../utils/validators/validation.dart';
import 'place_address_section.dart';
import 'label_chip.dart';

class PlaceForm extends StatelessWidget {
  final bool isEditMode;

  const PlaceForm({super.key, this.isEditMode = false});

  @override
  Widget build(BuildContext context) {
    final controller = PlaceController.instance;
    final categoryController = CategoryController.instance;
    final appLocalizations = AppLocalizations.of(context);

    return Column(
      children: [
        TextFormField(
          controller: controller.titleController,
          // validator: (value) =>
          //     AppValidator.validateEmptyText('Place Name', value),
          validator: (value) => AppValidator.validateEmptyText(
            AppLocalizations.of(context).placeName,
            value,
          ),
          decoration: InputDecoration(
            // labelText: 'Place Name',
            labelText: AppLocalizations.of(context).placeName,
            // hintText: 'Enter the name of this place',
            hintText: AppLocalizations.of(context).enterPlaceName,
          ),
        ),
        const SizedBox(height: AppSizes.spaceBtwInputFields),

        // Obx(() {
        //   // 1. Get the current value from the controller.
        //   // This value must be null or match an item in the list.
        //   final String? currentDropdownValue =
        //       controller.selectedCategoryName.value.isEmpty
        //       ? null
        //       : controller.selectedCategoryName.value;

        //   return DropdownButtonFormField<String>(
        //     // Use 'value' instead of 'initialValue'.
        //     // This is necessary when the value changes based on the state.
        //     initialValue: currentDropdownValue,

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

        //     // Ensure the onChanged logic updates the Name AND the ID.
        //     onChanged: (String? selectedName) {
        //       // Update the name variable
        //       controller.selectedCategoryName.value = selectedName ?? '';

        //       if (selectedName != null) {
        //         final matchingCategory = categoryController.categoryModels
        //             .firstWhereOrNull(
        //               (category) => category.name == selectedName,
        //             );

        //         // Update the ID variable
        //         controller.selectedCategoryId.value =
        //             matchingCategory?.id ?? '';
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
        //   );
        // }),
        // Obx(() {
        //   // Get the current localized category name
        //   final String? currentDropdownValue =
        //       controller.selectedCategoryName.value.isEmpty
        //       ? null
        //       : controller.selectedCategoryName.value;

        //   return DropdownButtonFormField<String>(
        //     initialValue: currentDropdownValue,
        //     decoration: InputDecoration(
        //       border: OutlineInputBorder(
        //         borderSide: BorderSide(
        //           width: 1,
        //           color: AppHelperFunctions.isDarkMode(context)
        //               ? AppColors.grey
        //               : AppColors.darkGrey,
        //         ),
        //       ),
        //       labelText: appLocalizations.selectCategory,
        //     ),

        //     onChanged: (String? selectedLocalizedName) {
        //       if (selectedLocalizedName != null) {
        //         // Find the category by localized name
        //         final matchingCategory = categoryController.categoryModels
        //             .firstWhereOrNull(
        //               (category) =>
        //                   category.getLocalizedName(context) ==
        //                   selectedLocalizedName,
        //             );

        //         if (matchingCategory != null) {
        //           // Update both name and ID
        //           controller.selectedCategoryName.value = selectedLocalizedName;
        //           controller.selectedCategoryId.value = matchingCategory.id;
        //         }
        //       } else {
        //         controller.selectedCategoryName.value = '';
        //         controller.selectedCategoryId.value = '';
        //       }
        //     },

        //     items: categoryController.categoryModels.map((category) {
        //       final localizedName = category.getLocalizedName(context);
        //       return DropdownMenuItem(
        //         value: localizedName,
        //         child: Text(localizedName),
        //       );
        //     }).toList(),
        //   );
        // }),
        Obx(() {
          // Get the current category ID
          final String? currentCategoryId =
              controller.selectedCategoryId.value.isEmpty
              ? null
              : controller.selectedCategoryId.value;

          return DropdownButtonFormField<String>(
            initialValue: currentCategoryId,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1,
                  color: AppHelperFunctions.isDarkMode(context)
                      ? AppColors.grey
                      : AppColors.darkGrey,
                ),
              ),
              labelText: appLocalizations.selectCategory,
            ),

            onChanged: (String? selectedCategoryId) {
              if (selectedCategoryId != null) {
                // Find the category by ID
                final matchingCategory = categoryController.categoryModels
                    .firstWhereOrNull(
                      (category) => category.id == selectedCategoryId,
                    );

                if (matchingCategory != null) {
                  // Update both ID and localized name
                  controller.selectedCategoryId.value = selectedCategoryId;
                  controller.selectedCategoryName.value = matchingCategory
                      .getLocalizedName(context);
                }
              } else {
                controller.selectedCategoryId.value = '';
                controller.selectedCategoryName.value = '';
              }
            },

            items: categoryController.categoryModels.map((category) {
              final localizedName = category.getLocalizedName(context);
              return DropdownMenuItem(
                value: category.id, // Use ID as value to ensure uniqueness
                child: Text(localizedName),
              );
            }).toList(),
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
              // const PlacePaymentSection(),
              // const Divider(),

              /// Address
              const PlaceAddressSection(),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.spaceBtwInputFields),
        TextFormField(
          maxLines: 4,
          controller: controller.descriptionController,
          // validator: (value) =>
          //     AppValidator.validateEmptyText('Place Description', value),
          validator: (value) => AppValidator.validateEmptyText(
            AppLocalizations.of(context).placeDescription,
            value,
          ),

          decoration: InputDecoration(
            // labelText: 'Description',
            labelText: AppLocalizations.of(context).description,
            // hintText: 'Tell us what makes this place special...',
            hintText: AppLocalizations.of(context).enterDescription,
          ),
        ),

        const SizedBox(height: AppSizes.spaceBtwInputFields),

        /// Phone Number
        TextFormField(
          controller: controller.phoneController,
          validator: (value) => AppValidator.validatePhoneNumber(value),
          decoration: InputDecoration(
            // labelText: 'Phone Number',
            labelText: AppLocalizations.of(context).phoneNo,
            // hintText: 'Enter your phone number',
            hintText: AppLocalizations.of(context).enterPhoneNumber,
          ),
        ),
        const SizedBox(height: AppSizes.spaceBtwInputFields),
        // Website URL (Optional)
        TextFormField(
          controller: controller.websiteUrlController,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              return AppValidator.validateWebsite(value);
            }
            return null; // Optional field
          },
          decoration: InputDecoration(
            // labelText: 'Website URL (Optional)',
            labelText: AppLocalizations.of(context).websiteUrlOptional,
            hintText: 'https://example.com',
          ),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: AppSizes.spaceBtwInputFields),
        // LabeledChips(
        //   // label: 'Tags',
        //   label: AppLocalizations.of(context).tags,
        //   tags: controller.allTags,
        //   selectedTags: controller.selectedTags,
        //   onSelected: controller.toggleTag,
        // ),
        Obx(
          () => LabeledChips(
            label: appLocalizations.tags,
            tags: controller.allTags.getLocalizedTags(
              context,
            ), // This will show localized tags
            selectedTags: controller.selectedTags
                .getLocalizedTags(context)
                .obs, // Localize selected tags too
            onSelected: (tag) {
              // Convert localized tag back to English for storage
              final englishTag = _findEnglishTag(tag, context);
              if (englishTag != null) {
                controller.toggleTag(englishTag);
              }
            },
          ),
        ),
      ],
    );
  }

  // Helper method to find English tag from localized tag
  String? _findEnglishTag(String localizedTag, BuildContext context) {
    final englishTags = TagTranslationService().allEnglishTags;
    for (final englishTag in englishTags) {
      final translated = TagTranslationService().getTranslatedNameInContext(
        englishTag,
        context,
      );
      if (translated == localizedTag) {
        return englishTag;
      }
    }
    return null;
  }
}
