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
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (AppHelperFunctions.isDarkMode(context)
                ? AppColors.black
                : AppColors.white),
        borderRadius: BorderRadius.circular(100),
      ),

      child: isNetworkImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Center(
                child:
                    // child: Image(
                    //   fit: fit,
                    //   image: isNetworkImage
                    //       ? NetworkImage(image)
                    //       : AssetImage(image) as ImageProvider,
                    //   color: overlayColor,
                    // ),
                    CachedNetworkImage(
                      fit: fit,
                      color: overlayColor,
                      progressIndicatorBuilder: (context, url, progress) =>
                          const AppShimmerEffect(
                            width: 55,
                            height: 55,
                            radius: 55,
                          ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      imageUrl: image,
                    ),
              ),
            )
          : Image(
              fit: fit,
              image:
                  //  isNetworkImage
                  //     ? NetworkImage(image)
                  // :
                  AssetImage(image) as ImageProvider,
              color: overlayColor,
            ),
    );
  }
}
