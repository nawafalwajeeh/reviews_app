import 'package:flutter/material.dart';
import 'package:reviews_app/utils/constants/colors.dart';

class LabeledLocationPicker extends StatelessWidget {
  final String label;

  const LabeledLocationPicker({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {},
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tap to set location',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
                Icon(Icons.location_on_outlined, color: AppColors.primaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
