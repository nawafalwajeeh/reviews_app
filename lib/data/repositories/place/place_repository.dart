// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:reviews_app/data/repositories/authentication/authentication_repository.dart';
import 'package:reviews_app/features/review/models/place_category_model.dart';
import 'package:reviews_app/features/review/models/place_model.dart';
import 'package:reviews_app/utils/exceptions/format_exceptions.dart';
import 'package:reviews_app/utils/exceptions/platform_exceptions.dart';

import '../../../utils/exceptions/firebase_exceptions.dart';
import 'place_batch_writer.dart';

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
      final placeIds = placeCategoryQuery.docs
          .map((doc) => PlaceCategoryModel.fromSnapshot(doc).placeId)
          .toList();
      // Query to get all documents where the placeId is in the list of placeIds
      // FieldPath.documentId to query documents in Collection
      final placesQuery = await _db
          .collection('Places')
          // .where(FieldPath.documentId, whereIn: placeIds)
          .where('Id', whereIn: placeIds)
          .get();

      debugPrint(
        'Fetched ${placesQuery.docs.length} places for category $categoryId',
      );
      debugPrint('placeIds: $placeIds');

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
    String placeId = '';

    try {
      // Write the main document first to get the unique Firestore ID
      final data = await _db.collection('Places').add(place.toJson());
      placeId = data.id;

      // Update the place model with the generated ID for batch use
      final placeWithId = place.copyWith(id: placeId);

      // Instantiate the batch writer, which initializes the WriteBatch internally
      final batchWriter = PlaceBatchWriter(db: _db);

      // Call the writer's methods to add operations to the internal batch.
      if (placeWithId.images != null && placeWithId.images!.isNotEmpty) {
        batchWriter.addImagesToGallery(placeWithId);

        await batchWriter.updateCollection(placeWithId);
      }

      // 4. Commit the internal batch atomically.
      await batchWriter.commit();

      // return data.id;
      return placeId;
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const AppFormatException();
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    } finally {}
  }

  /// -- Create new Place Category
  Future<String> createPlaceCategory(PlaceCategoryModel placeCategory) async {
    try {
      final data = await _db
          .collection('PlaceCategory')
          .add(placeCategory.toJson());
      return data.id;
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

  /// Updates the total review count and calculates the new average rating for a place.
  Future<void> updatePlaceRatingStatistics(
    String placeId,
    double newRating,
  ) async {
    try {
      final placeRef = _db.collection('Places').doc(placeId);

      await _db.runTransaction((transaction) async {
        final placeSnapshot = await transaction.get(placeRef);

        if (!placeSnapshot.exists) {
          throw Exception('Place not found for rating update.');
        }

        final data = placeSnapshot.data()!;

        // Get current statistics (using safe access with default values)
        final currentReviewCount = (data['ReviewCount'] ?? 0).toInt();
        // Assuming 'AverageRating' is stored as a double
        final currentAverageRating = (data['Rating'] ?? 0.0).toDouble();

        // 1. Calculate the total sum of all previous ratings
        final totalRatingSum = currentAverageRating * currentReviewCount;

        // 2. Calculate new count and new average
        final newReviewCount = currentReviewCount + 1;
        final newAverageRating = (totalRatingSum + newRating) / newReviewCount;

        // 3. Update the document atomically
        transaction.update(placeRef, {
          'ReviewCount': newReviewCount,
          // Store average rating rounded to 2 decimal places for cleanliness
          'Rating': double.parse(newAverageRating.toStringAsFixed(2)),
        });
      });
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong while updating place rating. Please try again.';
    }
  }
}
