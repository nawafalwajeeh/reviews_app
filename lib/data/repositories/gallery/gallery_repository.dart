import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:reviews_app/features/review/models/collection_item.dart';
import 'package:reviews_app/utils/exceptions/firebase_exceptions.dart';
import 'package:reviews_app/utils/exceptions/platform_exceptions.dart';

import '../../../features/review/models/gallery_image_model.dart';

class GalleryRepository extends GetxController {
  static GalleryRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  /// --- Collections fetching logic ---
  Future<List<CollectionItem>> getAllCollections() async {
    try {
      final snapshot = await _db.collection('Collections').get();
      final list = snapshot.docs
          .map((document) => CollectionItem.fromSnapshot(document))
          .toList();
      return list;
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong while fetching Collections. Please try again.';
    }
  }

  /// --- Image fetching logic (All Photos) ---
  Future<List<GalleryImageModel>> getAllGalleryImages() async {
    try {
      // Query to fetch all images, maybe ordered by timestamp for "Recent" logic
      final snapshot = await _db
          .collection('GalleryImages')
          .orderBy('Timestamp', descending: true)
          .get();

      final list = snapshot.docs
          .map((document) => GalleryImageModel.fromSnapshot(document))
          .toList();
      return list;
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong while fetching all Gallery Photos. Please try again.';
    }
  }

  /// --- Image fetching logic (Recent Photos - used in RecentPhotosSection) ---
  Future<List<GalleryImageModel>> getRecentGalleryImages(
      {int limit = 5}) async {
    try {
      final snapshot = await _db
          .collection('GalleryImages')
          .orderBy('Timestamp', descending: true)
          .limit(limit)
          .get();

      final list = snapshot.docs
          .map((document) => GalleryImageModel.fromSnapshot(document))
          .toList();
      return list;
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong while fetching Recent Photos. Please try again.';
    }
  }
}