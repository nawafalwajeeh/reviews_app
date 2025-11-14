import 'package:flutter/material.dart';
import 'package:reviews_app/features/review/models/payment_method_model.dart';
import 'package:reviews_app/utils/constants/image_strings.dart';

import '../../../../utils/constants/sizes.dart';
import '../../list_tiles/payment_tile.dart';
import '../../texts/section_heading.dart';

class PaymentMethodsContent extends StatelessWidget {
  const PaymentMethodsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeading(
              title: 'Select Payment Method',
              showActionButton: false,
            ),
            const SizedBox(height: AppSizes.spaceBtwSections),
            AppPaymentTile(
              paymentMethod: PaymentMethodModel(
                name: 'Kuraimi Bank',
                image: AppImages.kuraimiBank,
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems / 2),
            AppPaymentTile(
              paymentMethod: PaymentMethodModel(
                name: 'Paypal',
                image: AppImages.paypal,
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems / 2),
            AppPaymentTile(
              paymentMethod: PaymentMethodModel(
                name: 'Google Pay',
                image: AppImages.googlePay,
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems / 2),
            AppPaymentTile(
              paymentMethod: PaymentMethodModel(
                name: 'Apple Pay',
                image: AppImages.applePay,
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems / 2),
            AppPaymentTile(
              paymentMethod: PaymentMethodModel(
                name: 'VISA',
                image: AppImages.visa,
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems / 2),
            AppPaymentTile(
              paymentMethod: PaymentMethodModel(
                name: 'Master Card',
                image: AppImages.masterCard,
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems / 2),
            AppPaymentTile(
              paymentMethod: PaymentMethodModel(
                name: 'Paytm',
                image: AppImages.paytm,
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems / 2),
            AppPaymentTile(
              paymentMethod: PaymentMethodModel(
                name: 'Paystack',
                image: AppImages.paystack,
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems / 2),
            AppPaymentTile(
              paymentMethod: PaymentMethodModel(
                name: 'Credit Card',
                image: AppImages.creditCard,
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems / 2),
            const SizedBox(height: AppSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }
}
