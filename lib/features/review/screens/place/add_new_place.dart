import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../controllers/place_controller.dart';
import 'widgets/add_photo_box.dart';
import 'widgets/custom_questions_section.dart';
import 'widgets/place_form.dart';
import 'widgets/guid_lines_box.dart';

class AddNewPlaceScreen extends StatelessWidget {
  const AddNewPlaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = PlaceController.instance;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(
          leadingIcon: Icons.clear,
          leadingOnPressed: () => Get.back(),
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline_rounded, color: AppColors.darkGrey),
              onPressed: () {},
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.defaultSpace,
            ),
            child: Form(
              key: controller.placeFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  Text(
                    'Create New Place',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'Share your favorite spot with the community',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  AddPhotoBox(),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  PlaceForm(),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  // Custom Questions Section
                  CustomQuestionsSection(),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  CommunityGuidelinesBox(),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  /// -- Create Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller.createPlace(),
                      child: Text('Create Place'),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwSections),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
