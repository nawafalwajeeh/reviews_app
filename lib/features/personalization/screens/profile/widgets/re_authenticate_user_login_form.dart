import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/features/personalization/controllers/user_controller.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/validators/validation.dart';
import '../../../../../localization/app_localizations.dart';

class ReAuthLoginForm extends StatelessWidget {
  const ReAuthLoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(AppLocalizations.of(context).reAuthenticate),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.defaultSpace),
          child: Form(
            key: controller.reAuthFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Email
                TextFormField(
                  controller: controller.verifyEmail,
                  validator: (value) => AppValidator.validateEmail(value),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Iconsax.direct_right),
                    labelText: AppLocalizations.of(context).email,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceBtwInputFields),

                /// Password
                Obx(
                  () => TextFormField(
                    controller: controller.verifyPassword,
                    validator: (value) => AppValidator.validateEmptyText(
                      AppLocalizations.of(context).password,
                      value,
                    ),
                    obscureText: controller.obscureText.value,
                    decoration: InputDecoration(
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

                /// Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        controller.reAuthenticateEmailAndPasswordUser(),
                    child: Text(AppLocalizations.of(context).verify),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

