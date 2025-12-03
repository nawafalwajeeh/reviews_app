import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

class MapSearchContainer extends StatelessWidget {
  final String text;
  final Function(String) onChanged;
  final VoidCallback onVoiceSearch;
  final VoidCallback? onClear;
  final bool isListening;
  final TextEditingController? controller;

  const MapSearchContainer({
    super.key,
    required this.text,
    required this.onChanged,
    required this.onVoiceSearch,
    this.onClear,
    required this.isListening,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGrey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.black),
        decoration: InputDecoration(
          hintText: text,
          hintStyle: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.black),
          labelText: text,
          labelStyle: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.black),
          border: InputBorder.none,
          prefixIcon: Icon(Iconsax.search_normal, color: AppColors.darkerGrey),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller != null)
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller!,
                  builder: (context, value, child) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: Icon(Iconsax.close_circle, color: AppColors.dark),
                      onPressed: onClear,
                    );
                  },
                ),
              IconButton(
                icon: Icon(
                  isListening ? Iconsax.microphone_slash : Iconsax.microphone,
                  color: isListening ? AppColors.error : AppColors.primaryColor,
                ),
                onPressed: onVoiceSearch,
              ),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        ),
      ),
    );
  }
}
