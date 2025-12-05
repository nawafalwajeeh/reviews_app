import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../controllers/place_controller.dart';
import '../../models/place_model.dart';
import 'widgets/custom_questions_section.dart';
import 'widgets/edit_photo_box.dart';
import 'widgets/place_form.dart';
import 'widgets/guid_lines_box.dart';

class EditPlaceScreen extends StatelessWidget {
  final PlaceModel place;

  const EditPlaceScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final controller = PlaceController.instance;

    // Initialize form with existing place data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializeEditForm(place);
    });

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          controller.clearEditForm();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: CustomAppBar(
            // title: Text('Edit Place'),
            title: Text(txt.editPlace),
            leadingIcon: Icons.clear,
            leadingOnPressed: () {
              controller.clearEditForm();
              Get.back();
            },
            actions: [
              IconButton(
                icon: Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.darkGrey,
                ),
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
                      // 'Edit Place',
                      txt.editPlace,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      // 'Update your place information',
                      txt.updatePlaceInfo,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceBtwItems),
                    EditPhotoBox(place: place),
                    const SizedBox(height: AppSizes.spaceBtwItems),
                    PlaceForm(isEditMode: true),
                    const SizedBox(height: AppSizes.spaceBtwItems),

                    const CustomQuestionsSection(),
                    const SizedBox(height: AppSizes.spaceBtwItems),
                    CommunityGuidelinesBox(),
                    const SizedBox(height: AppSizes.spaceBtwItems),

                    /// -- Update Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => controller.updatePlace(place.id),
                        // child: Text('Update Place'),
                        child: Text(txt.editPlace),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceBtwSections),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
