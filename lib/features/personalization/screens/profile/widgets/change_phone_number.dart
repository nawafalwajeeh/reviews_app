import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/validators/validation.dart';
import '../../../../../localization/app_localizations.dart';
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
          AppLocalizations.of(context).changePhoneNumber,
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
              AppLocalizations.of(context).addPhoneForVerification,
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
                decoration: InputDecoration(
                  prefixIcon: Icon(Iconsax.call),
                  labelText: AppLocalizations.of(context).phoneNumber,
                  hintText: AppLocalizations.of(context).phoneNumberHint,
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spaceBtwSections),

            /// Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.updateUserPhone(),
                child: Text(AppLocalizations.of(context).save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
