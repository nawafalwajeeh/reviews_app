import 'package:flutter/material.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/image_strings.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
// import 'package:reviews_app/utils/constants/text_strings.dart';
// import 'package:reviews_app/utils/helpers/helper_functions.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // final bool dark = AppHelperFunctions.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image(
          // height: 150,
          height: 160,
          image: AssetImage(
            // dark ? AppImages.lightAppLogo : AppImages.darkAppLogo,
            AppImages.appLogo,
          ),
        ),
        Text(
          // AppTexts.loginTitle,
          AppLocalizations.of(context).loginTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          // AppTexts.loginSubTitle,
          AppLocalizations.of(context).loginSubTitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
