import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/texts/section_heading.dart';
import 'package:reviews_app/features/review/controllers/gallery_controller.dart';
import 'package:reviews_app/features/review/models/collection_item.dart';
import 'package:reviews_app/utils/helpers/cloud_helper_functions.dart';
import 'package:reviews_app/common/widgets/shimmers/gallery_shimmer.dart';
// Assuming CollectionCard is here

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
            buttonTitle: 'Manage',
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
            itemHeight: 100); // Using a placeholder shimmer for gallery items

        final widget = AppCloudHelperFunctions.checkMultiRecordState(
          snapshot: snapshot,
          loader: loader,
          // You might customize the "No Records Found" message here
        );

        if (widget != null) return widget;

        /// --- Record Found!
        final collections = snapshot.data!;

        return Row(
          children: collections
              .map(
                (collection) =>
                    Expanded(child: CollectionCard(collection: collection)),
              )
              .toList(),
          // Note: You need a way to separate items. I'm removing the commented separator to avoid compilation issues, 
          // but if your `separate` extension works, you can add it back. 
          // For now, I'll rely on padding/margin within CollectionCard or its container logic.
        );
      },
    );
  }
}



class CollectionCard extends StatelessWidget {
  final CollectionItem collection;

  const CollectionCard({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)],
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
            children: [
              Text(
                collection.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                '${collection.photoCount} photos',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//---------------------------
// import 'package:flutter/material.dart';
// import 'package:reviews_app/common/widgets/texts/section_heading.dart';

// import '../../../models/collection_item.dart';
// import 'gallery_widgets.dart';

// class CollectionsSection extends StatelessWidget {
//   const CollectionsSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 24),
//       child: Column(
//         children: [
//           AppSectionHeading(
//             title: 'Collections',
//             buttonTitle: 'Manage',
//             onPressed: () {},
//           ),
//           SizedBox(height: 16),
//           CollectionsGrid(),
//         ],
//       ),
//     );
//   }
// }

// class CollectionsGrid extends StatelessWidget {
//   const CollectionsGrid({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final collections = [
//       CollectionItem(
//         imageUrl:
//             'https://images.unsplash.com/photo-1592211801285-1353c35743a7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
//         title: 'Travel',
//         photoCount: 24,
//       ),
//       CollectionItem(
//         imageUrl:
//             'https://images.unsplash.com/photo-1673465792556-e9545649b179?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
//         title: 'Food',
//         photoCount: 18,
//       ),
//       CollectionItem(
//         imageUrl:
//             'https://images.unsplash.com/photo-1619856266537-0111fc5a4c67?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
//         title: 'Portraits',
//         photoCount: 32,
//       ),
//     ];

//     return Row(
//       children: collections
//           .map(
//             (collection) =>
//                 Expanded(child: CollectionCard(collection: collection)),
//           )
//           .toList(),
//       // .separate(const SizedBox(width: 16)),
//     );
//   }
// }