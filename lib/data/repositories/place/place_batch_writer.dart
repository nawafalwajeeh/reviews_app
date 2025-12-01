import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:reviews_app/features/review/models/place_model.dart';

import '../../../features/review/models/gallery_image_model.dart';
import '../../../localization/app_localizations.dart';
import '../categories/category_repository.dart';

class PlaceBatchWriter {
  final FirebaseFirestore _db;
  final WriteBatch _batch;

  PlaceBatchWriter({required FirebaseFirestore db})
    : _db = db,
      _batch = db.batch();

  /// Helper function to save individual images to the GalleryImages collection.
  /// Adds operations to the internal shared batch (`_batch`).
  ///
  Future<String> _getCategoryNameById(String categoryId) async {
    try {
      final repository = Get.put(CategoryRepository());
      final categoryTitle = await repository.getCategoryNameById(categoryId);
      return categoryTitle;
    } catch (e) {
      // throw 'Failed to fetch category name: ${e.toString()}';
        throw txt.somethingWentWrong;
    }
  }

  void addImagesToGallery(PlaceModel place) {
    final galleryCollection = _db.collection('GalleryImages');
    final categoryTitle = _getCategoryNameById(place.categoryId);
    for (var imageUrl in place.images!) {
      final galleryImage = GalleryImageModel(
        id: '',
        imageUrl: imageUrl,
        collectionId: place.categoryId,
        collectionTitle: categoryTitle.toString(),
        timestamp: DateTime.now(),
        placeId: place.id, // Uses the Firestore-generated ID
        placeName: place.title,
      );

      // Add operation to the shared batch
      _batch.set(galleryCollection.doc(), galleryImage.toJson());
    }
  }

  /// Helper function to update/create the Collection document.
  /// Adds operation to the internal shared batch (`_batch`).
  Future<void> updateCollection(PlaceModel place) async {
    final newPhotoUrl = place.images!.first;
    final photoCountIncrement = place.images!.length;

    final repository = Get.put(CategoryRepository());

    // final collectionId = categoryTitle;
    final collectionId = place.categoryId;
    final categoryTitle = await repository.getCategoryNameById(
      place.categoryId,
    );
    //     .trim()
    //     .replaceAll(' ', '_')
    //     .toLowerCase();
    final collectionDocRef = _db.collection('Collections').doc(collectionId);

    final batchUpdate = {
      'CollectionId': place.categoryId,
      'Title': categoryTitle,
      'ImageUrl': newPhotoUrl,
      'LastUpdated': FieldValue.serverTimestamp(),
      'PhotoCount': FieldValue.increment(photoCountIncrement),
    };

    // Add the collection update operation to the shared batch
    _batch.set(collectionDocRef, batchUpdate, SetOptions(merge: true));
  }

  /// Commits all pending operations in the batch atomically.
  Future<void> commit() => _batch.commit();
}
