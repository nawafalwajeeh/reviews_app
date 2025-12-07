import 'package:flutter/material.dart';
import 'package:reviews_app/localization/app_localizations.dart';

import '../../../../../common/widgets/shimmers/gallery_shimmer.dart';
import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/cloud_helper_functions.dart';
import '../../../controllers/gallery_controller.dart';
import '../../../models/featured_images_model.dart';
import 'featured_image_card.dart';

class RecentPhotosSection extends StatelessWidget {
  const RecentPhotosSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GalleryController.instance;
    final locale = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeading(
            title:
                // 'Recent Places', // Updated title to reflect the content source
                locale.recentPlaces,
            showActionButton: false,
            onPressed: null,
          ),
          const SizedBox(height: AppSizes.spaceBtwItems),

          FutureBuilder<List<FeaturedImagesModel>>(
            // This future is now correctly fixed to return a single String URL in the model
            future: controller
                .getRecentFeaturedImages(), // Fetch from recent places
            builder: (context, snapshot) {
              /// --- Handle Loader, Empty, Error Message using your helper
              const loader = GalleryShimmer(
                count: 3,
                crossAxisCount: 1,
                itemHeight: 250,
              );

              final widget = AppCloudHelperFunctions.checkMultiRecordState(
                snapshot: snapshot,
                loader: loader,
              );

              if (widget != null) return widget;

              /// --- Record Found!
              final recentImages = snapshot.data!;

              return SizedBox(
                height: 250,
                child: ListView.separated(
                  itemCount: recentImages.length,
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSizes.spaceBtwItems),
                  itemBuilder: (context, index) {
                    final image = recentImages[index];
                    return SizedBox(
                      width:
                          MediaQuery.of(context).size.width *
                          0.75, // Make cards wide
                      child: FeaturedImageCard(featuredImage: image),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
