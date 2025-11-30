import 'package:flutter/material.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

class VoiceSearchOverlay extends StatelessWidget {
  final String speechText;
  final VoidCallback onStop;

  const VoiceSearchOverlay({
    super.key,
    required this.speechText,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return Positioned.fill(
      child: Container(
        color: AppColors.black.withValues(alpha: 0.7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Animated Voice Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryColor, width: 2),
              ),
              child: const Icon(Icons.mic, size: 50, color: AppColors.white),
            ),
            const SizedBox(height: AppSizes.lg),

            /// Listening Text
            Text(
              // 'Listening...',
              locale.listening,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: AppSizes.md),

            /// Speech Text
            if (speechText.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSizes.defaultSpace,
                ),
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                ),
                child: Text(
                  speechText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),

            const SizedBox(height: AppSizes.xl),

            /// Stop Button
            ElevatedButton(
              onPressed: onStop,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.xl,
                  vertical: AppSizes.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                ),
              ),
              // child: const Text('Stop Listening'),
              child: Text(locale.stopListening),
            ),
          ],
        ),
      ),
    );
  }
}
