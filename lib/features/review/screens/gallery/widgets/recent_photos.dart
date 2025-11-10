import 'package:flutter/material.dart';

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeading(
            title:
                'Recent Places', // Updated title to reflect the content source

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
//-------------------------
// import 'package:flutter/material.dart';
// import 'package:reviews_app/common/widgets/shimmers/gallery_shimmer.dart';
// import 'package:reviews_app/common/widgets/texts/section_heading.dart';
// import 'package:reviews_app/features/review/controllers/gallery_controller.dart';
// import 'package:reviews_app/features/review/models/featured_images_model.dart';
// import 'package:reviews_app/utils/constants/sizes.dart';
// import 'package:reviews_app/utils/helpers/cloud_helper_functions.dart';

// import 'featured_image_card.dart';

// // Assuming FeaturedImageCard is here

// class RecentPhotosSection extends StatelessWidget {
//   const RecentPhotosSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = GalleryController.instance;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const AppSectionHeading(
//             title:
//                 'Recent Places', // Updated title to reflect the content source
//             buttonTitle: 'View All',
//             onPressed: null,
//           ),
//           const SizedBox(height: AppSizes.spaceBtwItems),

//           FutureBuilder<List<FeaturedImagesModel>>(
//             future: controller
//                 .getRecentFeaturedImages(), // Fetch from recent places
//             builder: (context, snapshot) {
//               /// --- Handle Loader, Empty, Error Message using your helper
//               const loader = GalleryShimmer(
//                 count: 3,
//                 crossAxisCount: 1,
//                 itemHeight: 250,
//               );

//               final widget = AppCloudHelperFunctions.checkMultiRecordState(
//                 snapshot: snapshot,
//                 loader: loader,
//               );

//               if (widget != null) return widget;

//               /// --- Record Found!
//               final recentImages = snapshot.data!;

//               return SizedBox(
//                 height: 250,
//                 child: ListView.separated(
//                   itemCount: recentImages.length,
//                   scrollDirection: Axis.horizontal,
//                   separatorBuilder: (_, _) =>
//                       const SizedBox(width: AppSizes.spaceBtwItems),
//                   itemBuilder: (context, index) {
//                     final image = recentImages[index];
//                     return SizedBox(
//                       width:
//                           MediaQuery.of(context).size.width *
//                           0.75, // Make cards wide
//                       child: FeaturedImageCard(featuredImage: image),
//                     );
//                   },
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
//------------------
// import 'package:flutter/material.dart';
// import 'package:reviews_app/common/widgets/texts/section_heading.dart';
// import 'package:reviews_app/features/review/models/featured_images_model.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// import 'featured_image_card.dart';

// class RecentPhotosSection extends StatelessWidget {
//   const RecentPhotosSection({super.key});



//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 24),
//       child: Column(
//         children: [
//           AppSectionHeading(title: 'Recent Photos', onPressed: () {}),
//           SizedBox(height: 16),
//           FeaturedImageCarousel(),
//         ],
//       ),
//     );
//   }
// }

// class FeaturedImageCarousel extends StatefulWidget {
//   const FeaturedImageCarousel({super.key});

//   @override
//   State<FeaturedImageCarousel> createState() => _FeaturedImageCarouselState();
// }

// class _FeaturedImageCarouselState extends State<FeaturedImageCarousel> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;

//   final List<FeaturedImagesModel> _featuredImages = [
//     FeaturedImagesModel(
//       imageUrl:
//           'https://images.unsplash.com/photo-1628945647517-697bf1a7d905?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
//       title: 'Mountain Sunrise',
//       subtitle: 'Captured at Golden Hour',
//     ),
//     FeaturedImagesModel(
//       imageUrl:
//           'https://images.unsplash.com/photo-1563302485-df734143a240?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
//       title: 'Ocean Waves',
//       subtitle: 'Peaceful Beach Moment',
//     ),
//     FeaturedImagesModel(
//       imageUrl:
//           'https://images.unsplash.com/photo-1621248439845-00ad5009e2f6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
//       title: 'Forest Path',
//       subtitle: 'Morning Adventure',
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 280,
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             blurRadius: 15,
//             color: Colors.black.withValues(alpha: 0.1),
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           PageView(
//             controller: _pageController,
//             // onPageChanged: (index) => setState(() => _currentPage = index),
//             children: _featuredImages
//                 .map((image) => FeaturedImageCard(featuredImage: image))
//                 .toList(),
//           ),
//           Positioned(
//             bottom: 16,
//             left: 0,
//             right: 0,
//             child: _PageIndicator(
//               controller: _pageController,
//               count: _featuredImages.length,
//               currentPage: _currentPage,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// class _PageIndicator extends StatelessWidget {
//   final PageController controller;
//   final int count;
//   final int currentPage;

//   const _PageIndicator({
//     required this.controller,
//     required this.count,
//     required this.currentPage,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SmoothPageIndicator(
//       controller: controller,
//       count: count,
//       effect: ExpandingDotsEffect(
//         expansionFactor: 2.5,
//         spacing: 8,
//         radius: 12,
//         dotWidth: 12,
//         dotHeight: 6,
//         dotColor: Colors.black.withValues(alpha: 0.3),
//         activeDotColor: Theme.of(context).colorScheme.primary,
//         paintStyle: PaintingStyle.fill,
//       ),
//     );
//   }
// }
