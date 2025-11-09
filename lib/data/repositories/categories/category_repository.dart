import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reviews_app/features/review/models/category_model.dart';
import '../../../features/review/models/place_category_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../../../utils/popups/loaders.dart';

class CategoryRepository extends GetxController {
  // Singleton instance of the CategoryRepository
  static CategoryRepository get instance => Get.find();

  // Firebase Firestore instance
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get all categories from the 'Categories' collection
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final snapshot = await _db.collection("Categories").get();

      final result = snapshot.docs
          .map((e) => CategoryModel.fromSnapshot(e))
          .toList();
      return result;
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Create a new category document in the 'Categories' collection
  Future<String> createCategory(CategoryModel category) async {
    try {
      final result = await _db.collection("Categories").add(category.toJson());
      return result.id;
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const AppFormatException();
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Update an existing category document in the 'Categories' collection
  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _db
          .collection("Categories")
          .doc(category.id)
          .update(category.toJson());
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const AppFormatException();
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Delete an existing category document from the 'Categories' collection
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _db.collection("Categories").doc(categoryId).delete();
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const AppFormatException();
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Upload Categories to the Cloud Firestore
  Future<void> uploadDummyData(List<CategoryModel> categories) async {
    try {
      // loop through each category
      for (var category in categories) {
        // Store category in firestore
        await _db
            .collection('Categories')
            .doc(category.id)
            .set(category.toJson());
        // Show success snackbar for the individual category
        AppLoaders.successSnackBar(
          title: 'Success!',
          message: 'Category ${category.id} uploaded successfully.',
        );
      }
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Upload Categories to the Cloud Firebase
  Future<void> uploadPlaceCategoryDummyData(
    List<PlaceCategoryModel> placeCategory,
  ) async {
    try {
      // Loop through each category
      for (var entry in placeCategory) {
        // Store Category in Firestore
        await _db.collection("PlaceCategory").doc().set(entry.toJson());

        // Show success snackbar for the individual place category
        AppLoaders.successSnackBar(
          title: 'Success!',
          message: 'Place category ${entry.categoryId} uploaded successfully.',
        );
      }
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
}
