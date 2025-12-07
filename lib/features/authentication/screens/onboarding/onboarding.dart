import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import '../../../../data/services/localization/localization_service.dart';
import '../../controllers/on_boarding/onboarding_controller.dart';
import 'widgets/onboarding_next_button.dart';
import '../../../../utils/constants/image_strings.dart';
import 'widgets/onboarding_dot_navigation.dart';
import 'widgets/onboarding_page.dart';
import 'widgets/onboarding_skip.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());
    final localizationService = LocalizationService.instance;

    debugPrint(localizationService.textDirection.toString());
    debugPrint('current Locale: ${localizationService.currentLanguage}');

    return Scaffold(
      body: Stack(
        children: [
          /// Horizontal Scrollable page
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,

            children: [
              OnBoardingPage(
                image: AppImages.onBoardingImage1,
                // title: AppTexts.onBoardingTitle1,
                title: AppLocalizations.of(context).onBoardingTitle1,
                // subTitle: AppTexts.onBoardingSubTitle1,
                subTitle: AppLocalizations.of(context).onBoardingSubTitle1,
              ),
              OnBoardingPage(
                image: AppImages.onBoardingImage2,
                // title: AppTexts.onBoardingTitle2,
                title: AppLocalizations.of(context).onBoardingTitle2,
                // subTitle: AppTexts.onBoardingSubTitle2,
                subTitle: AppLocalizations.of(context).onBoardingSubTitle2,
              ),
              OnBoardingPage(
                image: AppImages.onBoardingImage3,
                // title: AppTexts.onBoardingTitle3,
                title: AppLocalizations.of(context).onBoardingTitle3,
                // subTitle: AppTexts.onBoardingSubTitle3,
                subTitle: AppLocalizations.of(context).onBoardingSubTitle3,
              ),
            ],
          ),

          /// Skip Button
          const OnBoardingSkip(),

          /// Dot Navigation SmoothPageIndicator
          const OnBoardingDotNavigation(),

          /// Next Circular Button
          const OnBoardingNextButton(),
        ],
      ),
    );
  }
}
