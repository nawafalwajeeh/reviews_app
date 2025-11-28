
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../../../../localization/app_localizations.dart';
import '../../../controllers/update_user_data_controller.dart';


class ChangeBirthDate extends StatelessWidget {
  const ChangeBirthDate({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateUserDataController());

    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          AppLocalizations.of(context).selectBirthDate,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          children: [
            /// Date Picker
            Form(
              key: controller.updateUserBirthDateFormKey,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Iconsax.calendar),
                    title: Text(AppLocalizations.of(context).selectBirthDate),
                    subtitle: Obx(
                      () => Text(
                        controller.selectedBirthDate.value != null
                            ? '${AppLocalizations.of(context).selected}: ${_formatDate(controller.selectedBirthDate.value!)}'
                            : AppLocalizations.of(context).noDateSelected,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Iconsax.calendar_edit),
                      onPressed: () => _selectDate(context, controller),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  Obx(
                    () => controller.selectedBirthDate.value != null
                        ? OutlinedButton(
                            onPressed: () => controller.clearBirthDate(),
                            child: Text(AppLocalizations.of(context).clearSelection),
                          )
                        : const SizedBox(),
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
                  onPressed: controller.selectedBirthDate.value != null
                      ? () => controller.updateUserBirthDate()
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

  Future<void> _selectDate(
    BuildContext context,
    UpdateUserDataController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedBirthDate.value ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != controller.selectedBirthDate.value) {
      controller.setBirthDate(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}




//-------------------------
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:reviews_app/common/widgets/appbar/appbar.dart';
// import 'package:reviews_app/utils/constants/sizes.dart';

// import '../../../controllers/update_user_data_controller.dart';

// class ChangeBirthDate extends StatelessWidget {
//   const ChangeBirthDate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(UpdateUserDataController());

//     return Scaffold(
//       appBar: CustomAppBar(
//         showBackArrow: true,
//         title: Text(
//           'Select Birth Date',
//           style: Theme.of(context).textTheme.headlineSmall,
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(AppSizes.defaultSpace),
//         child: Column(
//           children: [
//             /// Date Picker
//             Form(
//               key: controller.updateUserBirthDateFormKey,
//               child: Column(
//                 children: [
//                   ListTile(
//                     leading: const Icon(Iconsax.calendar),
//                     title: const Text('Select Birth Date'),
//                     subtitle: Obx(
//                       () => Text(
//                         controller.selectedBirthDate.value != null
//                             ? 'Selected: ${_formatDate(controller.selectedBirthDate.value!)}'
//                             : 'No date selected',
//                       ),
//                     ),
//                     trailing: IconButton(
//                       icon: const Icon(Iconsax.calendar_edit),
//                       onPressed: () => _selectDate(context, controller),
//                     ),
//                   ),
//                   const SizedBox(height: AppSizes.spaceBtwItems),
//                   Obx(
//                     () => controller.selectedBirthDate.value != null
//                         ? OutlinedButton(
//                             onPressed: () => controller.clearBirthDate(),
//                             child: const Text('Clear Selection'),
//                           )
//                         : const SizedBox(),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: AppSizes.spaceBtwSections),

//             /// Save Button
//             SizedBox(
//               width: double.infinity,
//               child: Obx(
//                 () => ElevatedButton(
//                   onPressed: controller.selectedBirthDate.value != null
//                       ? () => controller.updateUserBirthDate()
//                       : null,
//                   child: const Text('Save'),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _selectDate(
//     BuildContext context,
//     UpdateUserDataController controller,
//   ) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: controller.selectedBirthDate.value ?? DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );
    
//     if (picked != null && picked != controller.selectedBirthDate.value) {
//       controller.setBirthDate(picked);
//     }
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }