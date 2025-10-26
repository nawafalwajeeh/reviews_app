import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/image_strings.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';

import '../custom_shapes/containers/rounded_container.dart';

class AppPaymentTile extends StatelessWidget {
  // const AppPaymentTile({super.key, required this.paymentMethod});
  const AppPaymentTile({super.key});

  // final PaymentMethodModel paymentMethod;

  @override
  Widget build(BuildContext context) {
    // final controller = CheckoutController.instance;
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      onTap: () {
        // controller.selectedPaymentMethod.value = paymentMethod;
        Get.back();
      },
      leading: AppRoundedContainer(
        width: 60,
        // height: 35,
        height: 40,
        backgroundColor: AppHelperFunctions.isDarkMode(context)
            ? AppColors.light
            : AppColors.white,
        padding: const EdgeInsets.all(AppSizes.sm),
        child: Image(
          image: AssetImage(AppImages.paypal),
          // image: AssetImage(paymentMethod.image),
          fit: BoxFit.contain,
        ),
      ),
      title: Text(
        'Paypal',
        // paymentMethod.name,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: const Icon(Iconsax.arrow_right_34),
    );
  }
}
