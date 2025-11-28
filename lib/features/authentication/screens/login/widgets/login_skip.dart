import 'package:flutter/material.dart';
import 'package:reviews_app/localization/app_localizations.dart';

import '../../../../../utils/constants/sizes.dart';
// import '../../../../../utils/constants/text_strings.dart';
import '../../../../../utils/device/device_utility.dart';
import '../../../controllers/login/login_controller.dart';

class LoginSkip extends StatelessWidget {
  const LoginSkip({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: AppDeviceUtils.getAppBarHeight(),
      right: AppSizes.defaultSpace,
      child: TextButton(
        onPressed: () => LoginController.instance.signInAnonymously(),
        // child: const Text(AppTexts.skip),
        child: Text(AppLocalizations.of(context).skip),
      ),
    );
  }
}