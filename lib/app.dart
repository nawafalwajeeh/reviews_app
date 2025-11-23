import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/bindings/general_bindings.dart';
import 'package:reviews_app/routes/app_pages.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'features/personalization/controllers/settings_controller.dart';
import 'utils/constants/text_strings.dart';
import 'utils/theme/app_theme.dart';

/// -- Use this class to setup themes, initial Bindings,
/// any animations and much more.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    /// -- Initialize Settings controller to load theme mode from local Storage on app launch
    /// and change it when change theme mode button tapped in [SettingsScreen()].
    final controller = Get.put(SettingsController());

    return Obx(
      () => GetMaterialApp(
        title: AppTexts.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: controller.themeMode,
        initialBinding: GeneralBindings(),
        getPages: AppPages.pages,
        home: const Scaffold(
          backgroundColor: AppColors.primaryColor,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.white),
          ),
        ),
      ),
    );
  }
}
