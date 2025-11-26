import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/validators/validation.dart';
import '../../../controllers/update_user_data_controller.dart';

class ChangeUsername extends StatelessWidget {
  const ChangeUsername({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateUserDataController());

    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          'Change Username',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Headings
            Text(
              'Choose a unique username that represents you.',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: AppSizes.spaceBtwSections),

            /// Text Field and button
            Form(
              key: controller.updateUserUsernameFormKey,
              child: TextFormField(
                controller: controller.username,
                validator: (value) => AppValidator.validateEmptyText(
                  'Username',
                  value,
                ),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Iconsax.user_edit),
                  labelText: 'Username',
                  hintText: 'e.g., john_doe123',
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spaceBtwSections),

            /// Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.updateUserUsername(),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}