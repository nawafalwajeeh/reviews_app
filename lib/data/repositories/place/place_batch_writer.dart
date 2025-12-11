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

  /// In PlaceBatchWriter class
  Future<void> updatePlace(PlaceModel place) async {
    final placeRef = _db.collection('Places').doc(place.id);
    final categoryTitle = await _getCategoryNameById(place.categoryId);

    // Get ALL image URLs from the PlaceModel (thumbnail + images)
    final List<String> allImageUrls = [];

    // Add thumbnail if it exists
    if (place.thumbnail.isNotEmpty) {
      allImageUrls.add(place.thumbnail);
    }

    // Add additional images if they exist
    if (place.images != null && place.images!.isNotEmpty) {
      allImageUrls.addAll(place.images!);
    }

    // 1. Update main place document
    _batch.update(placeRef, place.toJson());

    // Only update GalleryImages if there are images
    if (allImageUrls.isNotEmpty) {
      // 2. Delete existing gallery images
      final existingGalleryQuery = await _db
          .collection('GalleryImages')
          .where('PlaceId', isEqualTo: place.id)
          .get();

      for (var doc in existingGalleryQuery.docs) {
        _batch.delete(doc.reference);
      }

      // 3. Add updated images to GalleryImages collection
      for (var imageUrl in allImageUrls) {
        final galleryImage = GalleryImageModel(
          id: '',
          imageUrl: imageUrl,
          collectionId: place.categoryId,
          collectionTitle: categoryTitle,
          timestamp: DateTime.now(),
          placeId: place.id,
          placeName: place.title,
        );

        _batch.set(
          _db.collection('GalleryImages').doc(),
          galleryImage.toJson(),
        );
      }

      // 4. Update Collections (but you need to modify updateCollection to accept PlaceModel)
      // Option A: Call your existing updateCollection method
      await updateCollection(place);

      // OR Option B: Update Collections inline
      // final newPhotoUrl = allImageUrls.isNotEmpty ? allImageUrls.first : '';
      // final photoCountIncrement = allImageUrls.length;
      //
      // final collectionDocRef = _db.collection('Collections').doc(place.categoryId);
      // final batchUpdate = {
      //   'CollectionId': place.categoryId,
      //   'Title': categoryTitle,
      //   'ImageUrl': newPhotoUrl,
      //   'LastUpdated': FieldValue.serverTimestamp(),
      //   'PhotoCount': FieldValue.increment(photoCountIncrement),
      // };
      // _batch.set(collectionDocRef, batchUpdate, SetOptions(merge: true));
    }

    // 5. Commit batch
    await _batch.commit();
  }

  /// Update GalleryImages collection for an existing place
  void updateGalleryImages(PlaceModel place, List<String> allImageUrls) async {
    final galleryCollection = _db.collection('GalleryImages');
    final categoryTitle = await _getCategoryNameById(place.categoryId);

    // 1. Delete existing gallery images for this place
    final existingImages = await galleryCollection
        .where('PlaceId', isEqualTo: place.id)
        .get();

    for (var doc in existingImages.docs) {
      _batch.delete(doc.reference);
    }

    // 2. Add all new images to GalleryImages collection
    for (var imageUrl in allImageUrls) {
      final galleryImage = GalleryImageModel(
        id: '',
        imageUrl: imageUrl,
        collectionId: place.categoryId,
        collectionTitle: categoryTitle.toString(),
        timestamp: DateTime.now(),
        placeId: place.id,
        placeName: place.title,
      );

      _batch.set(galleryCollection.doc(), galleryImage.toJson());
    }
  }

  /// Helper function to update/create the Collection document.
  /// Adds operation to the internal shared batch (`_batch`).
  Future<void> updateCollection(PlaceModel place) async {
    // final newPhotoUrl = place.images!.first;
    // final photoCountIncrement = place.images!.length;

    // Get all image URLs from place model
    final List<String> allImageUrls = [];
    if (place.thumbnail.isNotEmpty) allImageUrls.add(place.thumbnail);
    if (place.images != null) allImageUrls.addAll(place.images!);

    // Use first image as the collection image
    final newPhotoUrl = allImageUrls.isNotEmpty ? allImageUrls.first : '';
    final photoCountIncrement = allImageUrls.length;

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
