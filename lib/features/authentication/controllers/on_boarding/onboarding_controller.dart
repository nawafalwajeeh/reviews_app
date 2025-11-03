import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../../screens/login/login.dart';

class OnBoardingController extends GetxController {
  static OnBoardingController get instance => Get.find();

  /// Variables
  final pageController = PageController();
  final RxInt currentPageIndex = 0.obs;
  final storage = GetStorage();

  /// Update current Index when Page Scrolled out
  void updatePageIndicator(int index) => currentPageIndex.value = index;

  /// Jump to the specific dot selected page
  void doNavigationClick(int index) {
    currentPageIndex.value = index;
    pageController.jumpTo(index.toDouble());
  }

  /// Update current index & jump to next page
  void nextPage() {
    if (currentPageIndex.value == 2) {
      // make [OnBoardingScreen] show only
      // The first time when the app has been installed.
      storage.write('IsFirstTime', false);
      Get.offAll(() => const LoginScreen());
    } else {
      final int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  /// Update current index & jump to the last page
  void skipPage() {
    currentPageIndex.value = 2;
    // make [OnBoardingScreen] show only
    // The first time when the app has been installed.
    storage.write('IsFirstTime', false);
    debugPrint('IsFirstTime: ${storage.read('IsFirstTime')}');
    Get.offAll(() => const LoginScreen());
  }
}
