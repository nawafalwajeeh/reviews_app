import 'package:flutter/material.dart';

import 'section_title.dart';

class IconSelectionSection extends StatelessWidget {
  final String selectedIcon;
  final ValueChanged<String> onIconSelected;

  const IconSelectionSection({super.key, 
    required this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle('CATEGORY ICON'),
        const SizedBox(height: 12),
        _IconGrid(selectedIcon: selectedIcon, onIconSelected: onIconSelected),
      ],
    );
  }
}

class _IconGrid extends StatelessWidget {
  final String selectedIcon;
  final ValueChanged<String> onIconSelected;

  const _IconGrid({required this.selectedIcon, required this.onIconSelected});

  @override
  Widget build(BuildContext context) {
    final icons = [
      _IconData('restaurant', Icons.restaurant_rounded),
      _IconData('cafe', Icons.local_cafe_rounded),
      _IconData('shopping', Icons.shopping_bag_rounded),
      _IconData('hospital', Icons.local_hospital_rounded),
      _IconData('school', Icons.school_rounded),
      _IconData('fitness', Icons.fitness_center_rounded),
      _IconData('gas', Icons.local_gas_station_rounded),
      _IconData('movie', Icons.movie_rounded),
    ];

    return Column(
      children: [
        Row(
          children: icons
              .sublist(0, 4)
              .map(
                (iconData) => IconOption(
                  icon: iconData.icon,
                  label: iconData.label,
                  isSelected: selectedIcon == iconData.label,
                  onSelected: () => onIconSelected(iconData.label),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: icons
              .sublist(4)
              .map(
                (iconData) => IconOption(
                  icon: iconData.icon,
                  label: iconData.label,
                  isSelected: selectedIcon == iconData.label,
                  onSelected: () => onIconSelected(iconData.label),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _IconData {
  final String label;
  final IconData icon;

  const _IconData(this.label, this.icon);
}

class IconOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const IconOption({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onSelected,
        child: Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Icon(
            icon,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
            size: 32,
          ),
        ),
      ),
    );
  }
}
