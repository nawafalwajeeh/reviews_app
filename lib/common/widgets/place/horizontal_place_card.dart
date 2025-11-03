import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/place/favourite_icon/favourite_icon.dart';
import 'package:reviews_app/common/widgets/texts/place_title_text.dart';
import 'package:reviews_app/features/review/screens/place_details/place_details.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/enums.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';
import '../../../utils/constants/sizes.dart';
import '../../../features/review/models/place_model.dart';
import 'rating/place_rating_badge.dart';

class PlaceCardHorizontal extends StatelessWidget {
  final PlaceModel place;
  final double?
  height; // Still allowing height to be set, but we'll manage content

  const PlaceCardHorizontal({
    super.key,
    required this.place,
    this.height = 180, // Keeping this default height for the *entire card*
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);

    // Let's make the card slightly wider to accommodate the new image/text layout
    const double cardWidth = 360; // Increased width
    const double imageHeightRatio =
        0.65; // Image takes about 65% of the card's width
    // making it wide and short as requested
    final double imageSectionWidth = cardWidth * imageHeightRatio;
    final double detailsSectionWidth = cardWidth * (1 - imageHeightRatio);

    return GestureDetector(
      onTap: () => Get.to(() => PlaceDetailsScreen()),
      child: Container(
        height: height,
        width: cardWidth, // Use our calculated card width
        margin: const EdgeInsets.only(right: AppSizes.md),
        decoration: BoxDecoration(
          color: dark ? AppColors.darkerGrey : AppColors.light,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkGrey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// -- Thumbnail Image Section (now includes title & location overlay)
            SizedBox(
              width: imageSectionWidth, // Use calculated image section width
              child: Stack(
                children: [
                  // Main Image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppSizes.cardRadiusLg),
                      bottomLeft: Radius.circular(AppSizes.cardRadiusLg),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: place.thumbnail,
                      height: double.infinity, // Fill available height
                      width: double.infinity, // Fill available width
                      fit: BoxFit.cover, // Cover the entire area
                      placeholder: (context, url) =>
                          Container(color: AppColors.lightGrey),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: AppColors.grey,
                          size: 40,
                        ),
                      ),
                    ),
                  ),

                  // Gradient Overlay (for title readability)
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          dark
                              ? AppColors.dark.withOpacity(0.4)
                              : AppColors.black.withOpacity(0.2),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppSizes.cardRadiusLg),
                        bottomLeft: Radius.circular(AppSizes.cardRadiusLg),
                      ),
                    ),
                  ),

                  // Rating Badge (Top Left)
                  Positioned(
                    left: AppSizes.sm,
                    top: AppSizes.sm,
                    child: PlaceRatingBadge(rating: place.rating),
                  ),

                  // Favourite Icon (Top Right)
                  Positioned(
                    right: AppSizes.sm,
                    top: AppSizes.sm,
                    child: AppFavouriteIcon(),
                  ),

                  // Place Title and Location (Overlayed at the Bottom)
                  Positioned(
                    left: AppSizes.md, // Increased padding
                    right: AppSizes.md, // Increased padding
                    bottom: AppSizes.md, // Increased padding
                    child: PlaceTitleText(
                      title: place.title,
                      location: place.location,
                      isVerified: true, // Assuming verification status
                      placeTitleSize: TextSizes.small, // Keep text concise here
                      isDarkBackground:
                          true, // Always show light text on image overlay
                    ),
                  ),
                ],
              ),
            ),

            /// -- Details Section (Category, Description, Button)
            SizedBox(
              // Use SizedBox with fixed width for details section
              width: detailsSectionWidth,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top part: Category, Description
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.categoryId,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          place.description,
                          overflow: TextOverflow.ellipsis,
                          maxLines:
                              3, // Allow slightly more lines for description if needed
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.darkGrey,
                            fontSize:
                                12, // Slightly smaller font for more compact look
                          ),
                        ),
                      ],
                    ),

                    /// -- View Details Button
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () => Get.to(() => PlaceDetailsScreen()),
                        child: Container(
                          height: 38, // Slightly adjusted button height
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(
                              AppSizes.borderRadiusLg,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'View Details',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.apply(
                                  color: AppColors.white,
                                  fontWeightDelta: 1,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//---------------------------
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:reviews_app/common/widgets/place/favourite_icon/favourite_icon.dart';
// import 'package:reviews_app/common/widgets/texts/place_title_text.dart';
// import 'package:reviews_app/features/review/screens/place_details/place_details.dart';
// import 'package:reviews_app/utils/constants/colors.dart';
// import 'package:reviews_app/utils/constants/enums.dart'; // Assuming TextSizes is here
// import 'package:reviews_app/utils/helpers/helper_functions.dart';
// import '../../../utils/constants/sizes.dart';
// import '../../../features/review/models/place_model.dart';
// import 'rating/place_rating_badge.dart';

// class PlaceCardHorizontal extends StatelessWidget {
//   final PlaceModel place;
//   // Optional: You can add a height parameter if you want to control the card's height
//   // from where it's used, especially for horizontal lists.
//   final double? height; 

//   const PlaceCardHorizontal({
//     super.key,
//     required this.place,
//     this.height = 150, // Default height for a horizontal card
//   });

//   @override
//   Widget build(BuildContext context) {
//     final dark = AppHelperFunctions.isDarkMode(context);

//     return GestureDetector(
//       onTap: () => Get.to(() => PlaceDetailsScreen()),
//       child: Container(
//         height: height, // Use the provided height
//         width: 300, // You might want to adjust this width based on your design
//         margin: const EdgeInsets.only(right: AppSizes.spaceBtwItems), // Add margin for horizontal spacing
//         decoration: BoxDecoration(
//           color: dark ? AppColors.darkerGrey : AppColors.grey,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: const [
//             BoxShadow(
//               blurRadius: 8,
//               color: AppColors.dark,
//               offset: Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.stretch, // Make children stretch to fill height
//           children: [
//             /// -- Thumbnail Image
//             SizedBox(
//               width: 120, // Fixed width for the image
//               child: Stack(
//                 children: [
//                   ClipRRect(
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(20),
//                       bottomLeft: Radius.circular(20),
//                     ),
//                     child: CachedNetworkImage(
//                       imageUrl: place.thumbnail,
//                       height: double.infinity,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   Container(
//                     width: double.infinity,
//                     height: double.infinity,
//                     decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Colors.transparent, Color(0x80000000)],
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                       ),
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(20),
//                         bottomLeft: Radius.circular(20),
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     left: AppSizes.sm,
//                     top: AppSizes.sm,
//                     child: PlaceRatingBadge(rating: place.rating),
//                   ),
//                   Positioned(
//                     right: AppSizes.sm,
//                     top: AppSizes.sm,
//                     child: AppFavouriteIcon(),
//                   ),
//                   Positioned(
//                     left: AppSizes.sm,
//                     bottom: AppSizes.sm,
//                     child: PlaceTitleText(
//                       title: place.title,
//                       location: place.location,
//                       isVerified: true,
//                       placeTitleSize: TextSizes.small, // Smaller font for horizontal card
//                       isDarkBackground: true,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
            
//             /// -- Details Section
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(AppSizes.sm), // Reduced padding for compact layout
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space out top text and button
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           place.category,
//                           style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primaryColor), // Using labelLarge
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: AppSizes.xs), // Smaller gap
//                         Text(
//                           place.description,
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 2, // Limit description to 2 lines
//                           style: Theme.of(context).textTheme.bodySmall,
//                         ),
//                       ],
//                     ),
                    
//                     /// -- View Details Button
//                     SizedBox(
//                       width: double.infinity, // Make button fill available width
//                       child: Container(
//                         height: 30, // Slightly smaller button height
//                         decoration: BoxDecoration(
//                           color: AppColors.primaryColor,
//                           borderRadius: BorderRadius.circular(15), // Adjusted for smaller height
//                         ),
//                         alignment: Alignment.center,
//                         padding: const EdgeInsets.symmetric(horizontal: AppSizes.md), // Adjusted padding
//                         child: Text(
//                           'View Details',
//                           style: Theme.of(context).textTheme.labelSmall?.apply(color: AppColors.light), // Smaller text for button
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }