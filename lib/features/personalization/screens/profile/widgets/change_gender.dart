import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../../../../localization/app_localizations.dart';
import '../../../controllers/update_user_data_controller.dart';

class ChangeGender extends StatelessWidget {
  const ChangeGender({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateUserDataController());

    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          AppLocalizations.of(context).selectGender,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          children: [
            /// Gender Options
            Form(
              key: controller.updateUserGenderFormKey,
              child: Column(
                children: [
                  _buildGenderOption(
                    context,
                    AppLocalizations.of(context).male,
                    Iconsax.man,
                    controller,
                  ),
                  _buildGenderOption(
                    context,
                    AppLocalizations.of(context).female,
                    Iconsax.woman,
                    controller,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.spaceBtwSections),

            /// Save Button
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.selectedGender.value.isNotEmpty
                      ? () => controller.updateUserGender()
                      : null,
                  child: Text(AppLocalizations.of(context).save),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(
    BuildContext context,
    String gender,
    IconData icon,
    UpdateUserDataController controller,
  ) {
    return Obx(
      () => ListTile(
        leading: Icon(icon),
        title: Text(gender),
        trailing: controller.selectedGender.value == gender
            ? const Icon(Iconsax.tick_circle, color: Colors.green)
            : null,
        onTap: () => controller.setGender(gender),
      ),
    );
  }
}
