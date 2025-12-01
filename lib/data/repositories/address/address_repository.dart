import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:reviews_app/data/repositories/authentication/authentication_repository.dart';
import 'package:reviews_app/features/personalization/models/address_model.dart';
import 'package:reviews_app/utils/exceptions/firebase_exceptions.dart';
import 'package:reviews_app/utils/exceptions/format_exceptions.dart'
    show AppFormatException;
import 'package:reviews_app/utils/exceptions/platform_exceptions.dart';

import '../../../localization/app_localizations.dart';

class AddressRepository extends GetxController {
  static AddressRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  /// fetch all user specific addresses
  Future<List<AddressModel>> fetchUserAddresses() async {
    try {
      final userId = AuthenticationRepository.instance.authUser!.uid;
      if (userId.isEmpty) {
        // throw 'Unable to find user information. Try again in few minutes';
        throw txt.somethingWentWrong;
      }

      final result = await _db
          .collection('Users')
          .doc(userId)
          .collection('Addresses')
          .get();
      return result.docs
          .map(
            (documentSnapshot) =>
                AddressModel.fromDocumentSnapshot(documentSnapshot),
          )
          .toList();
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw AppFormatException();
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      // throw 'Something went wrong when fetching address information. Please try again later.';
      throw txt.somethingWentWrong;
    }
  }

  /// Clear the selected field for all addresses
  Future<void> updateSelectedField(String addressId, bool selected) async {
    try {
      final userId = AuthenticationRepository.instance.authUser!.uid;
      await _db
          .collection('Users')
          .doc(userId)
          .collection('Addresses')
          .doc(addressId)
          .update({'SelectedAddress': selected});
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw AppFormatException();
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      // throw 'Unable to update your address selection. Try again later';
      throw txt.somethingWentWrong;
    }
  }

  /// Add new user address
  Future<String> addAddress(AddressModel address) async {
    try {
      final userId = AuthenticationRepository.instance.authUser!.uid;
      final currentAddress = await _db
          .collection('Users')
          .doc(userId)
          .collection('Addresses')
          .add(address.toJson());

      return currentAddress.id;
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw AppFormatException();
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      // throw 'Something went wrong while saving address information. Please try again later.';
      throw txt.somethingWentWrong;
    }
  }
}
