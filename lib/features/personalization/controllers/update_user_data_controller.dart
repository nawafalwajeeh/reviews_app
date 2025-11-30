import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:reviews_app/data/repositories/user/user_repository.dart';
import 'package:reviews_app/features/personalization/controllers/user_controller.dart';
import 'package:reviews_app/features/personalization/screens/profile/profile.dart';
import 'package:reviews_app/utils/constants/image_strings.dart';
import 'package:reviews_app/utils/helpers/network_manager.dart';
import 'package:reviews_app/utils/popups/full_screen_loader.dart';
import 'package:reviews_app/utils/popups/loaders.dart';

import '../../../localization/app_localizations.dart';

class UpdateUserDataController extends GetxController {
  static UpdateUserDataController get instance => Get.find();

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final phoneNumber = TextEditingController();
  final username = TextEditingController();
  final userController = UserController.instance;
  final userRepository = Get.put(UserRepository());

  // Form Keys
  GlobalKey<FormState> updateUserNameFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> updateUserPhoneFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> updateUserUsernameFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> updateUserBirthDateFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> updateUserGenderFormKey = GlobalKey<FormState>();

  // Reactive variables for selection
  final selectedGender = ''.obs;
  final selectedBirthDate = Rxn<DateTime>();

  /// Initialize user data when Home screen appears
  @override
  void onInit() {
    initializeUserData();
    super.onInit();
  }

  /// Fetch user record and initialize all fields
  Future<void> initializeUserData() async {
    firstName.text = userController.user.value.firstName;
    lastName.text = userController.user.value.lastName;
    phoneNumber.text = userController.user.value.phoneNumber;
    username.text = userController.user.value.userName;
    selectedGender.value = userController.user.value.gender ?? '';

    if (userController.user.value.birthDate != null) {
      selectedBirthDate.value = userController.user.value.birthDate;
    }
  }

