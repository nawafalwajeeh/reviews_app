import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/features/authentication/controllers/forget_password/forget_password_controller.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/validators/validation.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordController());

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Heading
              Text(
                // AppTexts.forgetPasswordTitle,
                AppLocalizations.of(context).forgetPasswordTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSizes.spaceBtwItems),
              Text(
                // AppTexts.forgetPasswordSubTitle,
                AppLocalizations.of(context).forgetPasswordSubTitle,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: AppSizes.spaceBtwSections * 2),

              /// Text Field
              Form(
                key: controller.forgetPasswordFormKey,
                child: TextFormField(
                  controller: controller.email,
                  validator: AppValidator.validateEmail,
                  decoration: InputDecoration(
                    // labelText: AppTexts.email,
                    labelText: AppLocalizations.of(context).email,
                    prefixIcon: Icon(Iconsax.direct_right),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),

              /// Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.sendPasswordResetEmail(),
                  // child: const Text(AppTexts.submit),
                  child: Text(AppLocalizations.of(context).submit),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
