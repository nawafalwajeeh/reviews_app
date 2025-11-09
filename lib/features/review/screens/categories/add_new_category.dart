import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart'
    show CustomAppBar;
import 'package:reviews_app/utils/constants/sizes.dart';

import 'widgets/add_category_form.dart';
import 'widgets/header_section.dart';
import 'widgets/icon_selection_section.dart';
import 'widgets/preview_section.dart';

class AddNewCategoryScreen extends StatelessWidget {
  const AddNewCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // appBar: _buildAppBar(context),
      appBar: CustomAppBar(showBackArrow: true),
      body: SafeArea(child: CreateCategoryContent()),
    );
  }
}

class CreateCategoryContent extends StatelessWidget {
  CreateCategoryContent({super.key});

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  final _descriptionController = TextEditingController();

  final String _selectedIcon = 'new_Category';

  final Color _selectedColor = Colors.blue;

  // @override
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: AppSizes.spaceBtwSections),
            const HeaderSection(),
            const SizedBox(height: AppSizes.spaceBtwSections),
            IconSelectionSection(
              selectedIcon: _selectedIcon,
              onIconSelected: (icon) {},
            ),
            const SizedBox(height: AppSizes.defaultSpace),
            AddCategoryForm(),
            const SizedBox(height: AppSizes.defaultSpace),
            const SizedBox(height: AppSizes.defaultSpace),

            const SizedBox(height: AppSizes.defaultSpace),
            PreviewSection(
              icon: _selectedIcon,
              color: _selectedColor,
              name: _nameController.text,
              description: _descriptionController.text,
            ),
            const SizedBox(height: AppSizes.defaultSpace),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: Text('Create Category'),
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }
}
