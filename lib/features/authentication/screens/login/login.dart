import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:reviews_app/common/styles/spacing_styles.dart';
import 'package:reviews_app/common/widgets/login_signup/form_divider.dart';
import 'package:reviews_app/common/widgets/login_signup/social_button.dart';
import 'package:reviews_app/features/authentication/screens/login/widgets/login_skip.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../../../localization/app_localizations.dart';
import 'widgets/login_form.dart';
import 'widgets/login_header.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
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
                  // FormDivider(dividerText: AppTexts.orSignInWith.capitalize!),
                  FormDivider(
                    dividerText: AppLocalizations.of(
                      context,
                    ).orSignInWith.capitalize!,
                  ),
                  const SizedBox(height: AppSizes.spaceBtwSections),

                  /// Footer
                  const AppSocialButton(),
                ],
              ),
            ),
          ),

          /// Skip Button
          LoginSkip(),
        ],
      ),
    );
  }
}
