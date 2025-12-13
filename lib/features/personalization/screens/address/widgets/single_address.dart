import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:reviews_app/data/services/localization/localization_service.dart';
import 'package:reviews_app/features/personalization/controllers/address_controller.dart';
import 'package:reviews_app/features/personalization/models/address_model.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';

class SingleAddress extends StatelessWidget {
  const SingleAddress({super.key, required this.address, this.onTap});

  final AddressModel address;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final controller = AddressController.instance;
    final dark = AppHelperFunctions.isDarkMode(context);
    final localizationServie = LocalizationService.instance;

    return Obx(() {
      final selectedAddressId = controller.selectedAddress.value.id;
      final selectedAddress = selectedAddressId == address.id;

      final containerBackgroundColor = selectedAddress
          ? AppColors.primaryColor.withValues(alpha: 0.15)
          : Colors.transparent;
      final containerBorderColor = selectedAddress
          ? Colors.transparent
          : dark
          ? AppColors.darkerGrey
          : AppColors.grey;
      final primaryIconColor = selectedAddress
          ? AppColors.primaryColor
          : dark
          ? AppColors.white
          : AppColors.dark;

      return InkWell(
        onTap: onTap,
        child: AppRoundedContainer(
          width: double.infinity,
          showBorder: true,
          backgroundColor: containerBackgroundColor,
          borderColor: containerBorderColor,
          margin: EdgeInsets.only(bottom: AppSizes.spaceBtwItems),
          padding: EdgeInsets.all(AppSizes.md),
          child: Stack(
            children: [
              /// -- Selection Tick Icon
              Positioned(
                right: localizationServie.isRTL() ? null : 5,
                left: localizationServie.isRTL() ? 5 : null,
                top: 0,
                child: Icon(
                  selectedAddress ? Iconsax.tick_circle5 : null,
                  color: selectedAddress ? AppColors.primaryColor : null,
                  size: AppSizes.iconMd,
                ),
              ),

              /// -- content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// -- Leading Icon
                  Icon(
                    Iconsax.location,
                    color: primaryIconColor,
                    size: AppSizes.iconMd,
                  ),
                  const SizedBox(width: AppSizes.md),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// -- username
                        Row(
                          children: [
                            const Icon(
                              Iconsax.user,
                              size: 18,
                              color: AppColors.darkGrey,
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Text(
                              address.name,
                              // 'Nawaf',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: primaryIconColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.sm / 1.5),

                        /// -- Phone Number
                        Row(
                          children: [
                            const Icon(
                              Iconsax.call,
                              size: AppSizes.iconSm,
                              color: AppColors.darkGrey,
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Text(
                              address.formattedPhoneNo,
                              // '(+967) 778228445',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.sm / 1.5),

                        /// -- Full Address
                        Row(
                          children: [
                            const Icon(
                              Iconsax.location,
                              size: AppSizes.iconSm,
                              color: AppColors.darkGrey,
                            ),
                            const SizedBox(width: AppSizes.sm),

                            Flexible(
                              child: Text(
                                address.toString(),
                                // '26 Taiz, 26str, Military, sa-str, Yemen',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
