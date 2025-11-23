// widgets/loading_overlay.dart
import 'package:flutter/material.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              'Loading Map...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.darkGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}