  /// Update User Name
  Future<void> updateUserName() async {
    try {
      // Start loading
      AppFullScreenLoader.openLoadingDialog(
        // 'We are updating your information...',
        txt.weAreUpdatingYourInformation,
        AppImages.docerAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await AppNetworkManager.instance.isConnected();
      if (!isConnected) {
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!updateUserNameFormKey.currentState!.validate()) {
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Update user's first & last names in the Firebase Firestore
      Map<String, dynamic> name = {
        'FirstName': firstName.text.trim(),
        'LastName': lastName.text.trim(),
      };
      await userRepository.updateSingleField(name);

      // Update the Rx values
      userController.user.value.firstName = firstName.text.trim();
      userController.user.value.lastName = lastName.text.trim();

      // Remove Loader
      AppFullScreenLoader.stopLoading();

      // Show Success Message
      AppLoaders.successSnackBar(
        // title: 'Congratulations',
        title: txt.success,
        // message: 'Your Name has been updated.',
        message: txt.yourNameHasBeenUpdated,
      );

      // Move to previous Screen
      Get.off(() => ProfileScreen());
    } catch (e) {
      // Remove Loader
      AppFullScreenLoader.stopLoading();
      // AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      AppLoaders.errorSnackBar(title: txt.ohSnap, message: e.toString());
    }
  }

  /// Update Phone Number
  Future<void> updateUserPhone() async {
    try {
      // Start loading
      AppFullScreenLoader.openLoadingDialog(
        // 'We are updating your phone number...',
        txt.weAreUpdatingYourPhoneNumber,
        AppImages.docerAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await AppNetworkManager.instance.isConnected();
      if (!isConnected) {
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!updateUserPhoneFormKey.currentState!.validate()) {
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Update phone number in Firebase Firestore
      Map<String, dynamic> phoneData = {'PhoneNumber': phoneNumber.text.trim()};
      await userRepository.updateSingleField(phoneData);

      // Update the Rx value
      userController.user.value.phoneNumber = phoneNumber.text.trim();

      // Remove Loader
      AppFullScreenLoader.stopLoading();

      // Show Success Message
      AppLoaders.successSnackBar(
        // title: 'Success',
        title: txt.success,
        // message: 'Your phone number has been updated.',
        message: txt.yourPhoneNumberHasBeenUpdated,
      );

      // Move to previous Screen
      Get.off(() => ProfileScreen());
    } catch (e) {
      // Remove Loader
      AppFullScreenLoader.stopLoading();
      // AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      AppLoaders.errorSnackBar(title: txt.ohSnap, message: e.toString());
    }
  }

  /// Update Username
  Future<void> updateUserUsername() async {
    try {
      // Start loading
      AppFullScreenLoader.openLoadingDialog(
        // 'We are updating your username...',
        txt.weAreUpdatingYourUsername,
        AppImages.docerAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await AppNetworkManager.instance.isConnected();
      if (!isConnected) {
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!updateUserUsernameFormKey.currentState!.validate()) {
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Update username in Firebase Firestore
      Map<String, dynamic> usernameData = {'Username': username.text.trim()};
      await userRepository.updateSingleField(usernameData);

      // Update the Rx value
      userController.user.value.userName = username.text.trim();

      // Remove Loader
      AppFullScreenLoader.stopLoading();

      // Show Success Message
      AppLoaders.successSnackBar(
        // title: 'Success',
        title: txt.success,
        // message: 'Your username has been updated.',
        message: txt.yourUsernameHasBeenUpdated,
      );

      // Move to previous Screen
      Get.off(() => ProfileScreen());
    } catch (e) {
      // Remove Loader
      AppFullScreenLoader.stopLoading();
      // AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      AppLoaders.errorSnackBar(title: txt.ohSnap, message: e.toString());
    }
  }

  /// Update Gender
  Future<void> updateUserGender() async {
    try {
      // Start loading
      AppFullScreenLoader.openLoadingDialog(
        // 'We are updating your gender...',
        txt.weAreUpdatingYourGender,

        AppImages.docerAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await AppNetworkManager.instance.isConnected();
      if (!isConnected) {
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!updateUserGenderFormKey.currentState!.validate()) {
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Update gender in Firebase Firestore
      Map<String, dynamic> genderData = {'Gender': selectedGender.value};
      await userRepository.updateSingleField(genderData);

      // Update the Rx value
      userController.user.value.gender = selectedGender.value;

      // Remove Loader
      AppFullScreenLoader.stopLoading();

      // Show Success Message
      // AppLoaders.successSnackBar(
      //   title: 'Success',
      //   message: 'Your gender has been updated.',
      // );
      AppLoaders.successSnackBar(
        title: txt.success,
        message: txt.yourGenderHasBeenUpdated,
      );

      // Move to previous Screen
      Get.off(() => ProfileScreen());
    } catch (e) {
      // Remove Loader
      AppFullScreenLoader.stopLoading();
      // AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      AppLoaders.errorSnackBar(title: txt.ohSnap, message: e.toString());
    }
  }

  /// Update Birth Date
  Future<void> updateUserBirthDate() async {
    try {
      // Start loading
      AppFullScreenLoader.openLoadingDialog(
        // 'We are updating your birth date...',
        txt.weAreUpdatingYourBirthDate,

        AppImages.docerAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await AppNetworkManager.instance.isConnected();
      if (!isConnected) {
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation - Check if birth date is selected
      if (selectedBirthDate.value == null) {
        AppFullScreenLoader.stopLoading();
        AppLoaders.errorSnackBar(
          // title: 'Error',
          title: txt.error,
          // message: 'Please select your birth date.',
          message: txt.pleaseSelectYourBirthDate,
        );
        return;
      }

      // Update birth date in Firebase Firestore
      Map<String, dynamic> birthDateData = {
        'BirthDate': selectedBirthDate.value!.toIso8601String(),
      };
      await userRepository.updateSingleField(birthDateData);

      // Update the Rx value
      userController.user.value.birthDate = selectedBirthDate.value;

      // Remove Loader
      AppFullScreenLoader.stopLoading();

      // Show Success Message
      AppLoaders.successSnackBar(
        // title: 'Success',
        title: txt.success,
        // message: 'Your birth date has been updated.',
        message: txt.yourBirthDateHasBeenUpdated,
      );

      // Move to previous Screen
      Get.off(() => ProfileScreen());
    } catch (e) {
      // Remove Loader
      AppFullScreenLoader.stopLoading();
      // AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      AppLoaders.errorSnackBar(title: txt.ohSnap, message: e.toString());
    }
  }

  /// Set Gender
  void setGender(String gender) {
    selectedGender.value = gender;
  }

  /// Set Birth Date
  void setBirthDate(DateTime date) {
    selectedBirthDate.value = date;
  }

  /// Clear Birth Date
  void clearBirthDate() {
    selectedBirthDate.value = null;
  }
}
