import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/texts/section_heading.dart';
import 'package:reviews_app/features/review/controllers/gallery_controller.dart';
import 'package:reviews_app/features/review/models/collection_item.dart';
import 'package:reviews_app/utils/helpers/cloud_helper_functions.dart';
import 'package:reviews_app/common/widgets/shimmers/gallery_shimmer.dart';

class CollectionsSection extends StatelessWidget {
  const CollectionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AppSectionHeading(
            title: 'Collections',
            showActionButton: false,
            onPressed: () {},
          ),
          const SizedBox(height: 16),
          const CollectionsGrid(),
        ],
      ),
    );
  }
}

class CollectionsGrid extends StatelessWidget {
  const CollectionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GalleryController.instance;

    return FutureBuilder<List<CollectionItem>>(
      future: controller.getAllCollections(), // Fetch collections from DB
      builder: (context, snapshot) {
        /// --- Handle Loader, Empty, Error Message
        const loader = GalleryShimmer(
          count: 3,
          aspectRatio: 1.0,
          itemHeight: 100,
        ); // Using a placeholder shimmer for gallery items

        final widget = AppCloudHelperFunctions.checkMultiRecordState(
          snapshot: snapshot,
          loader: loader,
        );

        if (widget != null) return widget;

        /// --- Record Found!
        final collections = snapshot.data!;

        // 🎯 FIX: Changed from Row (which expands items) to a fixed-height, horizontal ListView.
        return SizedBox(
          height: 120, // Define an explicit height for the horizontal list
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: collections.length,
            // 🎯 FIX: Added spacing between cards
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (_, index) {
              final collection = collections[index];
              return CollectionCard(collection: collection);
            },
          ),
        );
      },
    );
  }
}

// --- Updated CollectionCard to be clickable and have a fixed width ---

class CollectionCard extends StatelessWidget {
  final CollectionItem collection;

  const CollectionCard({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    // 🎯 FIX: Wrapped the card in GestureDetector to make it clickable
    return GestureDetector(
      onTap: () {
        // 🎯 ACTION: Navigate to the screen showing photos for this collection.
        // We assume the GalleryController has a method to handle navigation.
        GalleryController.instance.navigateToPhotos(collection.id);

        // 💡 Note: If you're not using GetX routing, replace the line above with:
        // Navigator.push(context, MaterialPageRoute(builder: (context) => PhotosScreen(collectionId: collection.id)));
      },
      // 🎯 FIX: Set a fixed width for the card so it renders correctly in a horizontal list
      child: Container(
        width: 150,
        height: 100,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(collection.imageUrl),
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withValues(
                alpha: 0.1,
              ), // Used withOpacity instead of deprecated withValues
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.4),
              ], // Used withOpacity
              stops: const [0, 1],
              begin: AlignmentDirectional.topCenter,
              end: AlignmentDirectional.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align text to the left
              children: [
                Text(
                  collection.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  '${collection.photoCount} photos',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(
                      alpha: 0.8,
                    ), // Used withOpacity
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


//---------------------
// import 'package:flutter/material.dart';
// import 'package:reviews_app/common/widgets/texts/section_heading.dart';
// import 'package:reviews_app/features/review/controllers/gallery_controller.dart';
// import 'package:reviews_app/features/review/models/collection_item.dart';
// import 'package:reviews_app/utils/helpers/cloud_helper_functions.dart';
// import 'package:reviews_app/common/widgets/shimmers/gallery_shimmer.dart';
// // Assuming CollectionCard is here

// class CollectionsSection extends StatelessWidget {
//   const CollectionsSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: Column(
//         children: [
//           AppSectionHeading(
//             title: 'Collections',
//             buttonTitle: 'Manage',
//             onPressed: () {},
//           ),
//           const SizedBox(height: 16),
//           const CollectionsGrid(),
//         ],
//       ),
//     );
//   }
// }

// class CollectionsGrid extends StatelessWidget {
//   const CollectionsGrid({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = GalleryController.instance;

//     return FutureBuilder<List<CollectionItem>>(
//       future: controller.getAllCollections(), // Fetch collections from DB
//       builder: (context, snapshot) {
//         /// --- Handle Loader, Empty, Error Message
//         const loader = GalleryShimmer(
//           count: 3,
//           aspectRatio: 1.0,
//           itemHeight: 100,
//         ); // Using a placeholder shimmer for gallery items

//         final widget = AppCloudHelperFunctions.checkMultiRecordState(
//           snapshot: snapshot,
//           loader: loader,
//         );

//         if (widget != null) return widget;

//         /// --- Record Found!
//         final collections = snapshot.data!;

//         return Row(
//           children: collections
//               .map(
//                 (collection) =>
//                     Expanded(child: CollectionCard(collection: collection)),
//               )
//               .toList(),
//         );
//       },
//     );
//   }
// }

// class CollectionCard extends StatelessWidget {
//   final CollectionItem collection;

//   const CollectionCard({super.key, required this.collection});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 100,
//       decoration: BoxDecoration(
//         image: DecorationImage(
//           fit: BoxFit.cover,
//           image: NetworkImage(collection.imageUrl),
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             blurRadius: 10,
//             color: Colors.black.withValues(alpha: 0.1),
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)],
//             stops: const [0, 1],
//             begin: AlignmentDirectional.topCenter,
//             end: AlignmentDirectional.bottomCenter,
//           ),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Text(
//                 collection.title,
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                 ),
//               ),
//               Text(
//                 '${collection.photoCount} photos',
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color: Colors.white.withValues(alpha: 0.8),
//                   fontSize: 11,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

