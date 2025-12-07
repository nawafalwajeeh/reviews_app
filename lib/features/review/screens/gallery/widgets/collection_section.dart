import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/texts/section_heading.dart';
import 'package:reviews_app/features/review/controllers/gallery_controller.dart';
import 'package:reviews_app/features/review/models/collection_item.dart';
import 'package:reviews_app/utils/helpers/cloud_helper_functions.dart';
import 'package:reviews_app/common/widgets/shimmers/gallery_shimmer.dart';

import '../../../../../localization/app_localizations.dart';
import 'collection_card.dart';

class CollectionsSection extends StatelessWidget {
  const CollectionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AppSectionHeading(
            // title: 'Collections',
          title:  AppLocalizations.of(context).collections,
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

        return SizedBox(
          height: 120, // Define an explicit height for the horizontal list
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: collections.length,
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
