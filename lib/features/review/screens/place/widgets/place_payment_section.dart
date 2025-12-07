import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/texts/section_heading.dart';
import 'package:reviews_app/features/review/controllers/payment_method_controller.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';

import '../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../../utils/constants/sizes.dart';

class PlacePaymentSection extends StatelessWidget {
  const PlacePaymentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentMethodController());
    final dark = AppHelperFunctions.isDarkMode(context);

    return Column(
      children: [
        AppSectionHeading(
          title: 'Payment Method',
          buttonTitle: 'Change',
          onPressed: () => controller.selectPaymentMethod(context),
        ),
        const SizedBox(height: AppSizes.spaceBtwItems / 2),

        Obx(
          () => Row(
            children: [
              AppRoundedContainer(
                width: 60,
                height: 40,
                backgroundColor: dark ? AppColors.light : AppColors.white,
                padding: const EdgeInsets.all(AppSizes.sm),
                child: Image(
                  // image: AssetImage(AppImages.paypal),
                  image: AssetImage(
                    controller.selectedPaymentMethod.value.image,
                  ),
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: AppSizes.spaceBtwItems / 2),
              Text(
                // 'Paypal',
                controller.selectedPaymentMethod.value.name,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
