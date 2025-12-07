import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/constants/enums.dart'; // Import TextSizes enum

class PlaceTitleText extends StatelessWidget {
  final String title;
  final String? location;
  final TextSizes placeTitleSize;
  final bool isDarkBackground;
  final int maxLines;
  final bool isVerified;
  final Color? iconColor;
  final Color? titleColor;

  const PlaceTitleText({
    super.key,
    required this.title,
    this.location,
    this.placeTitleSize = TextSizes.medium,
    this.isDarkBackground = true,
    this.maxLines = 2,
    this.isVerified = false,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    /// -- Determine if location should be shown
    final bool showLocation = location != null && location!.isNotEmpty;

    /// -- Determine Title and Location Colors based on background
    final Color textColor =  isDarkBackground ? AppColors.white : AppColors.dark;
    final Color locationColor = isDarkBackground
        ? AppColors.grey
        : AppColors.darkGrey;

    // --- Determine Title Style based on TextSizes enum
    TextStyle titleStyle;
    switch (placeTitleSize) {
      case TextSizes.large:
        // Suitable for headers or large card titles (e.g., headlineMedium or titleLarge)
        // titleStyle = Theme.of(context).textTheme.headlineSmall!.copyWith(
        //   color: titleColor ?? textColor,
        //   fontWeight: FontWeight.bold,
        // );
        titleStyle = Theme.of(context).textTheme.headlineMedium!.copyWith(
          color: titleColor ?? textColor,
          fontWeight: FontWeight.bold,
        );
        break;
      case TextSizes.medium:
        // Suitable for standard card titles (e.g., titleMedium)
        titleStyle = Theme.of(context).textTheme.titleMedium!.copyWith(
          color: titleColor ?? textColor,
          fontWeight: FontWeight.bold,
        );
        break;
      case TextSizes.small:
        // Suitable for small/compact card titles (e.g., labelLarge or titleSmall)
        titleStyle = Theme.of(context).textTheme.titleSmall!.copyWith(
          color: titleColor ?? textColor ,
          fontWeight: FontWeight.bold,
        );
        break;
    }

    /// -- Determine Location Style and Icon Size based on TextSizes enum
    TextStyle locationStyle;
    double mapIconSize;
    double verificationIconSize;
    double spacing;

    if (placeTitleSize == TextSizes.small) {
      locationStyle = Theme.of(
        context,
      ).textTheme.labelSmall!.copyWith(color: locationColor);
      mapIconSize = 12;
      verificationIconSize = 14;
      spacing = AppSizes.xs;
    } else {
      locationStyle = Theme.of(
        context,
      ).textTheme.bodySmall!.copyWith(color: locationColor);
      mapIconSize = 16;
      verificationIconSize = 18;
      spacing = AppSizes.sm;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        /// -- Title and Verified Icon
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                title,
                style: titleStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: maxLines,
              ),
            ),

            // Show Verified Icon if isVerified is true
            if (isVerified) ...[
              const SizedBox(width: AppSizes.xs),
              Icon(
                Iconsax.verify5,
                color: iconColor ?? AppColors.primaryColor,
                size: verificationIconSize,
              ),
            ],
          ],
        ),

        /// -- Location (Conditionally displayed)
        if (showLocation) ...[
          SizedBox(height: spacing),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                color: locationColor,
                size: mapIconSize,
              ),
              const SizedBox(width: AppSizes.xs),
              Flexible(
                child: Text(
                  location ?? '',
                  style: locationStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

//---------perfect version----------------
// import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart'; // Iconsax dependency added for the verified icon
// import 'package:reviews_app/utils/constants/colors.dart';
// import 'package:reviews_app/utils/constants/sizes.dart';

// class PlaceTitleText extends StatelessWidget {
//   final String title;
//   final String? location;
//   final bool isSmall;
//   final bool isDarkBackground;
//   final int maxLines;
//   final bool isVerified; // New property for the verified icon
//   final Color? iconColor;

//   const PlaceTitleText({
//     super.key,
//     required this.title,
//     this.location,
//     this.isSmall = false,
//     this.isDarkBackground = true,
//     this.maxLines = 2,
//     this.isVerified = false, // Default is false
//     this.iconColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     /// -- Determine if location should be shown based on whether the string is provided
//     final bool showLocation = location != null && location!.isNotEmpty;

//     /// -- Determine Title Style and Color based on size and background
//     final Color textColor = isDarkBackground
//         ? AppColors.white
//         : AppColors.dark;

//     final TextStyle titleStyle = isSmall
//         ? Theme.of(context).textTheme.labelLarge!.copyWith(
//               color: textColor,
//               fontWeight: FontWeight.bold,
//             )
//         : Theme.of(context).textTheme.titleMedium!.copyWith(
//               color: textColor,
//               fontWeight: FontWeight.bold,
//             );

//     /// -- Determine Location Style and Icon Color
//     final Color locationColor = isDarkBackground
//         ? AppColors.grey
//         : AppColors.darkGrey;
//     final TextStyle locationStyle = isSmall
//         ? Theme.of(context).textTheme.labelSmall!.copyWith(color: locationColor)
//         : Theme.of(context).textTheme.bodySmall!.copyWith(color: locationColor);

//     final double verificationIconSize = isSmall ? 14 : 18;
//     final double mapIconSize = isSmall ? 12 : 16;
//     final double spacing = isSmall ? AppSizes.xs : AppSizes.sm;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       // Ensure the column doesn't take unnecessary space
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         /// -- Title and Verified Icon (combined in a Row)
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Flexible(
//               child: Text(
//                 title,
//                 style: titleStyle,
//                 overflow: TextOverflow.ellipsis,
//                 maxLines: maxLines,
//               ),
//             ),

//             // Show Verified Icon if isVerified is true
//             if (isVerified) ...[
//               const SizedBox(width: AppSizes.xs),
//               Icon(
//                 Iconsax.verify5,
//                 // Use the provided iconColor, or default to the primary theme color, or the text color
//                 color: iconColor ?? AppColors.primaryColor,
//                 size: verificationIconSize,
//               ),
//             ],
//           ],
//         ),

//         /// -- Location (Conditionally displayed)
//         if (showLocation) ...[
//           SizedBox(height: spacing),
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.location_on_rounded,
//                 color: locationColor,
//                 size: mapIconSize,
//               ),
//               const SizedBox(width: AppSizes.xs),
//               Flexible(
//                 // Use Flexible to prevent the text from causing overflow errors in tight spaces
//                 child: Text(
//                   location ?? '',
//                   style: locationStyle,
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ],
//     );
//   }
// }

//--------2nd version with verify icon----------------
// import 'package:flutter/material.dart';
// import 'package:reviews_app/utils/constants/colors.dart';
// import 'package:reviews_app/utils/constants/sizes.dart';
// // NOTE: Removed the dependency on 'package:reviews_app/features/review/models/place_model.dart'

// class PlaceTitleText extends StatelessWidget {
//   final String title;
//   final String? location;
//   final bool isSmall;
//   final bool isDarkBackground;
//   final int maxLines;

//   const PlaceTitleText({
//     super.key,
//     required this.title,
//     this.location,
//     this.isSmall = false,
//     this.isDarkBackground = true,
//     this.maxLines = 2,
//   });

//   @override
//   Widget build(BuildContext context) {
//     /// -- Determine if location should be shown based on whether the string is provided
//     final bool showLocation = location != null && location!.isNotEmpty;

//     /// -- Determine Title Style based on size and background
//     final Color titleColor = isDarkBackground
//         ? AppColors.white
//         : AppColors.dark;

//     final TextStyle titleStyle = isSmall
//         ? Theme.of(context).textTheme.labelLarge!.copyWith(
//             color: titleColor,
//             fontWeight: FontWeight.bold,
//           )
//         : Theme.of(context).textTheme.titleMedium!.copyWith(
//             color: titleColor,
//             fontWeight: FontWeight.bold,
//           );

//     /// -- Determine Location Style and Icon Color
//     final Color locationColor = isDarkBackground
//         ? AppColors.grey
//         : AppColors.darkGrey;
//     final TextStyle locationStyle = isSmall
//         ? Theme.of(context).textTheme.labelSmall!.copyWith(color: locationColor)
//         : Theme.of(context).textTheme.bodySmall!.copyWith(color: locationColor);

//     final double iconSize = isSmall ? 12 : 16;
//     final double spacing = isSmall ? AppSizes.xs : AppSizes.sm;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       // Ensure the column doesn't take unnecessary space
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         /// -- Title
//         Text(
//           title,
//           style: titleStyle,
//           overflow: TextOverflow.ellipsis,
//           maxLines: maxLines,
//         ),

//         /// -- Location (Conditionally displayed)
//         if (showLocation) ...[
//           SizedBox(height: spacing),
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.location_on_rounded,
//                 color: locationColor,
//                 size: iconSize,
//               ),
//               const SizedBox(width: AppSizes.xs),
//               Flexible(
//                 // Use Flexible to prevent the text from causing overflow errors in tight spaces
//                 child: Text(
//                   location ??
//                       '', // We can assert non-null because of the showLocation check
//                   style: locationStyle,
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ],
//     );
//   }
// }

// import 'package:flutter/material.dart';

// class PlaceTitleText extends StatelessWidget {
//   const PlaceTitleText({
//     super.key,
//     required this.title,
//     this.smallSize = false,
//     this.maxLines = 2,
//     this.textAlign = TextAlign.left,
//   });

//   final String title;
//   final bool smallSize;
//   final int maxLines;
//   final TextAlign? textAlign;

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       title,
//       style: smallSize
//           ? Theme.of(context).textTheme.labelLarge
//           : Theme.of(context).textTheme.titleSmall,
//       overflow: TextOverflow.ellipsis,
//       maxLines: maxLines,
//       textAlign: textAlign,
//     );
//   }
// }
