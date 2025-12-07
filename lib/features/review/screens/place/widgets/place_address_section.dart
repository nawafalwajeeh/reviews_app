import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/features/review/controllers/place_controller.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../localization/app_localizations.dart';
import '../../../../../utils/constants/colors.dart';

class PlaceAddressSection extends StatelessWidget {
  const PlaceAddressSection({super.key});

  @override
  Widget build(BuildContext context) {
    final PlaceController placeController = PlaceController.instance;

    return Obx(() {
      // Use the address stored specifically for this place (creation/editing)
      final selectedAddress = placeController.selectedAddress.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeading(
            title: AppLocalizations.of(context).placeAddress,
            titleStyle: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
            buttonTitle: AppLocalizations.of(context).change,
            // Direct map picking for cleaner UX
            onPressed: () => placeController.pickAddressFromMap(),
          ),

          selectedAddress.id.isNotEmpty || selectedAddress.toString().isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedAddress.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),

                    const SizedBox(height: AppSizes.spaceBtwItems / 2),

                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: AppColors.darkGrey,
                          size: 16,
                        ),
                        const SizedBox(width: AppSizes.spaceBtwItems),
                        Text(
                          selectedAddress.phoneNumber,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spaceBtwItems / 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_history,
                          color: AppColors.darkGrey,
                          size: 16,
                        ),
                        const SizedBox(width: AppSizes.spaceBtwItems),
                        Flexible(
                          child: Text(
                            selectedAddress.toString(),
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Text(
                  AppLocalizations.of(context).selectAddress,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
        ],
      );
    });
  }
}
