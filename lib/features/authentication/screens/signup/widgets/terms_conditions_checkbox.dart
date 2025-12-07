import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:reviews_app/features/authentication/controllers/signup/signup_controller.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';

class TermsAndConditionsCheckbox extends StatelessWidget {
  const TermsAndConditionsCheckbox({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SignupController.instance;
    final dark = AppHelperFunctions.isDarkMode(context);

    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Obx(
            () => Checkbox(
              value: controller.privacyPolicy.value,
              onChanged: (value) => controller.privacyPolicy.value =
                  !controller.privacyPolicy.value,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.spaceBtwItems),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  // text: '${AppTexts.iAgreeTo} ',
                  text: '${AppLocalizations.of(context).iAgreeTo} ',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                TextSpan(
                  // text: '${AppTexts.privacyPolicy} ',
                  text: '${AppLocalizations.of(context).privacyPolicy} ',
                  style: Theme.of(context).textTheme.bodyMedium!.apply(
                    color: dark ? AppColors.white : AppColors.primaryColor,
                    decoration: TextDecoration.underline,
                    decorationColor: dark
                        ? AppColors.white
                        : AppColors.primaryColor,
                  ),
                ),
                TextSpan(
                  // text: '${AppTexts.and} ',
                  text: '${AppLocalizations.of(context).and} ',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                TextSpan(
                  // text: AppTexts.termsOfUse,
                  text: AppLocalizations.of(context).termsOfUse,
                  style: Theme.of(context).textTheme.bodyMedium!.apply(
                    color: dark ? AppColors.white : AppColors.primaryColor,
                    decoration: TextDecoration.underline,
                    decorationColor: dark
                        ? AppColors.white
                        : AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
