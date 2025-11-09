import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:readmore/readmore.dart';
import 'package:reviews_app/common/widgets/texts/section_heading.dart';
// import 'package:reviews_app/features/review/controllers/place_controller.dart';
import 'package:reviews_app/features/review/models/place_model.dart';
import 'package:reviews_app/utils/constants/colors.dart' show AppColors;
import '../../../../utils/constants/sizes.dart';
import '../place_reviews/place_reviews.dart';
import 'widgets/details_image_slider.dart';
import 'widgets/place_aminities.dart';
import 'widgets/place_meta_data.dart';
import 'widgets/rating_share.dart';
import 'widgets/write_review.dart';

class PlaceDetailsScreen extends StatelessWidget {
  const PlaceDetailsScreen({super.key, required this.place});

  final PlaceModel place;

  @override
  Widget build(BuildContext context) {
    // final controller = PlaceController.instance;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// -- Place Image Slider & Custom AppBar
                PlaceImageSlider(place: place),

                /// -- Details Content Section
                Padding(
                  padding: const EdgeInsets.all(AppSizes.defaultSpace),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// -- Place Metadata (Title, Location, Category)
                      PlaceMetadata(place: place),
                      const SizedBox(height: AppSizes.spaceBtwItems),

                      /// -- Rating and Share Widget
                      RatingAndShareWidget(place: place),
                      const SizedBox(height: AppSizes.spaceBtwSections),

                      /// -- Overview & Description
                      const AppSectionHeading(
                        title: 'Description',
                        showActionButton: false,
                      ),
                      const SizedBox(height: AppSizes.spaceBtwItems),
                      ReadMoreText(
                        place.description,
                        trimLines: 2,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: ' Show more',
                        trimExpandedText: ' Less',
                        moreStyle: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        lessStyle: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spaceBtwSections),
                      const AppSectionHeading(
                        title: 'Amentities',
                        showActionButton: false,
                      ),
                      AmenitiesSection(tags: place.tags ?? []),
                      const SizedBox(height: AppSizes.spaceBtwSections),

                      /// -- Map Section Placeholder
                      // const AppSectionHeading(
                      //   title: 'Location on Map',
                      //   showActionButton: false,
                      // ),
                      // const SizedBox(height: AppSizes.spaceBtwItems),
                      // Container(
                      //   height: 200,
                      //   decoration: BoxDecoration(
                      //     color: Colors.grey.shade200,
                      //     borderRadius: BorderRadius.circular(
                      //       AppSizes.cardRadiusMd,
                      //     ),
                      //   ),
                      //   alignment: Alignment.center,
                      //   child: Text(
                      //     'Map View Placeholder',
                      //     style: Theme.of(context).textTheme.titleMedium,
                      //   ),
                      // ),
                      WriteReviewSection(),
                      SizedBox(height: AppSizes.spaceBtwItems),

                      const Divider(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AppSectionHeading(
                            title: 'Reviews(199)',
                            showActionButton: false,
                          ),
                          IconButton(
                            onPressed: () =>
                                Get.to(() => const PlaceReviewsScreen()),
                            icon: const Icon(Iconsax.arrow_right_3, size: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
