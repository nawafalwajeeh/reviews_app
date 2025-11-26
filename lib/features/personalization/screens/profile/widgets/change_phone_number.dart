import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/validators/validation.dart';
import '../../../controllers/update_user_data_controller.dart';

class ChangePhone extends StatelessWidget {
  const ChangePhone({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateUserDataController());

    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          'Change Phone Number',
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
              'Add your phone number for verification and contact purposes.',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: AppSizes.spaceBtwSections),

            /// Text Field and button
            Form(
              key: controller.updateUserPhoneFormKey,
              child: TextFormField(
                controller: controller.phoneNumber,
                validator: (value) => AppValidator.validatePhoneNumber(value),
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Iconsax.call),
                  labelText: 'Phone Number',
                  hintText: 'e.g., +967 234 567 8900',
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spaceBtwSections),

            /// Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.updateUserPhone(),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
