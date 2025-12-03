import 'package:get/get.dart';
import 'package:reviews_app/features/review/controllers/category_controller.dart';
import 'package:reviews_app/features/review/models/collection_item.dart';
import 'package:reviews_app/features/review/models/gallery_image_model.dart';
import 'package:reviews_app/features/review/models/featured_images_model.dart'; // NEW
import 'package:reviews_app/utils/popups/loaders.dart';

import '../../../data/repositories/categories/category_repository.dart';
import '../../../data/repositories/gallery/gallery_repository.dart';
import '../../../data/repositories/place/place_repository.dart';
import '../../../localization/app_localizations.dart';
import '../screens/gallery/collection_photos.dart';

class GalleryController extends GetxController {
  static GalleryController get instance => Get.find();

  // Repositories
  final galleryRepository = Get.put(GalleryRepository());
  // Assuming these repositories are already implemented using your Firestore logic
  final placeRepository = PlaceRepository.instance;
  final categoryRepository = Get.put(CategoryRepository());
  // Observables for the list of collections and loading state
  final allCollections = <CollectionItem>[].obs;
  final isLoading = false.obs;

  // State for creating a new collection
  final newCollectionTitle = ''.obs;
  final newCollectionImageUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Pre-fetch collections when the controller initializes
    getAllCollections();
  }

  /// Fetches all collections for the grid view
  Future<List<CollectionItem>> getAllCollections() async {
    try {
      final collections = await galleryRepository.getAllCollections();
      return collections;
    } catch (e) {
      // AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      AppLoaders.errorSnackBar(title: txt.ohSnap, message: e.toString());
      return [];
    }
  }

  /// Fetches all gallery images for the main grid
  Future<List<GalleryImageModel>> getAllGalleryImages() async {
    try {
      final images = await galleryRepository.getAllGalleryImages();
      return images;
    } catch (e) {
      // AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      AppLoaders.errorSnackBar(title: txt.ohSnap, message: e.toString());
      return [];
    }
  }

  Future<List<GalleryImageModel>> getPhotosByCollectionId(
    String collectionId,
  ) async {
    try {
      final photos = await galleryRepository.getPhotosByCollectionId(
        collectionId,
      );
      return photos;
    } catch (e) {
      // AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      AppLoaders.errorSnackBar(title: txt.ohSnap, message: e.toString());
      return [];
    }
  }

  Future<void> getCollectionNameById(String collectionId) async {
    try {
      final collectionName = await CategoryRepository.instance
          .getCategoryNameById(collectionId);
      newCollectionTitle.value = collectionName;
    } catch (e) {
      // AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      AppLoaders.errorSnackBar(title: txt.ohSnap, message: e.toString());
    }
  }

  /// -- Get recent places
  Future<List<FeaturedImagesModel>> getRecentFeaturedImages() async {
    try {
      // 1. Fetch recent places (e.g., top 5)
      final recentPlaces = await galleryRepository.getRecentGalleryImages(
        limit: 5,
      );

      if (recentPlaces.isEmpty) return [];

      // 2. Extract unique category IDs needed for lookup
      recentPlaces.map((place) => place.collectionId).toSet().toList();

      // 3. Fetch all necessary categories
      final categories = await categoryRepository.getCategoriesByIds(
        recentPlaces.map((p) => p.collectionId).toSet().toList(),
      );
      final categoryMap = {for (var cat in categories) cat.id: cat.name};

      // 4. Transform PlaceModel data into the required FeaturedImagesModel
      final featuredImages = recentPlaces.map((place) {
        // Assume PlaceModel has a single main 'imageUrl' or you take the first from an image list
        final _ = categoryMap[place.collectionId] ?? txt.unknownCategory;
        final imageUrl = place.imageUrl.isNotEmpty
            ? place.imageUrl
            : 'https://placehold.co/500x300/CCCCCC/000000?text=No+Image';

        final localizedCategoryName = CategoryController.instance
            .getCachedLocalizedCategoryName(place.collectionId, Get.context!);

        return FeaturedImagesModel(
          id: place.id,
          title: place.placeName, // Place Name for Title
          // subtitle: categoryName,
          subtitle: localizedCategoryName, // Category Name for Subtitle
          imageUrl: imageUrl.toString(),
        );
      }).toList();

      return featuredImages;
    } catch (e) {
      AppLoaders.errorSnackBar(
        // title: 'Oh Snap!',
        title: txt.ohSnap,
        // message: 'Failed to load recent featured images: ${e.toString()}',
        message: txt.failedToLoadRecentFeaturedImages(e.toString()),
      );
      return [];
    }
  }

  void navigateToPhotos(String collectionId) {
    Get.to(() => CollectionPhotosScreen(collectionId: collectionId));
  }

  /// Refreshes the collections list (used after creation/update)
  Future<void> refreshCollections() async {
    await getAllCollections();
  }
}
