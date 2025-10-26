import 'package:flutter/material.dart';
import 'package:reviews_app/utils/constants/colors.dart';

import '../../../../../utils/constants/sizes.dart';
// import 'package:reviews_app/utils/constants/colors.dart';

class AddPhotoBox extends StatelessWidget {
  const AddPhotoBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(AppSizes.spaceBtwItems),
        border: Border.all(color: Theme.of(context).dividerColor, width: 2),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Color(0x1A000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              color: AppColors.primaryColor,
              size: 48,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Add Photos',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.primaryColor),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Upload up to 5 photos of this place',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).hintColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
