import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:reviews_app/features/review/models/review_model.dart';
import 'package:reviews_app/utils/exceptions/firebase_exceptions.dart';
import 'package:reviews_app/utils/exceptions/format_exceptions.dart';

import '../../../localization/app_localizations.dart';

/// Repository for managing all review-related data operations.
class ReviewRepository extends GetxController {
  static ReviewRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final String _collectionName = 'Reviews';

  /// --- CRUD Operations ---

  /// Adds a new review document to the 'Reviews' collection.
  Future<void> addReview(ReviewModel review) async {
    try {
      // Add the review and let Firestore generate the ID
      await _db.collection(_collectionName).add(review.toJson());
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const AppFormatException();
    } catch (e) {
      // throw 'Something went wrong. Please try again.';
        throw txt.somethingWentWrong;
    }
  }

  /// Updates an existing review document in the 'Reviews' collection.
  Future<void> updateReview(ReviewModel review) async {
    try {
      if (review.id.isEmpty) {
        throw 'Review ID is missing. Cannot update.';
      }

      // First get the old review to know the previous rating
      final oldReviewDoc = await _db
          .collection(_collectionName)
          .doc(review.id)
          .get();
      final oldRating = (oldReviewDoc.data()?['rating'] as num?)?.toInt();
      final newRating = review.rating.round();

      // Update the review
      await _db
          .collection(_collectionName)
          .doc(review.id)
          .update(review.toJson());

      // If rating changed, update distribution
      if (oldRating != null && oldRating != newRating) {
        await removeFromRatingDistribution(review.placeId, oldRating);
        await updateRatingDistribution(review.placeId, newRating);
      }
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const AppFormatException();
    } catch (e) {
      // throw 'Something went wrong while updating. Please try again.';
        throw txt.somethingWentWrong;
    }
  }

  /// Deletes a review and updates rating distribution
  Future<void> deleteReview(String reviewId) async {
    try {
      // First get the review to know the rating
      final reviewDoc = await _db
          .collection(_collectionName)
          .doc(reviewId)
          .get();
      if (!reviewDoc.exists) return;

      final reviewData = reviewDoc.data();
      final placeId = reviewData?['placeId'];
      final rating = (reviewData?['rating'] as num?)?.toInt();

      // Delete the review
      await _db.collection(_collectionName).doc(reviewId).delete();

      // Remove from rating distribution
      if (placeId != null && rating != null) {
        await removeFromRatingDistribution(placeId, rating);
      }
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const AppFormatException();
    } catch (e) {
      // throw 'Failed to delete review: $e';
        throw txt.somethingWentWrong;
    }
  }

  /// Retrieves a stream of reviews for a specific place, ordered by timestamp.
  Stream<List<ReviewModel>> streamReviewsForPlace(String placeId) {
    try {
      return _db
          .collection(_collectionName)
          .where('placeId', isEqualTo: placeId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => ReviewModel.fromSnapshot(doc))
                .toList(),
          );
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const AppFormatException();
    } catch (e) {
      print('Error streaming reviews: $e');
      // throw 'Could not stream reviews. Check your network connection.';
        throw txt.somethingWentWrong;
    }
  }

  // --- Rating Distribution Methods ---

  /// Updates rating distribution when a new review is added
  Future<void> updateRatingDistribution(String placeId, int newRating) async {
    try {
      final placeRef = _db.collection('Places').doc(placeId);

      await _db.runTransaction((transaction) async {
        final placeDoc = await transaction.get(placeRef);
        if (!placeDoc.exists) return;

        final currentDistribution =
            placeDoc.data()?['RatingDistribution'] ??
            {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0};

        // Convert to mutable map and increment the count for this rating
        final updatedDistribution = Map<String, int>.from(currentDistribution);
        final ratingKey = newRating.toString();
        updatedDistribution[ratingKey] =
            (updatedDistribution[ratingKey] ?? 0) + 1;

        transaction.update(placeRef, {
          'RatingDistribution': updatedDistribution,
        });
      });
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } catch (e) {
      // throw 'Failed to update rating distribution: $e';
        throw txt.somethingWentWrong;
    }
  }

  /// Removes a rating from the distribution when a review is deleted or updated
  Future<void> removeFromRatingDistribution(
    String placeId,
    int oldRating,
  ) async {
    try {
      final placeRef = _db.collection('Places').doc(placeId);

      await _db.runTransaction((transaction) async {
        final placeDoc = await transaction.get(placeRef);
        if (!placeDoc.exists) return;

        final currentDistribution =
            placeDoc.data()?['RatingDistribution'] ??
            {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0};

        // Convert to mutable map and decrement the count for this rating
        final updatedDistribution = Map<String, int>.from(currentDistribution);
        final ratingKey = oldRating.toString();
        final currentCount = updatedDistribution[ratingKey] ?? 0;
        updatedDistribution[ratingKey] = currentCount > 0
            ? currentCount - 1
            : 0;

        transaction.update(placeRef, {
          'RatingDistribution': updatedDistribution,
        });
      });
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } catch (e) {
      // throw 'Failed to remove from rating distribution: $e';
        throw txt.somethingWentWrong;
    }
  }

  // --- Utility Queries ---

  /// Fetches the existing review by a specific user for a specific place.
  Future<ReviewModel?> getExistingReview(String userId, String placeId) async {
    try {
      final querySnapshot = await _db
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('placeId', isEqualTo: placeId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ReviewModel.fromSnapshot(querySnapshot.docs.first);
      }
      return null;
    } on FirebaseException catch (e) {
      print('Firebase Error fetching existing review: $e');
      return null;
    } catch (e) {
      print('General Error fetching existing review: $e');
      return null;
    }
  }

  /// Checks if a user has already reviewed a specific place
  Future<bool> hasUserReviewedPlace(String userId, String placeId) async {
    final review = await getExistingReview(userId, placeId);
    return review != null;
  }

  /// Gets rating distribution for a place
  Future<Map<String, int>> getRatingDistribution(String placeId) async {
    try {
      final placeDoc = await _db.collection('Places').doc(placeId).get();
      if (!placeDoc.exists) {
        return {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0};
      }

      final distribution =
          placeDoc.data()?['RatingDistribution'] ??
          {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0};

      return Map<String, int>.from(distribution);
    } catch (e) {
      print('Error getting rating distribution: $e');
      return {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0};
    }
  }
}
