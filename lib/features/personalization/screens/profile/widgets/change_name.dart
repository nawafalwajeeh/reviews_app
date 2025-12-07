import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/validators/validation.dart';
import '../../../../../localization/app_localizations.dart';
import '../../../controllers/update_user_data_controller.dart';

class ChangeName extends StatelessWidget {
  const ChangeName({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateUserDataController());

    return Scaffold(
      /// CustomAppBar
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          AppLocalizations.of(context).changeName,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Headings
            Text(
              AppLocalizations.of(context).useRealNameForVerification,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: AppSizes.spaceBtwSections),

            /// Text Field and button
            Form(
              key: controller.updateUserNameFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: controller.firstName,
                    validator: (value) => AppValidator.validateEmptyText(
                      AppLocalizations.of(context).firstName,
                      value,
                    ),
                    expands: false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Iconsax.user),
                      labelText: AppLocalizations.of(context).firstName,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwInputFields),
                  TextFormField(
                    controller: controller.lastName,
                    validator: (value) => AppValidator.validateEmptyText(
                      AppLocalizations.of(context).lastName,
                      value,
                    ),
                    expands: false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Iconsax.user),
                      labelText: AppLocalizations.of(context).lastName,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.spaceBtwSections),

            /// Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.updateUserName(),
                child: Text(AppLocalizations.of(context).save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
