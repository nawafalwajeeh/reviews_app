import 'package:flutter/material.dart';
import 'package:reviews_app/features/authentication/controllers/on_boarding/onboarding_controller.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/device/device_utility.dart';

class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: AppDeviceUtils.getAppBarHeight(),
      right: AppSizes.defaultSpace,
      child: TextButton(
        onPressed: () => OnBoardingController.instance.skipPage(),
        // child: const Text(AppTexts.skip),
        child: Text(AppLocalizations.of(context).skip),
      ),
    );
  }
}
