import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reviews_app/data/repositories/authentication/authentication_repository.dart';
import 'package:reviews_app/data/repositories/user/user_repository.dart';
import 'package:reviews_app/features/personalization/models/user_model.dart';
import 'package:reviews_app/features/personalization/screens/profile/widgets/re_authenticate_user_login_form.dart';
import 'package:reviews_app/utils/constants/image_strings.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/network_manager.dart';
import 'package:reviews_app/utils/logging/logger.dart';
import 'package:reviews_app/utils/popups/full_screen_loader.dart';
import 'package:reviews_app/utils/popups/loaders.dart';
// import 'package:permission_handler/permission_handler.dart';

import '../../authentication/screens/login/login.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final obscureText = false.obs;
  final profileLoading = false.obs;
  final imageUploading = false.obs;
  Rx<UserModel> user = UserModel.empty().obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  final userRepository = Get.put(UserRepository());
  GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();
  final localStorage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    fetchUserRecord();
  }

  Future<void> fetchUserRecord() async {
    try {
      profileLoading.value = true;
      final user = await userRepository.fetchUserDetails();
      this.user(user);
    } catch (e) {
      user(UserModel.empty());
    } finally {
      profileLoading.value = false;
    }
  }

  /// Save user Record from any Registration Provider
  Future<void> saveUserRecordFromCredentials(
    UserCredential? userCredentials,
  ) async {
    try {
      // First update Rx User and then check if user data is already stored. If not store new data.
      await fetchUserRecord();

      if (user.value.id!.isEmpty) {
        if (userCredentials != null) {
          // convert Name to First and Last Name
          final nameParts = UserModel.nameParts(
            userCredentials.user?.displayName ?? '',
          );
          final username = UserModel.generateUsername(
            userCredentials.user?.displayName ?? '',
          );

          // Map Data
          final newUser = UserModel(
            id: userCredentials.user!.uid,
            firstName: nameParts[0],
            lastName: nameParts.length > 1
                ? nameParts.sublist(1).join(' ')
                : '',
            userName: username,
            email: userCredentials.user?.email ?? '',
            phoneNumber: userCredentials.user?.phoneNumber ?? '',
            profilePicture: userCredentials.user?.photoURL ?? '',
          );

          // Save Data to Firebase db
          // await userRepository.saveUserRecord(user);
          await saveUserRecord(newUser);
        }
      }
    } catch (e) {
      AppLoaders.warningSnackBar(
        title: 'Date not saved',
        message:
            'Something went wrong while saving your information. You can re-save your data in your profile.',
      );
    }
  }

  /// Save user Record from any Registration Provider
  Future<void> saveUserRecord(UserModel userModel) async {
    try {
      await userRepository.saveUserRecord(userModel);
      user.value = userModel;
    } catch (e) {
      throw e.toString();
    }
  }

  /// Delete Account Warning
  void deleteAccountWarningPopup() {
    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(AppSizes.md),
      title: 'Delete Account',
      middleText:
          'Are you sure you want to delete your account permanently? This action is not reversible and all of your data will be removed permanently.',
      confirm: ElevatedButton(
        onPressed: () async => await deleteUserAccount(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.lg),
          child: Text('Delete'),
        ),
      ),
      cancel: OutlinedButton(
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
        child: Text('Cancel'),
      ),
    );
  }

  /// Delete user Account
  Future<void> deleteUserAccount() async {
    try {
      // Start Loading
      AppFullScreenLoader.openLoadingDialog(
        'Processing',
        AppImages.docerAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await AppNetworkManager.instance.isConnected();
      if (!isConnected) {
        AppFullScreenLoader.stopLoading();
        return;
      }

      // first Re-Authenticate user
      final auth = AuthenticationRepository.instance;
      final provider = auth.authUser!.providerData
          .map((e) => e.providerId)
          .first;
      if (provider.isNotEmpty) {
        // Re Verify Auth Email
        if (provider == 'google.com') {
          await auth.signInWithGoogle();
          await auth.deleteAccount();
          AppFullScreenLoader.stopLoading();
          localStorage.write('REMEMBER_ME_EMAIL', '');
          localStorage.write('REMEMBER_ME_PASSWORD', '');
          AppLoaders.successSnackBar(
            title: 'Account Deleted',
            message: 'Your account has been deleted successfully.',
          );
          Get.off(() => const LoginScreen());
        } else if (provider == 'password') {
          AppFullScreenLoader.stopLoading();
          localStorage.write('REMEMBER_ME_EMAIL', '');
          localStorage.write('REMEMBER_ME_PASSWORD', '');
          AppLoaders.successSnackBar(
            title: 'Account Deleted',
            message: 'Your account has been deleted successfully.',
          );
          Get.to(() => const ReAuthLoginForm());
        }
      }
    } catch (e) {
      AppFullScreenLoader.stopLoading();
      AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Re-Authenticate before deleting
  Future<void> reAuthenticateEmailAndPasswordUser() async {
    try {
      // Start Loading
      AppFullScreenLoader.openLoadingDialog(
        'Processing',
        AppImages.docerAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await AppNetworkManager.instance.isConnected();
      if (!isConnected) {
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Form validation
      if (!reAuthFormKey.currentState!.validate()) {
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Re-Auth
      await AuthenticationRepository.instance
          .reAuthenticateWithEmailAndPassword(
            verifyEmail.text.trim(),
            verifyPassword.text.trim(),
          );
      await AuthenticationRepository.instance.deleteAccount();
      AppFullScreenLoader.stopLoading();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      AppFullScreenLoader.stopLoading();
      AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Upload Profile Picture with Firebase Storage or SupaBase Storage
  Future<void> uploadUserProfilePicture() async {
    try {
      // Request photo permission with supBase only not needed with Firebase Storage
      // var photoStatus = await Permission.photos.request();

      // if (!photoStatus.isGranted) {
      //   AppLoaders.errorSnackBar(
      //     title: 'Permission Denied',
      //     message:
      //         'Please allow access to your photos to upload a profile picture.',
      //   );
      //   return;
      // }
      //-----------------------
      // Proceed with the image upload
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxHeight: 512,
        maxWidth: 512,
      );

      // Check Internet Connectivity
      final isConnected = await AppNetworkManager.instance.isConnected();
      if (!isConnected) {
        AppFullScreenLoader.stopLoading();
        return;
      }
      // If image is not null
      if (image != null) {
        imageUploading.value = true;
        // Upload Image
        //-------------------------
        // With Firebase Storage
        // final imageUrl = await userRepository.uploadImage(
        //   'Users/Images/Profile/',
        //   image,
        // );
        //-------------------------
        // get the userId
        final userId = AuthenticationRepository.instance.getUserID;
        // With Supabase Storage
        // https://iofzzsfucawjnemyrcnr.supabase.co/storage/v1/object/public/Images/Profile/review_profile_image_2.jpeg
        final imageUrl = await userRepository.uploadImage(
          'Users/Profile/$userId',
          image,
        );
        debugPrint('Image URL: $imageUrl');

        // Update user Image Record
        Map<String, dynamic> json = {'ProfilePicture': imageUrl};
        await userRepository.updateSingleField(json);
        user.value.profilePicture = imageUrl;
        user.refresh();

        AppLoaders.successSnackBar(
          title: 'Congratulations',
          message: 'Your Profile Image has been updated!',
        );
      }
    } catch (e) {
      AppLoggerHelper.error('Error uploading image: $e');
      AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      imageUploading.value = false;
    }
  }
}
