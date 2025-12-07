import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/texts/category_name_text.dart';
import '../../../../../localization/app_localizations.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../controllers/gallery_controller.dart';
import '../../../models/collection_item.dart';

class CollectionCard extends StatelessWidget {
  final CollectionItem collection;

  const CollectionCard({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    debugPrint('CollectionID: ${collection.id}');
    return GestureDetector(
      onTap: () => GalleryController.instance.navigateToPhotos(collection.id),
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
                CategoryNameText(
                  categoryId: collection.collectionId,
                  isSingular: false,
                  textColor: AppColors.white,
                ),
                Text(
                  // '${collection.photoCount} photos',
                  '${collection.photoCount} ${AppLocalizations.of(context).photos}',
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
