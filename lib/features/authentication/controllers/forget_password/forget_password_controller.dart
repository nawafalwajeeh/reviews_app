import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:reviews_app/data/repositories/authentication/authentication_repository.dart';
import 'package:reviews_app/features/authentication/screens/password_configuration/reset_password.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/image_strings.dart';
import 'package:reviews_app/utils/helpers/network_manager.dart';
import 'package:reviews_app/utils/popups/full_screen_loader.dart';
import 'package:reviews_app/utils/popups/loaders.dart';

class ForgetPasswordController extends GetxController {
  static ForgetPasswordController get instance => Get.find();

  /// Variables
  final email = TextEditingController();
  GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

  /// Send Reset Password Email
  Future<void> sendPasswordResetEmail() async {
    try {
      // Start Loader
      AppFullScreenLoader.openLoadingDialog(
        // 'Processing your request...',
        txt.processingYourRequest,
        AppImages.docerAnimation,
      );

      // Check Internet Connection
      final isConnected = await AppNetworkManager.instance.isConnected();
      if (!isConnected) {
        // Remove Loader
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!forgetPasswordFormKey.currentState!.validate()) {
        // Remove Loader
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Send Reset Password Email
      await AuthenticationRepository.instance.sendPasswordResetEmail(
        email.text.trim(),
      );

      // Remove Loader
      AppFullScreenLoader.stopLoading();

      // Show Success Message
      AppLoaders.successSnackBar(
        // title: 'Email Sent',
        title: txt.emailSent,
        // message: 'Email Link Sent to Reset your Password'.tr,
        message: txt.emailLinkSentResetPassword,
      );

      // Redirect
      Get.to(() => ResetPasswordScreen(email: email.text.trim()));
    } catch (e) {
      // Remove Loader
      AppFullScreenLoader.stopLoading();
      // AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      AppLoaders.errorSnackBar(title: txt.ohSnap, message: e.toString());
    }
  }

  /// Re-send Reset Password Email
  Future<void> resendPasswordResetEmail(String email) async {
    try {
      // Start Loader
      AppFullScreenLoader.openLoadingDialog(
        // 'Processing your request...',
        txt.processingYourRequest,
        AppImages.docerAnimation,
      );

      // Check Internet Connection
      final isConnected = await AppNetworkManager.instance.isConnected();
      if (!isConnected) {
        // Remove Loader
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Re-Send Reset Password Email
      await AuthenticationRepository.instance.sendPasswordResetEmail(email);

      // Remove Loader
      AppFullScreenLoader.stopLoading();

      // Show Success Message
      AppLoaders.successSnackBar(
        // title: 'Email Sent',
        title: txt.emailSent,
        // message: 'Email Link Sent to Reset your Password'.tr,
        message: txt.emailLinkSentResetPassword,
      );
    } catch (e) {
      // Remove Loader
      AppFullScreenLoader.stopLoading();
      // AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      AppLoaders.errorSnackBar(title: txt.ohSnap, message: e.toString());
    }
  }
}
