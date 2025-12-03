import 'package:get/get.dart';
import 'package:reviews_app/features/review/models/gallery_image_model.dart';
import '../image_viewer_screen.dart';

class GalleryImageViewerHelper {
  static void openGalleryImageViewer({
    required List<GalleryImageModel> galleryImages,
    required int initialIndex,
  }) {
    // Extract URLs and metadata
    final imageUrls = galleryImages.map((img) => img.imageUrl).toList();

    // Create metadata map
    final Map<int, Map<String, dynamic>> metadata = {};

    for (int i = 0; i < galleryImages.length; i++) {
      metadata[i] = {
        'placeName': galleryImages[i].placeName,
        // 'location': galleryImages[i].location ?? '',
        // 'rating': galleryImages[i].rating ?? 0.0,
      };
    }

    Get.to(
      () => ImageViewerScreen(
        imageUrls: imageUrls,
        initialIndex: initialIndex,
        isFromGallery: true,
        galleryMetadata: metadata,
      ),
    );
  }

  static void openGroupedGalleryImageViewer({
    required String placeName,
    required List<GalleryImageModel> images,
    required int initialIndex,
  }) {
    openGalleryImageViewer(galleryImages: images, initialIndex: initialIndex);
  }
}
