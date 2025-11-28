import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/login_signup/form_divider.dart';
import 'package:reviews_app/common/widgets/login_signup/social_button.dart';
import 'package:reviews_app/features/authentication/screens/signup/widgets/signup_form.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
// import 'package:reviews_app/utils/constants/text_strings.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';

import '../../../../localization/app_localizations.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back,
            color: AppHelperFunctions.isDarkMode(context)
                ? AppColors.white
                : AppColors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              Text(
                // AppTexts.signupTitle,
                AppLocalizations.of(context).signupTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),

              /// Form
              const SignupForm(),
              const SizedBox(height: AppSizes.spaceBtwSections),

              /// Divider
              // FormDivider(dividerText: AppTexts.orSignUpWith.capitalize!),
              FormDivider(
                dividerText: AppLocalizations.of(
                  context,
                ).orSignUpWith.capitalize!,
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),

              /// Social Buttons
              const AppSocialButton(),
            ],
          ),
        ),
      ),
    );
  }
}
