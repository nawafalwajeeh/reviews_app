import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:reviews_app/data/repositories/authentication/authentication_repository.dart';
// import 'package:reviews_app/features/personalization/controllers/user_controller.dart';
import 'package:reviews_app/utils/constants/image_strings.dart';
import 'package:reviews_app/utils/helpers/network_manager.dart';
import 'package:reviews_app/utils/popups/full_screen_loader.dart';
import 'package:reviews_app/utils/popups/loaders.dart';

import '../../../personalization/controllers/user_controller.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  /// Variables
  final localStorage = GetStorage();
  final RxBool obscureText = true.obs;
  final RxBool rememberMe = false.obs;
  final email = TextEditingController();
  final password = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  final userController = Get.put(UserController());

  @override
  void onInit() {
    if (AuthenticationRepository.instance.authUser != null) {
      email.text = localStorage.read('REMEMBER_ME_EMAIL') ?? '';
      password.text = localStorage.read('REMEMBER_ME_PASSWORD') ?? '';

      if (email.text.isNotEmpty) {
        rememberMe.value = true;
      }
    }
    super.onInit();
  }

  /// -- Login
  Future<void> emailAndPasswordSignIn() async {
    try {
      // Start Loading
      AppFullScreenLoader.openLoadingDialog(
        'Logging you in...',
        AppImages.docerAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await AppNetworkManager.instance.isConnected();
      if (!isConnected) {
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!loginFormKey.currentState!.validate()) {
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Save data if Remember Me is selected
      if (rememberMe.value) {
        localStorage.write('REMEMBER_ME_EMAIL', email.text.trim());
        localStorage.write('REMEMBER_ME_PASSWORD', password.text.trim());
      } else {
        // Clear saved data if the user unchecks "Remember Me"
        localStorage.remove('REMEMBER_ME_EMAIL');
        localStorage.remove('REMEMBER_ME_PASSWORD');
      }

      // Login user using Email & Password Authentication
      final _ = await AuthenticationRepository.instance
          .loginWithEmailAndPassword(email.text.trim(), password.text.trim());

      // Remove Loader
      AppFullScreenLoader.stopLoading();

      // Redirect
      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      // Remove Loader
      AppFullScreenLoader.stopLoading();

      // Show some Geneic Error to the user
      AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// -- Anonymous Sign-In (Skip)
  Future<void> signInAnonymously() async {
    try {
      // Start Loading
      AppFullScreenLoader.openLoadingDialog(
        'Entering as guest...',
        AppImages.docerAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await AppNetworkManager.instance.isConnected();
      if (!isConnected) {
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Perform Anonymous Sign-In via Repository
      await AuthenticationRepository.instance.signInAnonymously();

      // Remove Loader
      AppFullScreenLoader.stopLoading();

      // Redirect based on the new Anonymous User state
      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      // Handle Errors
      AppFullScreenLoader.stopLoading();

      // Show Geneic Error to the user
      AppLoaders.errorSnackBar(
        title: 'Oh Snap!',
        message:
            'Could not skip login. Please check your connection or try again: ${e.toString()}',
      );
    }
  }

  /// -- Google Sign-In Authentication
  Future<void> googleSignIn() async {
    try {
      // Start Loading
      AppFullScreenLoader.openLoadingDialog(
        'Logging you in...',
        AppImages.docerAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await AppNetworkManager.instance.isConnected();
      if (!isConnected) {
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Google Authentication
      final userCredentials = await AuthenticationRepository.instance
          .signInWithGoogle();

      // Save User Data to Firebase Firestore db
      await userController.saveUserRecordFromCredentials(userCredentials);

      // Remove Loader
      AppFullScreenLoader.stopLoading();

      // Redirect
      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      // Remove Loader
      AppFullScreenLoader.stopLoading();
      AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}
