import 'package:flutter/material.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';

class PlaceRatingBadge extends StatelessWidget {
  final double rating;
  final bool isSmall;

  const PlaceRatingBadge({
    super.key,
    required this.rating,
    this.isSmall = false, // Defaults to the larger size
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);

    // Dynamic dimensions based on size flag
    final double width = isSmall ? 50 : 60;
    final double height = isSmall ? 22 : 28;
    final double iconSize = isSmall ? AppSizes.iconSm : AppSizes.iconMd;
    final double fontSize = isSmall ? 10 : 12;
    final double borderRadius = isSmall ? 11 : 14;

    // Determine text style
    final TextStyle ratingTextStyle = Theme.of(context).textTheme.bodySmall!
        .copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: dark ? AppColors.light : AppColors.dark,
        );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: dark ? AppColors.dark : AppColors.light.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_rounded,
            color: AppColors.secondary, // Yellow/Gold color for star
            size: iconSize,
          ),
          const SizedBox(width: 2), // Reduced spacing for compact look
          Text(rating.toStringAsFixed(1), style: ratingTextStyle),
        ],
      ),
    );
  }
}

//-----------Original code----------------------
// import 'package:flutter/material.dart';
// import 'package:reviews_app/features/review/models/place_model.dart';
// import 'package:reviews_app/utils/constants/colors.dart';
// import 'package:reviews_app/utils/constants/sizes.dart';
// import 'package:reviews_app/utils/helpers/helper_functions.dart';

// class PlaceRatingBadge extends StatelessWidget {
//   const PlaceRatingBadge({super.key, required this.place});

//   final PlaceModel place;

//   @override
//   Widget build(BuildContext context) {
//     final dark = AppHelperFunctions.isDarkMode(context);

//     return Container(
//       width: 60,
//       height: 28,
//       decoration: BoxDecoration(
//         color: dark ? AppColors.dark : AppColors.light.withValues(alpha: 0.7),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.star_rounded,
//             color: AppColors.secondary,
//             size: AppSizes.iconMd,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             place.rating.toStringAsFixed(1),
//             style: Theme.of(context).textTheme.bodySmall?.apply(
//               color: dark ? AppColors.light : AppColors.dark,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
