import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reviews_app/data/repositories/authentication/authentication_repository.dart';
import 'package:reviews_app/features/personalization/models/user_model.dart';
import 'package:reviews_app/utils/exceptions/firebase_auth_exceptions.dart';
import 'package:reviews_app/utils/exceptions/firebase_exceptions.dart';
import 'package:reviews_app/utils/exceptions/format_exceptions.dart';
import 'package:reviews_app/utils/exceptions/platform_exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../localization/app_localizations.dart';

/// Repository class for user-related operations.
class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Function to save user data to Firestore.
  Future<void> saveUserRecord(UserModel user) async {
    try {
      await _db.collection('Users').doc(user.id).set(user.toJson());
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

  /// Function to fetch user details based on user ID.
  Future<UserModel> fetchUserDetails() async {
    try {
      final uid = AuthenticationRepository.instance.authUser?.uid;

      //  Explicitly check if the user is authenticated (UID is available)
      if (uid == null || uid.isEmpty) {
        return UserModel.empty();
      }

      final documentSnapshot = await _db.collection('Users').doc(uid).get();
      if (documentSnapshot.exists) {
        return UserModel.fromSnapshot(documentSnapshot);
      } else {
        return UserModel.empty();
      }
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

  /// Function to update user deta in Firestore.
  Future<void> updateUserDetails(UserModel updatedUser) async {
    try {
      await _db
          .collection('Users')
          .doc(updatedUser.id)
          .update(updatedUser.toJson());
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

  /// Function to update any field in specific Users Collection.
  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      await _db
          .collection('Users')
          .doc(AuthenticationRepository.instance.authUser?.uid)
          .update(json);
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

  /// Function to update any field in specific Users Collection.
  Future<void> removeUserRecord(String userId) async {
    try {
      await _db.collection('Users').doc(userId).delete();
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

  /// Function to fetch all User IDs from Firestore
  Future<List<String>> getAllUserIds() async {
    try {
      // fetch all documents from the 'Users' collection
      final querySnapshot = await _db.collection('Users').get();

      final List<String> userIds = querySnapshot.docs
          .map((document) => document.id)
          .toList();
      return userIds;
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

  /// Upload any Image
  Future<String> uploadImage(
    String path,
    XFile image, {
    String bucketName = 'Images',
  }) async {
    try {
      // use firebase storage
      //---------------------------------
      // final ref = FirebaseStorage.instance.ref(path).child(image.name);
      // await ref.putFile(File(image.path));
      // final url = await ref.getDownloadURL();
      // return url;
      //---------------------------------

      // use supaBase Storage
      // 1. Read image bytes
      final bytes = await image.readAsBytes();
      final fileName = '$path/${image.name}';

      // 2. Upload the file to Supabase Storage
      final String() = await Supabase.instance.client.storage
          .from(bucketName)
          .uploadBinary(fileName, bytes);

      // If uploadBinary throws, it will be caught by catch below.
      // uploadedPath is the path of the uploaded file.

      // 3. Get the public URL of the uploaded image
      final url = Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(fileName);

      return url;
    } on StorageException catch (e) {
      // Supabase Storage-specific error handling.
      throw e.message;
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
