import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';

import '../../../controllers/place_controller.dart';

class LabeledLocationPicker extends StatelessWidget {
  final String label;

  const LabeledLocationPicker({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    // Get the instance of the controller
    final controller = PlaceController.instance;
    final dark = AppHelperFunctions.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),

        // Use Obx to rebuild this section whenever selectedLocationName changes
        Obx(() {
          final locationText = controller.selectedLocationName.value;
          final isLocationSet = locationText.isNotEmpty;

          return InkWell(
            // Call the controller's method to handle map navigation/selection
            onTap: controller.openLocationPicker,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: dark ? AppColors.black : AppColors.grey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.darkGrey),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      // Display the selected location or the placeholder text
                      isLocationSet
                          ? locationText
                          : 'Tap to set location from map',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isLocationSet
                            ? dark
                                  ? AppColors
                                        .white // Darker text for set location
                                  : AppColors.dark
                            : dark
                            ? AppColors.darkGrey
                            : AppColors.darkGrey, // Hint color for placeholder
                        fontWeight: isLocationSet
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  Icon(
                    // Change icon style based on whether location is set
                    isLocationSet
                        ? Icons.location_on
                        : Icons.location_on_outlined,
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
