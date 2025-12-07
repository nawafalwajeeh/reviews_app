import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/features/authentication/controllers/login/login_controller.dart';
import 'package:reviews_app/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:reviews_app/features/authentication/screens/signup/signup_screen.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/validators/validation.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Form(
      key: controller.loginFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.spaceBtwSections,
        ),
        child: Column(
          children: [
            /// Email
            TextFormField(
              controller: controller.email,
              validator: (value) => AppValidator.validateEmail(value),
              decoration: InputDecoration(
                prefixIcon: Icon(Iconsax.direct_right),
                // labelText: AppTexts.email,
                labelText: AppLocalizations.of(context).email,
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwInputFields),

            /// Password
            Obx(
              () => TextFormField(
                controller: controller.password,
                validator: (value) => AppValidator.validateEmptyText(
                  AppLocalizations.of(context).password,
                  value,
                ),
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

            const SizedBox(height: AppSizes.spaceBtwInputFields / 2),

            /// Remember Me & Forget Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Remember Me
                Row(
                  children: [
                    Obx(
                      () => Checkbox(
                        value: controller.rememberMe.value,
                        onChanged: (value) => controller.rememberMe.value =
                            !controller.rememberMe.value,
                      ),
                    ),

                    // const Text(AppTexts.rememberMe),
                    Text(AppLocalizations.of(context).rememberMe),
                  ],
                ),

                /// Forget Password
                TextButton(
                  onPressed: () => Get.to(() => const ForgetPasswordScreen()),
                  // child: const Text(AppTexts.forgetPassword),
                  child: Text(AppLocalizations.of(context).forgetPassword),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceBtwSections),

            /// Sign In Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // onPressed: () => Get.offAll(() => const NavigationMenu()),
                onPressed: () => controller.emailAndPasswordSignIn(),
                // child: const Text(AppTexts.signIn),
                child: Text(AppLocalizations.of(context).signIn),
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),

            /// Create account Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.to(() => const SignupScreen()),
                // child: const Text(AppTexts.createAccount),
                child: Text(AppLocalizations.of(context).createAccount),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
