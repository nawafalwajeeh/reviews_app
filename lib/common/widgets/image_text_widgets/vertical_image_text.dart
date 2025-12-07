import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/images/circular_image.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';

class AppVerticalImageText extends StatelessWidget {
  const AppVerticalImageText({
    super.key,
    required this.image,
    required this.title,
    this.textColor = AppColors.white,
    this.backgroundColor,
    this.isNetworkImage = false,
    this.onTap,
  });

  final String image, title;
  final Color textColor;
  final Color? backgroundColor;
  final bool isNetworkImage;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: AppSizes.spaceBtwItems),
        child: Column(
          children: [
            /// Circular Icon
            // Container(
            //   width: 56,
            //   height: 56,
            //   padding: const EdgeInsets.all(AppSizes.sm),
            //   decoration: BoxDecoration(
            //     color:
            //         backgroundColor ??
            //         (dark ? AppColors.black : AppColors.white),
            //     borderRadius: BorderRadius.circular(100),
            //   ),
            //   child: Center(
            //     child: isNetworkImage
            //         ? CachedNetworkImage(
            //             fit: BoxFit.cover,
            //             imageUrl: image,
            //             color: (dark ? AppColors.light : AppColors.dark),
            //           )
            //         : Image(
            //             image: AssetImage(image) as ImageProvider,
            //             fit: BoxFit.cover,
            //             color: (dark ? AppColors.light : AppColors.dark),
            //           ),
            //   ),
            // ),
            AppCircularImage(
              image: image,
              fit: BoxFit.fitWidth,
              padding: AppSizes.sm * 1.4,
              isNetworkImage: isNetworkImage,
              backgroundColor: backgroundColor,
              overlayColor: dark ? AppColors.light : AppColors.dark,
            ),

            /// Text
            const SizedBox(height: AppSizes.spaceBtwItems / 2),
            SizedBox(
              width: 55,
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.apply(color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
