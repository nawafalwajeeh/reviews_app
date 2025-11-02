import 'package:flutter/material.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

class PreviewContent extends StatelessWidget {
  final String icon;
  final Color color;
  final String name;
  final String description;

  const PreviewContent({
    super.key,
    required this.icon,
    required this.color,
    required this.name,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getIconFromLabel(icon),
            color: color,
            size: AppSizes.iconMd,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIconFromLabel(String label) {
    final iconMap = {
      'restaurant': Icons.restaurant_rounded,
      'cafe': Icons.local_cafe_rounded,
      'shopping': Icons.shopping_bag_rounded,
      'hospital': Icons.local_hospital_rounded,
      'school': Icons.school_rounded,
      'fitness': Icons.fitness_center_rounded,
      'gas': Icons.local_gas_station_rounded,
      'movie': Icons.movie_rounded,
    };
    return iconMap[label] ?? Icons.category_rounded;
  }
}