import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/features/authentication/controllers/signup/signup_controller.dart';
import 'package:reviews_app/features/authentication/screens/signup/widgets/terms_conditions_checkbox.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/validators/validation.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

    return Form(
      key: controller.signupFormKey,
      child: Column(
        children: [
          /// First & last Name
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.firstName,
                  validator: (value) => AppValidator.validateEmptyText(
                    AppLocalizations.of(context).firstName,
                    value,
                  ),
                  expands: false,
                  decoration: InputDecoration(
                    // labelText: AppTexts.firstName,
                    labelText: AppLocalizations.of(context).firstName,
                    prefixIcon: Icon(Iconsax.user),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spaceBtwInputFields),
              Expanded(
                child: TextFormField(
                  controller: controller.lastName,
                  validator: (value) => AppValidator.validateEmptyText(
                    AppLocalizations.of(context).lastName,
                    value,
                  ),
                  expands: false,
                  decoration: InputDecoration(
                    // labelText: AppTexts.lastName,
                    labelText: AppLocalizations.of(context).lastName,
                    prefixIcon: Icon(Iconsax.user),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceBtwInputFields),

          /// Username
          TextFormField(
            controller: controller.username,
            validator: (value) => AppValidator.validateEmptyText(
              AppLocalizations.of(context).username,
              value,
            ),
            decoration: InputDecoration(
              // labelText: AppTexts.username,
              labelText: AppLocalizations.of(context).username,
              prefixIcon: Icon(Iconsax.user_edit),
            ),
          ),
          const SizedBox(height: AppSizes.spaceBtwInputFields),

          /// Email
          TextFormField(
            controller: controller.email,
            validator: (value) => AppValidator.validateEmail(value),
            decoration: InputDecoration(
              // labelText: AppTexts.email,
              labelText: AppLocalizations.of(context).email,
              prefixIcon: Icon(Iconsax.direct),
            ),
          ),
          const SizedBox(height: AppSizes.spaceBtwInputFields),

          /// Phone Number
          TextFormField(
            controller: controller.phoneNumber,
            validator: (value) => AppValidator.validatePhoneNumber(value),
            decoration: InputDecoration(
              // labelText: AppTexts.phoneNo,
              labelText: AppLocalizations.of(context).phoneNumber,
              prefixIcon: Icon(Iconsax.call),
            ),
          ),
          const SizedBox(height: AppSizes.spaceBtwInputFields),

          /// Password
          Obx(
            () => TextFormField(
              controller: controller.password,
              validator: (value) => AppValidator.validatePassword(value),
              obscureText: controller.obscureText.value,
              decoration: InputDecoration(
                // labelText: AppTexts.password,
                labelText: AppLocalizations.of(context).password,
                prefixIcon: Icon(Iconsax.password_check),
                suffixIcon: IconButton(
                  onPressed: () => controller.obscureText.value =
                      !controller.obscureText.value,
                  icon: Icon(
                    controller.obscureText.value
                        ? Iconsax.eye_slash
                        : Iconsax.eye,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spaceBtwSections),

          /// Terms&Conditions Checkbox
          const TermsAndConditionsCheckbox(),
          const SizedBox(height: AppSizes.spaceBtwSections),

          ///  Sign Up Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // onPressed: () => Get.to(() => const VerifyEmailScreen()),
              onPressed: () => controller.signup(),
              // child: const Text(AppTexts.createAccount),
              child: Text(AppLocalizations.of(context).createAccount),
            ),
          ),
        ],
      ),
    );
  }
}
