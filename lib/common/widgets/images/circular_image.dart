import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/shimmers/shimmer_effect.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';

class AppCircularImage extends StatelessWidget {
  const AppCircularImage({
    super.key,
    this.width = 56,
    this.height = 56,
    this.overlayColor,
    this.backgroundColor,
    this.isNetworkImage = false,
    this.fit = BoxFit.cover,
    required this.image,
    this.padding = AppSizes.sm,
  });

  final BoxFit? fit;
  final String image;
  final bool isNetworkImage;
  final Color? overlayColor;
  final Color? backgroundColor;
  final double width, height, padding;

  @override
  Widget build(BuildContext context) {
    // Determine background color based on theme, if not provided
    final containerColor =
        backgroundColor ??
        (AppHelperFunctions.isDarkMode(context)
            ? AppColors.black
            : AppColors.white);

    // Calculate the size of the inner clipped area
    final innerSize = width - 2 * padding;

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: containerColor,
        // Using BoxShape.circle is the simplest way to enforce a circle shape
        shape: BoxShape.circle,
      ),

      // Use ClipOval for perfect circular clipping regardless of padding/size
      child: ClipOval(
        // The child is sized to fit the remaining space inside the padding
        child: SizedBox(
          width: innerSize,
          height: innerSize,
          child: isNetworkImage
              ? CachedNetworkImage(
                  imageUrl: image,
                  fit: fit, // Use the provided fit, usually BoxFit.cover
                  color: overlayColor,
                  progressIndicatorBuilder: (context, url, progress) =>
                      const AppShimmerEffect(
                        width: 55, // Adjusted to match the default width/height
                        height: 55,
                        radius: 55,
                      ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                )
              : Image(
                  fit: fit,
                  image: AssetImage(image) as ImageProvider,
                  color: overlayColor,
                ),
        ),
      ),
    );
  }
}
