import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reviews_app/features/review/models/category_model.dart';
import '../../../features/review/models/place_category_model.dart';
import '../../../localization/app_localizations.dart';
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
      // throw 'Something went wrong. Please try again';
        throw txt.somethingWentWrong;
    }
  }

  /// -- Get CategoryName By Id
  Future<String> getCategoryNameById(String categoryId) async {
    try {
      final doc = await _db.collection("Categories").doc(categoryId).get();

      if (doc.exists) {
        final category = CategoryModel.fromSnapshot(doc);
        return category.name;
      } else {
        // throw 'Category not found';
        throw txt.categoryNotFound;
      }
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      // throw 'Something went wrong. Please try again';
        throw txt.somethingWentWrong;
    }
  }

  /// Get Specific Category
  Future<CategoryModel> getSelectedCategory(String categoryId) async {
    try {
      final doc = await _db.collection("Categories").doc(categoryId).get();
      if (doc.exists) {
        return CategoryModel.fromSnapshot(doc);
      } else {
        return CategoryModel.empty();
      }
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      // throw 'Something went wrong. Please try again';
        throw txt.somethingWentWrong;
    }
  }

  /// -- Get Categories By List of Ids
  Future<List<CategoryModel>> getCategoriesByIds(
    List<String> categoryIds,
  ) async {
    try {
      if (categoryIds.isEmpty) return [];

      final snapshot = await _db
          .collection('Categories')
          .where(FieldPath.documentId, whereIn: categoryIds.take(10).toList())
          .get();

      return snapshot.docs
          .map((doc) => CategoryModel.fromSnapshot(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw AppFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw AppPlatformException(e.code).message;
    } catch (e) {
      // throw 'Something went wrong. Please try again';
        throw txt.somethingWentWrong;
    }
  }

  /// -- Create a new category document in the 'Categories' collection
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
      // throw 'Something went wrong. Please try again';
        throw txt.somethingWentWrong;
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
      // throw 'Something went wrong. Please try again';
        throw txt.somethingWentWrong;
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
      // throw 'Something went wrong. Please try again';
  throw txt.somethingWentWrong;
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
      // throw 'Something went wrong. Please try again.';
        throw txt.somethingWentWrong;
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
      // throw 'Something went wrong. Please try again';
        throw txt.somethingWentWrong;
    }
  }
}
