import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/common/widgets/custom_shapes/containers/search_container.dart';
import 'package:reviews_app/features/review/controllers/gallery_controller.dart';
import 'package:reviews_app/features/review/screens/gallery/widgets/collection_section.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import '../../../../utils/constants/sizes.dart';
import '../search/search.dart';
import 'widgets/all_photos.dart';
import 'widgets/recent_photos.dart';

class ImageGalleryScreen extends StatelessWidget {
  const ImageGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final _ = Get.put(GalleryController());

    return GestureDetector(
      child: Scaffold(
        appBar: CustomAppBar(
          showBackArrow: true,
          centerTitle: true,
          title: Text(
            // 'Gallery',
            locale.gallery,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),

        body: Column(
          children: [
            AppSearchContainer(
              // text: 'Search for Places',
              text: AppLocalizations.of(context).searchPlaces,
              onTap: () => Get.to(() => SearchScreen()),
            ),
            const SizedBox(height: AppSizes.spaceBtwSections),
            Expanded(child: GalleryContent()),
          ],
        ),
      ),
    );
  }
}

class GalleryContent extends StatelessWidget {
  const GalleryContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const RecentPhotosSection(),
            const SizedBox(height: 24),
            const CollectionsSection(),
            const SizedBox(height: 24),
            const AllPhotosSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
