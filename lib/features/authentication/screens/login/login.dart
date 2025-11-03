import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:reviews_app/common/styles/spacing_styles.dart';
import 'package:reviews_app/common/widgets/login_signup/form_divider.dart';
import 'package:reviews_app/common/widgets/login_signup/social_button.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/constants/text_strings.dart';

import '../../../../data/repositories/authentication/authentication_repository.dart';
import 'widgets/login_form.dart';
import 'widgets/login_header.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () async {
              // Perform anonymous sign-in
              await AuthenticationRepository.instance.signInAnonymously();
            },
            // Using "Skip" text, often defined in AppTexts, to signal anonymous login
            child: Text(
              // Assuming 'skip' is defined in AppTexts, otherwise use "Skip"
              AppTexts.skip.isEmpty ? AppTexts.skip : 'Skip',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                // Use primary color for visibility
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(
            width: AppSizes.defaultSpace,
          ), // Add padding from the edge
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyles.paddingWithAppBarHeight,
          child: Column(
            children: [
              /// Logo, Title, subTitle
              const LoginHeader(),
              const SizedBox(height: AppSizes.spaceBtwSections),

              /// Form
              const LoginForm(),

              /// Divider
              FormDivider(dividerText: AppTexts.orSignInWith.capitalize!),
              const SizedBox(height: AppSizes.spaceBtwSections),

              /// Footer
              const AppSocialButton(),
            ],
          ),
        ),
      ),
    );
  }
}
