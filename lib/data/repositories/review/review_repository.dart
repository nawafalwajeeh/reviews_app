import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:reviews_app/features/review/models/review_model.dart';
import 'package:reviews_app/utils/exceptions/firebase_exceptions.dart';
import 'package:reviews_app/utils/exceptions/format_exceptions.dart';

import '../../../features/review/models/reply_model.dart';
import '../authentication/authentication_repository.dart';

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
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Updates an existing review document in the 'Reviews' collection.
  Future<void> updateReview(ReviewModel review) async {
    try {
      if (review.id.isEmpty) {
        throw 'Review ID is missing. Cannot update.';
      }
      await _db
          .collection(_collectionName)
          .doc(review.id)
          .update(review.toJson());
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const AppFormatException();
    } catch (e) {
      throw 'Something went wrong while updating. Please try again.';
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
          .map((snapshot) => snapshot.docs
              .map((doc) => ReviewModel.fromSnapshot(doc))
              .toList());
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const AppFormatException();
    } catch (e) {
      print('Error streaming reviews: $e');
      throw 'Could not stream reviews. Check your network connection.';
    }
  }

  // --- Utility Queries (for pre-filling and checking review status) ---

  /// Fetches the existing review by a specific user for a specific place.
  Future<ReviewModel?> getExistingReview(
      String userId, String placeId) async {
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

  /// Checks if a user has already reviewed a specific place (legacy check, usually simplified by getExistingReview).
  Future<bool> hasUserReviewedPlace(String userId, String placeId) async {
    final review = await getExistingReview(userId, placeId);
    return review != null;
  }
}
//--------------------------
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
// import 'package:reviews_app/features/review/models/review_model.dart';
// import 'package:reviews_app/utils/exceptions/firebase_exceptions.dart';
// import 'package:reviews_app/utils/exceptions/format_exceptions.dart';

// /// Repository for managing all review-related data operations.
// class ReviewRepository extends GetxController {
//   static ReviewRepository get instance => Get.find();

//   final _db = FirebaseFirestore.instance;
//   final String _collectionName = 'Reviews';

//   /// Adds a new review document to the 'Reviews' collection.
//   Future<void> addReview(ReviewModel review) async {
//     try {
//       // Add the review and let Firestore generate the ID
//       await _db.collection(_collectionName).add(review.toJson());
//     } on FirebaseException catch (e) {
//       throw AppFirebaseException(e.code).message;
//     } on FormatException catch (_) {
//       throw const AppFormatException();
//     } catch (e) {
//       throw 'Something went wrong. Please try again.';
//     }
//   }

//   /// Retrieves a stream of reviews for a specific place, ordered by timestamp.
//   Stream<List<ReviewModel>> streamReviewsForPlace(String placeId) {
//     try {
//       return _db
//           .collection(_collectionName)
//           .where('placeId', isEqualTo: placeId)
//           .orderBy('timestamp', descending: true)
//           .snapshots()
//           .map(
//             (snapshot) => snapshot.docs
//                 .map((doc) => ReviewModel.fromSnapshot(doc))
//                 .toList(),
//           );
//     } on FirebaseException catch (e) {
//       throw AppFirebaseException(e.code).message;
//     } on FormatException catch (_) {
//       throw const AppFormatException();
//     } catch (e) {
//       // In a real app, you might use a logger here instead of throwing a generic error
//       print('Error streaming reviews: $e');
//       throw 'Could not stream reviews. Check your network connection.';
//     }
//   }

//   // --- Utility Queries (for analytics or detailed checks) ---

//   /// Checks if a user has already reviewed a specific place.
//   Future<bool> hasUserReviewedPlace(String userId, String placeId) async {
//     try {
//       final querySnapshot = await _db
//           .collection(_collectionName)
//           .where('userId', isEqualTo: userId)
//           .where('placeId', isEqualTo: placeId)
//           .limit(1)
//           .get();

//       return querySnapshot.docs.isNotEmpty;
//     } catch (e) {
//       // Log error but default to allowing review submission if query fails
//       print('Error checking existing review: $e');
//       return false;
//     }
//   }
// }
