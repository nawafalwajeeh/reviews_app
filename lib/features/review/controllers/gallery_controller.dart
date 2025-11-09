import 'package:get/get.dart';
import 'package:reviews_app/features/review/models/collection_item.dart';
import 'package:reviews_app/features/review/models/gallery_image_model.dart';
import 'package:reviews_app/features/review/models/featured_images_model.dart'; // NEW
import 'package:reviews_app/utils/popups/loaders.dart';

import '../../../data/repositories/categories/category_repository.dart';
import '../../../data/repositories/gallery/gallery_repository.dart';
import '../../../data/repositories/place/place_repository.dart';

class GalleryController extends GetxController {
  static GalleryController get instance => Get.find();

  // Repositories
  final galleryRepository = Get.put(GalleryRepository());
  // Assuming these repositories are already implemented using your Firestore logic
  final placeRepository = PlaceRepository.instance;
  final categoryRepository = Get.put(CategoryRepository());

  /// Fetches all collections for the grid view
  Future<List<CollectionItem>> getAllCollections() async {
    try {
      final collections = await galleryRepository.getAllCollections();
      return collections;
    } catch (e) {
      AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  /// Fetches all gallery images for the main grid
  Future<List<GalleryImageModel>> getAllGalleryImages() async {
    try {
      final images = await galleryRepository.getAllGalleryImages();
      return images;
    } catch (e) {
      AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  /// NEW: Fetches featured images by pulling data from recent places.
  Future<List<FeaturedImagesModel>> getRecentFeaturedImages() async {
    try {
      // 1. Fetch recent places (e.g., top 5)
      final recentPlaces = await placeRepository.getRecentPlaces(limit: 5);

      if (recentPlaces.isEmpty) return [];

      // 2. Extract unique category IDs needed for lookup
      recentPlaces.map((place) => place.categoryId).toSet().toList();

      // 3. Fetch all necessary categories
      final categories = await categoryRepository.getAllCategories();
      final categoryMap = {for (var cat in categories) cat.id: cat.name};

      // 4. Transform PlaceModel data into the required FeaturedImagesModel
      final featuredImages = recentPlaces.map((place) {
        // Assume PlaceModel has a single main 'imageUrl' or you take the first from an image list
        final categoryName =
            categoryMap[place.categoryId] ?? 'Unknown Category';
        final imageUrl = place.images!.isNotEmpty
            ? place.images
            : 'https://placehold.co/500x300/CCCCCC/000000?text=No+Image';

        return FeaturedImagesModel(
          id: place.id,
          title: place.title, // Place Name for Title
          subtitle: categoryName, // Category Name for Subtitle
          imageUrl: imageUrl.toString(),
        );
      }).toList();

      return featuredImages;
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: 'Oh Snap!',
        message: 'Failed to load recent featured images: ${e.toString()}',
      );
      return [];
    }
  }
}
