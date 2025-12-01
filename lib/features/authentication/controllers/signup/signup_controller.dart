import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/data/repositories/authentication/authentication_repository.dart';
import 'package:reviews_app/features/authentication/screens/signup/verify_email.dart';
import 'package:reviews_app/features/personalization/controllers/user_controller.dart';
import 'package:reviews_app/utils/constants/image_strings.dart';
import 'package:reviews_app/utils/helpers/network_manager.dart';
import 'package:reviews_app/utils/popups/full_screen_loader.dart';
import 'package:reviews_app/utils/popups/loaders.dart';

import '../../../../localization/app_localizations.dart';
import '../../../personalization/models/user_model.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  /// Variables
  final RxBool obscureText = true.obs;
  final RxBool privacyPolicy = false.obs;
  final email = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  final phoneNumber = TextEditingController();
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  /// Signup
  Future<void> signup() async {
    try {
      // Start Loading
      AppFullScreenLoader.openLoadingDialog(
        // 'We are processing your information...',
        txt.weAreProcessingYourInformation,
        AppImages.docerAnimation,
      );

      // Check Internet Connectivity
      final icConnected = await AppNetworkManager.instance.isConnected();
      if (!icConnected) {
        // Remove Loader
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!signupFormKey.currentState!.validate()) {
        // Remove Loader
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Privacy Policy Check
      if (!privacyPolicy.value) {
        AppLoaders.warningSnackBar(
          // title: 'Accept Privacy Policy',
          title: txt.acceptPrivacyPolicy,
          // message:
              // 'In order to create account,'
              // 'you must have to read and accept the Privacy Policy & Terms of Use.',
              message: txt.privacyPolicyMessage
        );
        return;
      }

      // Register User in Firebase Authentication & Save user data in the Firebase
      final userCredential = await AuthenticationRepository.instance
          .registerWithEmailAndPassword(
            email.text.trim(),
            password.text.trim(),
          );

      // Save Authenticationed user data in the Firebase Firestore
      final newUser = UserModel(
        id: userCredential.user!.uid,
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        userName: username.text.trim(),
        email: email.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        profilePicture: '',
      );

      final userController = Get.put(UserController());
      await userController.saveUserRecord(newUser);

      // Remove Loader
      AppFullScreenLoader.stopLoading();

      // Show Success Message
      AppLoaders.successSnackBar(
        // title: 'Congratulations',
        title: txt.congratulations,
        // message: 'Your account has been created! Verify email to continue.',
        message: txt.accountCreatedVerifyEmail
      );
      // Move to Verify Email Screen
      Get.to(() => VerifyEmailScreen(email: email.text.trim()));
    } catch (e) {
      // Remove Loader
      AppFullScreenLoader.stopLoading();

      // Show some Generic Error to the user
      // AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      AppLoaders.errorSnackBar(title: txt.ohSnap, message: e.toString());
    }
  }
}
