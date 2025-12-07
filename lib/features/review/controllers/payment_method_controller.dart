import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/place/payment/payment_method_content.dart';
import '../../../utils/constants/image_strings.dart';
import '../models/payment_method_model.dart';

class PaymentMethodController extends GetxController {
  static PaymentMethodController get instance => Get.find();

  /// Variables
  final Rx<PaymentMethodModel> selectedPaymentMethod =
      PaymentMethodModel.empty().obs;

  @override
  void onInit() {
    super.onInit();
    selectedPaymentMethod.value = PaymentMethodModel(
      name: 'Kuraimi Bank',
      image: AppImages.kuraimiBank,
    );
  }

  Future<void> selectPaymentMethod(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return PaymentMethodsContent();
      },
    );
  }
}
