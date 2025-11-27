import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/features/review/controllers/category_controller.dart';
import 'package:reviews_app/features/review/controllers/place_controller.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';
import '../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
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
            labelText: AppLocalizations.of(context).placeDescription,
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
        LabeledChips(
          // label: 'Tags',
          label: AppLocalizations.of(context).tags,
          tags: const [
            // General
            'Family Friendly',
            'Pet Friendly',
            'Budget Friendly',
            'Luxury',
            'Romantic',
            'Business',
            'Student Friendly',

            // Location Types
            'Outdoor',
            'Indoor',
            'Beachfront',
            'Mountain View',
            'City Center',
            'Suburban',
            'Rural',

            // Amenities
            'Free WiFi',
            'Parking Available',
            'Wheelchair Accessible',
            'Air Conditioned',
            'Heating',
            'Swimming Pool',
            'Gym',
            'Spa',

            // Activities
            'Live Music',
            'Sports Bar',
            'Gaming',
            'Karaoke',
            'Dance Floor',
            'Quiet Atmosphere',

            // Food & Drink
            'Vegetarian Options',
            'Vegan Options',
            'Gluten-Free Options',
            'Halal',
            'Alcohol Served',
            'Coffee Shop',
            'Fine Dining',
            'Fast Food',
            'Buffet',

            // Accommodation
            'Hotel',
            'Hostel',
            'Resort',
            'Vacation Rental',
            'Camping',

            // Entertainment
            'Cinema',
            'Theater',
            'Museum',
            'Art Gallery',
            'Shopping',
            'Amusement Park',

            // Services
            '24/7',
            'Delivery',
            'Takeaway',
            'Reservations',
            'Catering',
            'Event Space',

            // Special Features
            'Historic',
            'Modern',
            'Traditional',
            'Eco-Friendly',
            'LGBTQ+ Friendly',
            'Kid Friendly',
          ],
          selectedTags: controller.selectedTags,
          onSelected: controller.toggleTag,
        ),
      ],
    );
  }
}
