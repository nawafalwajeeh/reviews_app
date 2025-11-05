// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reviews_app/data/repositories/authentication/authentication_repository.dart';
import 'package:reviews_app/features/review/models/category_model.dart';
import 'package:reviews_app/features/review/models/place_category_model.dart';
import 'package:reviews_app/features/review/models/place_model.dart';
import 'package:reviews_app/utils/exceptions/firebase_auth_exceptions.dart';
import 'package:reviews_app/utils/exceptions/format_exceptions.dart';
import 'package:reviews_app/utils/exceptions/platform_exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../utils/exceptions/firebase_exceptions.dart';

class PlaceRepository extends GetxController {
  static PlaceRepository get instance => Get.find();

  /// Variables
  final _db = FirebaseFirestore.instance;

  // get the current userId
  String get getCurrentUserId => AuthenticationRepository.instance.getUserID;

  /// -- Get Limited Featured Places
  Future<List<PlaceModel>> getFeaturedPlaces({int limit = 4}) async {
    try {
      final snapshot = await _db
          .collection('Places')
          .where('IsFeatured', isEqualTo: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => PlaceModel.fromSnapshot(doc)).toList();
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// -- Get All Featured Places
  Future<List<PlaceModel>> getAllFeaturedPlaces() async {
    try {
      final snapshot = await _db
          .collection('Places')
          .where('IsFeatured', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((querySnapshot) => PlaceModel.fromSnapshot(querySnapshot))
          .toList();
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// -- Get Places by Category
  Future<List<PlaceModel>> getPlacesByCategory(String categoryId) async {
    try {
      final snapshot = await _db
          .collection('Places')
          .where('CategoryId', isEqualTo: categoryId)
          .get();
      return snapshot.docs
          .map((querySnapshot) => PlaceModel.fromSnapshot(querySnapshot))
          .toList();
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Get Places based on the Query
  Future<List<PlaceModel>> fetchPlacesByQuery(Query query) async {
    try {
      final querySnapshot = await query.get();
      final List<PlaceModel> placeList = querySnapshot.docs
          .map((doc) => PlaceModel.fromQuerySnapshot(doc))
          .toList();
      return placeList;
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// -- Get Favorite Places based on a list of place IDs.
  Future<List<PlaceModel>> getFavoritePlaces(List<String> placeIds) async {
    try {
      final snapshot = await _db
          .collection('Places')
          .where(FieldPath.documentId, whereIn: placeIds)
          .get();

      return snapshot.docs
          .map((querySnapshot) => PlaceModel.fromSnapshot(querySnapshot))
          .toList();
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Fetches products for a specific category.
  /// If the limit is -1, retrieves all products for the category;
  ///  otherwise, limits the result based on the provided limit.
  /// Returns a list of [PlaceModel] objects.
  Future<List<PlaceModel>> getPlacesForCategory(
    String categoryId, {
    int limit = 4,
  }) async {
    try {
      // Query to get all documnets where placeId matches the provided categoryId & Fetch
      // limited or unlimited based on the limit parameter
      QuerySnapshot placeCategoryQuery = limit == -1
          ? await _db
                .collection('PlaceCategory')
                .where('categoryId', isEqualTo: categoryId)
                .get()
          : await _db
                .collection('PlaceCategory')
                .where('categoryId', isEqualTo: categoryId)
                .limit(limit)
                .get();

      // Extract placeIds from the documents
      List<String> placeIds = placeCategoryQuery.docs
          .map((doc) => doc['placeId'] as String)
          .toList();

      // Query to get all documents where the placeId is in the list of placeIds
      // FieldPath.documentId to query documents in Collection
      final placesQuery = await _db
          .collection('Places')
          .where(FieldPath.documentId, whereIn: placeIds)
          .get();

      // Extract relevant data from the documents
      List<PlaceModel> places = placesQuery.docs
          .map((doc) => PlaceModel.fromSnapshot(doc))
          .toList();
      return places;
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// -- Create new place
  Future<String> createPlace(PlaceModel place) async {
    try {
      // get the userId
      final userId = AuthenticationRepository.instance.getUserID;
      // get the place data
      Map<String, dynamic> data = place.toJson();

      // set the userId to UserId field in the model
      data['UserId'] = userId;
      // add the data to the database
      final result = await _db.collection('Places').add(data);
      return result.id;
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const AppFormatException();
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// -- Create new Place Category
  Future<String> createPlaceCategory(CategoryModel placeCategory) async {
    try {
      final userId = getCurrentUserId;

      Map<String, dynamic> data = placeCategory.toJson();
      data['UserId'] = userId;

      final result = await _db.collection('PlaceCategory').add(data);
      return result.id;
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const AppFormatException();
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// -- Update place.
  Future<void> updatePlace(PlaceModel place) async {
    try {
      await _db.collection('Places').doc(place.id).update(place.toJson());
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const AppFormatException();
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Update Place Instance
  Future<void> updatePlaceSpecificValue(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.collection('Places').doc(id).update(data);
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const AppFormatException();
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// -- Get Places Categories
  Future<List<PlaceCategoryModel>> getPlaceCategories(String placeId) async {
    try {
      final snapshot = await _db
          .collection('PlaceCategory')
          .where('placeId', isEqualTo: placeId)
          .get();
      return snapshot.docs
          .map(
            (querySnapshot) => PlaceCategoryModel.fromSnapshot(querySnapshot),
          )
          .toList();
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const AppFormatException();
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// -- Remove Place category
  Future<void> removePlaceCategory(String placeId, String categoryId) async {
    try {
      final result = await _db
          .collection('PlaceCategory')
          .where('placeId', isEqualTo: placeId)
          .get();
      for (final doc in result.docs) {
        await doc.reference.delete();
      }
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const AppFormatException();
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// -- Delete Place
  Future<void> deletePlace(PlaceModel place) async {
    try {
      // delete all data at once from Firebase firestore
      await _db.runTransaction((transaction) async {
        final placeRef = _db.collection('Places').doc(place.id);
        final placeSnap = await transaction.get(placeRef);

        if (!placeSnap.exists) {
          throw Exception('Place not found');
        }

        // Fetch PlaceCategories
        final placeCategoriesSnapshot = await _db
            .collection('PlaceCategory')
            .where('placeId', isEqualTo: place.id)
            .get();
        final placeCategories = placeCategoriesSnapshot.docs
            .map((e) => PlaceCategoryModel.fromSnapshot(e))
            .toList();

        if (placeCategories.isNotEmpty) {
          for (var placeCategory in placeCategories) {
            transaction.delete(
              _db.collection('PlaceCategory').doc(placeCategory.id),
            );
          }
        }

        transaction.delete(placeRef);
      });
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const AppFormatException();
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

/// -- Upload Image to Storage and Get URL --
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
      throw 'Something went wrong. Please try again.';
    }
  }
}
