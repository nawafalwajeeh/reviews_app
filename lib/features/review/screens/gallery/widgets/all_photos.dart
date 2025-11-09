import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/shimmers/gallery_shimmer.dart';
import 'package:reviews_app/features/review/controllers/gallery_controller.dart';
import 'package:reviews_app/features/review/models/gallery_image_model.dart';
import 'package:reviews_app/utils/helpers/cloud_helper_functions.dart';

import 'gallery_widgets.dart';

class AllPhotosSection extends StatelessWidget {
  const AllPhotosSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SectionHeader(title: 'All Photos'),
          SizedBox(height: 16),
          PhotoGrid(),
        ],
      ),
    );
  }
}

class PhotoGrid extends StatelessWidget {
  const PhotoGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GalleryController.instance;

    return FutureBuilder<List<GalleryImageModel>>(
      future: controller.getAllGalleryImages(), // Fetch all images from DB
      builder: (context, snapshot) {
        /// --- Handle Loader, Empty, Error Message
        const loader = GalleryShimmer(
          count: 9,
          aspectRatio: 0.7,
          crossAxisCount: 3,
        );

        final widget = AppCloudHelperFunctions.checkMultiRecordState(
          snapshot: snapshot,
          loader: loader,
        );

        if (widget != null) return widget;

        /// --- Record Found!
        final photos = snapshot.data!;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.7,
          ),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            final imageUrl = photos[index].imageUrl;
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(imageUrl), // Use fetched imageUrl
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black.withValues(alpha: 0.1),
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

//--------------------------------
// import 'package:flutter/material.dart';

// import 'gallery_widgets.dart';

// class AllPhotosSection extends StatelessWidget {
//   const AllPhotosSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Padding(
//       padding: EdgeInsets.symmetric(horizontal: 24),
//       child: Column(
//         children: [
//           SectionHeader(title: 'All Photos'),
//           SizedBox(height: 16),
//           PhotoGrid(),
//         ],
//       ),
//     );
//   }
// }

// class PhotoGrid extends StatelessWidget {
//   const PhotoGrid({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final photoUrls = [
//       'https://images.unsplash.com/photo-1716386480079-9e12aa53a9b4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
//       'https://images.unsplash.com/photo-1552657490-8a0cf383c33a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
//       'https://images.unsplash.com/photo-1599834027865-61d3931db8cc?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
//       'https://images.unsplash.com/photo-1718875727989-f0a679020075?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
//       'https://images.unsplash.com/photo-1714201624095-11407e335eff?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
//       'https://images.unsplash.com/photo-1701401901550-16330a541ae3?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
//       'https://images.unsplash.com/photo-1657665675084-2a9dec00f211?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
//       'https://images.unsplash.com/photo-1570922958075-787eb527f829?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
//       'https://images.unsplash.com/photo-1642399403814-360bc87e12fb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
//     ];

//     return GridView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         crossAxisSpacing: 8,
//         mainAxisSpacing: 8,
//         childAspectRatio: 0.7,
//       ),
//       itemCount: photoUrls.length,
//       itemBuilder: (context, index) {
//         return ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 fit: BoxFit.cover,
//                 image: NetworkImage(photoUrls[index]),
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   blurRadius: 8,
//                   color: Colors.black.withValues(alpha: 0.1),
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
