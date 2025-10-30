import 'package:flutter/material.dart';

class AddNewCategoryScreen extends StatelessWidget {
  static const String routeName = 'CreateCategoryScreen';
  static const String routePath = '/createCategoryScreen';

  const AddNewCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context),
      body: SafeArea(child: CreateCategoryContent()),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      automaticallyImplyLeading: false,
      leading: _AppBarIconButton(
        icon: Icons.arrow_back_rounded,
        onPressed: () => _handleBackPressed(),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _AppBarIconButton(
            icon: Icons.help_outline_rounded,
            onPressed: () => _handleHelpPressed(),
          ),
        ),
      ],
      elevation: 0,
    );
  }

  void _handleBackPressed() {
    debugPrint('Back button pressed');
  }

  void _handleHelpPressed() {
    debugPrint('Help button pressed');
  }
}

class CreateCategoryContent extends StatelessWidget {
  CreateCategoryContent({super.key});

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  final _descriptionController = TextEditingController();

  final String _selectedIcon = 'restaurant';

  final Color _selectedColor = Colors.blue;

  // @override
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 32),
            const _HeaderSection(),
            const SizedBox(height: 32),
            _IconSelectionSection(
              selectedIcon: _selectedIcon,
              // onIconSelected: (icon) => setState(() => _selectedIcon = icon),
              onIconSelected: (icon) {},
            ),
            const SizedBox(height: 24),
            _NameInputSection(controller: _nameController),
            const SizedBox(height: 24),
            _DescriptionInputSection(controller: _descriptionController),
            const SizedBox(height: 24),
            _ColorSelectionSection(
              selectedColor: _selectedColor,
              onColorSelected: (value) {},
              // onColorSelected: (color) => setState(() => _selectedColor = color),
            ),
            const SizedBox(height: 24),
            _PreviewSection(
              icon: _selectedIcon,
              color: _selectedColor,
              name: _nameController.text,
              description: _descriptionController.text,
            ),
            const SizedBox(height: 24),
            _CreateButton(
              // onPressed: _handleCreateCategory,
              onPressed: () {},
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_HeaderTitle(), SizedBox(height: 8), _HeaderSubtitle()],
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Create Category',
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _HeaderSubtitle extends StatelessWidget {
  const _HeaderSubtitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Add a new place category to organize your locations',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }
}

class _IconSelectionSection extends StatelessWidget {
  final String selectedIcon;
  final ValueChanged<String> onIconSelected;

  const _IconSelectionSection({
    required this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('CATEGORY ICON'),
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
                (iconData) => _IconOption(
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
                (iconData) => _IconOption(
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

class _IconOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _IconOption({
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
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
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
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            size: 32,
          ),
        ),
      ),
    );
  }
}

class _NameInputSection extends StatelessWidget {
  final TextEditingController controller;

  const _NameInputSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('CATEGORY NAME'),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'Enter category name',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          style: Theme.of(context).textTheme.bodyLarge,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a category name';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class _DescriptionInputSection extends StatelessWidget {
  final TextEditingController controller;

  const _DescriptionInputSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('DESCRIPTION'),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          maxLines: 3,
          minLines: 3,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            hintText: 'Add a brief description (optional)',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
        ),
      ],
    );
  }
}

class _ColorSelectionSection extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const _ColorSelectionSection({
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.purple,
      Colors.blueGrey,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('COLOR THEME'),
        const SizedBox(height: 12),
        Row(
          children: colors
              .map(
                (color) => _ColorOption(
                  color: color,
                  isSelected: selectedColor == color,
                  onSelected: () => onColorSelected(color),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onSelected;

  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        width: 48,
        height: 48,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 3,
                )
              : null,
        ),
        child: isSelected
            ? Icon(
                Icons.check_rounded,
                color: Theme.of(context).colorScheme.surface,
                size: 20,
              )
            : null,
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  final String icon;
  final Color color;
  final String name;
  final String description;

  const _PreviewSection({
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
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _PreviewContent(
              icon: icon,
              color: color,
              name: name.isEmpty ? 'Restaurants' : name,
              description: description.isEmpty
                  ? 'Places to dine and eat'
                  : description,
            ),
            const SizedBox(height: 16),
            _PreviewLabel(),
          ],
        ),
      ),
    );
  }
}

class _PreviewContent extends StatelessWidget {
  final String icon;
  final Color color;
  final String name;
  final String description;

  const _PreviewContent({
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
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getIconFromLabel(icon), color: color, size: 24),
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
                  ).colorScheme.onSurface.withOpacity(0.6),
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

class _PreviewLabel extends StatelessWidget {
  const _PreviewLabel();

  @override
  Widget build(BuildContext context) {
    return Text(
      'PREVIEW',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        letterSpacing: 1,
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CreateButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          'Create Category',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 1,
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _AppBarIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(44, 44),
      ),
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurface,
        size: icon == Icons.arrow_back_rounded ? 24 : 20,
      ),
    );
  }
}
