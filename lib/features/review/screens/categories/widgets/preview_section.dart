import 'package:flutter/material.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

import 'preview_content.dart';

class PreviewSection extends StatelessWidget {
  final String icon;
  final Color color;
  final String name;
  final String description;

  const PreviewSection({super.key, 
    required this.icon,
    required this.color,
    required this.name,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PreviewContent(
              icon: icon,
              color: color,
              name: name.isEmpty ? 'Category' : name,
              description: description.isEmpty
                  ? 'Places to dine and eat'
                  : description,
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            Text(
              'PREVIEW',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

