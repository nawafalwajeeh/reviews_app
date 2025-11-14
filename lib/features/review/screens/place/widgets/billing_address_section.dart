import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../personalization/controllers/address_controller.dart';

class BillingAddressSection extends StatelessWidget {
  const BillingAddressSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AddressController.instance;

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeading(
            title: 'Shipping Address',
            buttonTitle: 'Change',
            onPressed: () => controller.selectNewAddressPopup(context),
          ),

          controller.selectedAddress.value.id.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // 'Alwajeeh',
                      controller.selectedAddress.value.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),

                    const SizedBox(height: AppSizes.spaceBtwItems / 2),

                    Row(
                      children: [
                        Icon(Icons.phone, color: AppColors.darkGrey, size: 16),
                        const SizedBox(width: AppSizes.spaceBtwItems),
                        Text(
                          // '+967 778228445',
                          controller.selectedAddress.value.phoneNumber,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spaceBtwItems / 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_history,
                          color: AppColors.darkGrey,
                          size: 16,
                        ),
                        const SizedBox(width: AppSizes.spaceBtwItems),
                        Text(
                          // 'South Liana, Maine 87695, USA',
                          controller.selectedAddress.value.toString(),
                          softWrap: true,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                )
              : Text(
                  'Select Address',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
        ],
      ),
    );
  }
}
