import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reviews_app/data/repositories/user/user_repository.dart';
import 'package:reviews_app/features/authentication/screens/login/login.dart';
import 'package:reviews_app/features/authentication/screens/onboarding/onboarding.dart';
import 'package:reviews_app/navigation_menu.dart';
import 'package:reviews_app/utils/exceptions/firebase_auth_exceptions.dart';
import 'package:reviews_app/utils/exceptions/firebase_exceptions.dart';
import 'package:reviews_app/utils/exceptions/format_exceptions.dart';
import 'package:reviews_app/utils/exceptions/platform_exceptions.dart';
import 'package:reviews_app/utils/logging/logger.dart';
import '../../../features/authentication/screens/signup/verify_email.dart';
import '../../../features/personalization/screens/locale/select_language.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/local_storage/storage_utility.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  /// Variables
  final deviceStorage = GetStorage();
  // late final Rx<User?> _firebaseUser;
  late final Rx<User?> _firebaseUser = Rx<User?>(_auth.currentUser);
  final _auth = FirebaseAuth.instance;

  /// getters
  // Get Authenticated User data
  User? get authUser => _firebaseUser.value;

  // Check if the current user is a guest (anonymous)
  bool get isGuestUser => authUser != null && authUser!.isAnonymous;

  String get getUserID => _firebaseUser.value?.uid ?? "";

  String get getUserEmail => _firebaseUser.value?.email ?? "";

  String get getDisplayName => _firebaseUser.value?.displayName ?? "";

  String get getPhoneNo => _firebaseUser.value?.phoneNumber ?? "";

  String get getPhotoUrl => _firebaseUser.value?.photoURL ?? "";

  bool get isCurrentUser => getUserID == _firebaseUser.value?.uid;

  /// Called Immediately when the [AuthenticationRepository]
  /// instance is created and ready to go ahead.
  @override
  void onReady() {
    super.onReady();
    // _firebaseUser = Rx<User?>(_auth.currentUser);
    _firebaseUser.value = Rx<User?>(_auth.currentUser).value;
    _firebaseUser.bindStream(_auth.userChanges());
    FlutterNativeSplash.remove();
    screenRedirect();
  }

  /// Function to show Relevant screen
  // void screenRedirect() async {
  //   final user = _firebaseUser.value;

  //   // Check if navigation is ready
  //   if (Get.key.currentContext == null) {
  //     // If not ready, wait and try again
  //     Future.delayed(const Duration(milliseconds: 100), screenRedirect);
  //     return;
  //   }

  //   if (user != null) {
  //     // check if user is not anonymose
  //     if (!user.isAnonymous) {
  //       // User Logged-In: If email verified let the user go to Home Screen else to the Email Verification Screen
  //       if (user.emailVerified) {
  //         // Initialize user specific storage
  //         await AppLocalStorage.init(user.uid);

  //         // If the user's email is verified, navigate to the main NavigationMenu
  //         Get.offAll(() => const NavigationMenu());
  //       } else {
  //         // If the user's email is not verified, navigate to VerifyEmailScreen(email)
  //         Get.offAll(() => VerifyEmailScreen(email: getUserEmail));
  //       }
  //     } else {
  //       // User is ANONYMOUS (Guest), Navigate directly to the NavigationMenu
  //       // Anonymous users are automatically considered "ready" to browse.
  //       Get.offAll(() => const NavigationMenu());
  //     }
  //   } else {
  //     // show [OnBoardingScreen] to the user the firstTime only
  //     // Local Storage: User is new or Logged out! If new then write IsFirstTime Local storage variable = true.
  //     deviceStorage.writeIfNull('IsFirstTime', true);
  //     deviceStorage.read('IsFirstTime') != true
  //         ? Get.offAll(() => const LoginScreen())
  //         : Get.offAll(() => const OnBoardingScreen());
  //   }
  // }

  /// Function to show Relevant screen
  void screenRedirect() async {
    final user = _firebaseUser.value;

    // Check if navigation is ready
    if (Get.key.currentContext == null) {
      // If not ready, wait and try again
      Future.delayed(const Duration(milliseconds: 100), screenRedirect);
      return;
    }

    if (user != null) {
      // User is logged in
      if (!user.isAnonymous) {
        // Authenticated user
        if (user.emailVerified) {
          // Initialize user specific storage
          await AppLocalStorage.init(user.uid);
          Get.offAll(() => const NavigationMenu());
        } else {
          Get.offAll(() => VerifyEmailScreen(email: getUserEmail));
        }
      } else {
        // Anonymous user
        Get.offAll(() => const NavigationMenu());
      }
    } else {
      // User is not logged in - Check app flow
      deviceStorage.writeIfNull('IsFirstTime', true);

      final bool isFirstTime = deviceStorage.read('IsFirstTime') == true;
      final bool hasSelectedLanguage =
          deviceStorage.read('hasSelectedLanguage') == true;

      if (!hasSelectedLanguage) {
        // if (hasSelectedLanguage) {
        // Show Language Selection Screen first
        Get.offAll(() => const SelectLanguageScreen());
      } else if (isFirstTime) {
        // } else if (!isFirstTime) {
        // Show OnBoarding after language selection
        Get.offAll(() => const OnBoardingScreen());
      } else {
        // Go directly to Login
        Get.offAll(() => const LoginScreen());
      }
    }
  }

  /// [AnonymousAuthentication]-SignIn-Anonymously-----------------
  Future<UserCredential> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AppFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw AppFormatException();
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      // throw 'Something went wrong. Please try again.';
      throw txt.somethingWentWrong;
    }
  }

  /// [EmailAuthentication]-SignIn-----------------
  Future<UserCredential> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AppFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw AppFormatException();
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      // throw 'Something went wrong. Please try again.';
      throw txt.somethingWentWrong;
    }
  }

  /// [EmailAuthentication]-REGESTER---------------
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AppFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw AppFormatException();
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      // throw 'Something went wrong. Please try again.';
      throw txt.somethingWentWrong;
    }
  }

  /// [GoogleAuthentication]-GOOGLE---------------
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Initialize Google Sign In
      await GoogleSignIn.instance.initialize();

      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AppFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw AppFormatException();
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      AppLoggerHelper.error('Something went wrong: $e');
      return null;
    }
  }

  /// [ReAuthentication] - RE AUTHENTICATE USER
  Future<void> reAuthenticateWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Create a credential
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Re-Authenticate
      await _auth.currentUser?.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AppFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw AppFormatException();
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      // throw 'Something went wrong. Please try again.';
      throw txt.somethingWentWrong;
    }
  }

  /// [DeleteAccount] - DELETE USER ACCOUNT
  /// Remove user auth and Firestore account
  Future<void> deleteAccount() async {
    try {
      await UserRepository.instance.removeUserRecord(_auth.currentUser!.uid);
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw AppFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw AppFormatException();
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      // throw 'Something went wrong. Please try again.';
      throw txt.somethingWentWrong;
    }
  }

  /// [EmailAuthentication] - FORGET PASSWORD
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AppFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw AppFormatException();
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      // throw 'Something went wrong. Please try again.';
      throw txt.somethingWentWrong;
    }
  }

  /// [EmailVerification] - MAIL VEREFICATION
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AppFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw AppFormatException();
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      // throw 'Something went wrong. Please try again.';
      throw txt.somethingWentWrong;
    }
  }

  /// [LogoutUser] - Valid for any Authentication
  Future<void> logout() async {
    try {
      await GoogleSignIn.instance.signOut();
      await _auth.signOut();
      Get.offAll(() => const LoginScreen());
    } on FirebaseAuthException catch (e) {
      throw AppFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw AppFormatException();
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      // throw 'Something went wrong. Please try again.';
      throw txt.somethingWentWrong;
    }
  }
}
