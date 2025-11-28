import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/features/personalization/controllers/address_controller.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/validators/validation.dart';
import '../../../../localization/app_localizations.dart';
import '../../models/address_model.dart';

class AddNewAddressScreen extends StatelessWidget {
  const AddNewAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AddressController.instance;

    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(AppLocalizations.of(context).addNewAddress),
        actions: [
          // Map picker button in app bar
          IconButton(
            icon: Icon(Icons.map_outlined, color: AppColors.primaryColor),
            onPressed: () => _pickLocationFromMap(context, controller),
            tooltip: AppLocalizations.of(context).pickLocationFromMap,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Form(
          key: controller.addressFormKey,
          child: Column(
            children: [
              // Map Picked Location Display
              Obx(() => _buildMapLocationCard(context, controller)),
              const SizedBox(height: AppSizes.spaceBtwInputFields),

              TextFormField(
                controller: controller.name,
                validator: (value) => AppValidator.validateEmptyText(
                  AppLocalizations.of(context).name,
                  value,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(Iconsax.user),
                  labelText: AppLocalizations.of(context).addressName,
                  hintText: AppLocalizations.of(context).addressNameHint,
                ),
              ),
              const SizedBox(height: AppSizes.spaceBtwInputFields),
              TextFormField(
                controller: controller.phoneNumber,
                validator: (value) => AppValidator.validatePhoneNumber(value),
                decoration: InputDecoration(
                  prefixIcon: Icon(Iconsax.mobile),
                  labelText: AppLocalizations.of(context).phoneNumber,
                ),
              ),
              const SizedBox(height: AppSizes.spaceBtwInputFields),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.street,
                      validator: (value) => AppValidator.validateEmptyText(
                        AppLocalizations.of(context).street,
                        value,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Iconsax.building_31),
                        labelText: AppLocalizations.of(context).street,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceBtwInputFields),
                  Expanded(
                    child: TextFormField(
                      controller: controller.postalCode,
                      validator: (value) => AppValidator.validateEmptyText(
                        AppLocalizations.of(context).postalCode,
                        value,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Iconsax.code),
                        labelText: AppLocalizations.of(context).postalCode,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceBtwInputFields),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.city,
                      validator: (value) => AppValidator.validateEmptyText(
                        AppLocalizations.of(context).city,
                        value,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Iconsax.building),
                        labelText: AppLocalizations.of(context).city,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceBtwInputFields),
                  Expanded(
                    child: TextFormField(
                      controller: controller.state,
                      validator: (value) => AppValidator.validateEmptyText(
                        AppLocalizations.of(context).state,
                        value,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Iconsax.activity),
                        labelText: AppLocalizations.of(context).state,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceBtwInputFields),
              TextFormField(
                controller: controller.country,
                validator: (value) => AppValidator.validateEmptyText(
                  AppLocalizations.of(context).country,
                  value,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(Iconsax.global),
                  labelText: AppLocalizations.of(context).country,
                ),
              ),
              const SizedBox(height: AppSizes.defaultSpace),

              // Map Picker Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: Icon(Icons.map),
                  label: Text(AppLocalizations.of(context).pickLocationFromMap),
                  onPressed: () => _pickLocationFromMap(context, controller),
                ),
              ),
              const SizedBox(height: AppSizes.spaceBtwItems),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.addNewAddress(),
                  child: Text(AppLocalizations.of(context).saveAddress),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // And update the _buildMapLocationCard to auto-fill form fields when map address is selected
  Widget _buildMapLocationCard(
    BuildContext context,
    AddressController controller,
  ) {
    final selectedAddress = controller.selectedAddress.value;

    // Auto-fill form fields when map address is selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedAddress.id.startsWith('Map_')) {
        _autoFillFormFromMap(controller, selectedAddress);
      }
    });

    // Show card only if coordinates are set from map
    if (selectedAddress.latitude == 0.0 && selectedAddress.longitude == 0.0) {
      return const SizedBox();
    }

    return Card(
      color: AppColors.success.withValues(alpha: 0.1),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 20),
                const SizedBox(width: AppSizes.sm),
                Text(
                  AppLocalizations.of(context).locationFromMap,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, size: 18),
                  onPressed: () {
                    // Clear map-selected location
                    controller.selectedAddress.value = controller
                        .selectedAddress
                        .value
                        .copyWith(latitude: 0.0, longitude: 0.0);
                  },
                  tooltip: AppLocalizations.of(context).clearMapLocation,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),

            // Coordinates
            Text(
              AppLocalizations.of(context).coordinates,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              '${selectedAddress.latitude.toStringAsFixed(6)}, ${selectedAddress.longitude.toStringAsFixed(6)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: AppColors.darkGrey,
              ),
            ),

            // Auto-filled address if available
            if (selectedAddress.street.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    AppLocalizations.of(context).addressFromMap,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    selectedAddress.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _autoFillFormFromMap(
    AddressController controller,
    AddressModel mapAddress,
  ) {
    // Only auto-fill if fields are empty
    if (controller.street.text.isEmpty && mapAddress.street.isNotEmpty) {
      controller.street.text = mapAddress.street;
    }
    if (controller.city.text.isEmpty && mapAddress.city.isNotEmpty) {
      controller.city.text = mapAddress.city;
    }
    if (controller.country.text.isEmpty && mapAddress.country.isNotEmpty) {
      controller.country.text = mapAddress.country;
    }
    if (controller.name.text.isEmpty &&
        mapAddress.name.isNotEmpty &&
        mapAddress.name != 'N/A') {
      controller.name.text =
          '${AppLocalizations.of(Get.context!).mapLocation} ${DateTime.now().hour}:${DateTime.now().minute}';
    }
  }

  void _pickLocationFromMap(
    BuildContext context,
    AddressController controller,
  ) {
    // controller.navigateToMapPicker();
    controller.openLocationPicker();
  }
}

//---------------------------------------
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:reviews_app/common/widgets/appbar/appbar.dart';
// import 'package:reviews_app/features/personalization/controllers/address_controller.dart';
// import 'package:reviews_app/utils/constants/colors.dart';
// import 'package:reviews_app/utils/constants/sizes.dart';
// import 'package:reviews_app/utils/validators/validation.dart';

// import '../../models/address_model.dart';

// class AddNewAddressScreen extends StatelessWidget {
//   const AddNewAddressScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = AddressController.instance;

//     return Scaffold(
//       appBar: CustomAppBar(
//         showBackArrow: true,
//         title: const Text('Add New Address'),
//         actions: [
//           // Map picker button in app bar
//           IconButton(
//             icon: Icon(Icons.map_outlined, color: AppColors.primaryColor),
//             onPressed: () => _pickLocationFromMap(context, controller),
//             tooltip: 'Pick Location from Map',
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(AppSizes.defaultSpace),
//         child: Form(
//           key: controller.addressFormKey,
//           child: Column(
//             children: [
//               // Map Picked Location Display
//               Obx(() => _buildMapLocationCard(context, controller)),
//               const SizedBox(height: AppSizes.spaceBtwInputFields),

//               TextFormField(
//                 controller: controller.name,
//                 validator: (value) =>
//                     AppValidator.validateEmptyText('Name', value),
//                 decoration: const InputDecoration(
//                   prefixIcon: Icon(Iconsax.user),
//                   labelText: 'Address Name',
//                   hintText: 'Home, Work, Office, etc.',
//                 ),
//               ),
//               const SizedBox(height: AppSizes.spaceBtwInputFields),
//               TextFormField(
//                 controller: controller.phoneNumber,
//                 validator: (value) => AppValidator.validatePhoneNumber(value),
//                 decoration: const InputDecoration(
//                   prefixIcon: Icon(Iconsax.mobile),
//                   labelText: 'Phone Number',
//                 ),
//               ),
//               const SizedBox(height: AppSizes.spaceBtwInputFields),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: controller.street,
//                       validator: (value) =>
//                           AppValidator.validateEmptyText('Street', value),
//                       decoration: const InputDecoration(
//                         prefixIcon: Icon(Iconsax.building_31),
//                         labelText: 'Street',
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: AppSizes.spaceBtwInputFields),
//                   Expanded(
//                     child: TextFormField(
//                       controller: controller.postalCode,
//                       validator: (value) =>
//                           AppValidator.validateEmptyText('Postal Code', value),
//                       decoration: const InputDecoration(
//                         prefixIcon: Icon(Iconsax.code),
//                         labelText: 'Postal Code',
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: AppSizes.spaceBtwInputFields),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: controller.city,
//                       validator: (value) =>
//                           AppValidator.validateEmptyText('City', value),
//                       decoration: const InputDecoration(
//                         prefixIcon: Icon(Iconsax.building),
//                         labelText: 'City',
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: AppSizes.spaceBtwInputFields),
//                   Expanded(
//                     child: TextFormField(
//                       controller: controller.state,
//                       validator: (value) =>
//                           AppValidator.validateEmptyText('State', value),
//                       decoration: const InputDecoration(
//                         prefixIcon: Icon(Iconsax.activity),
//                         labelText: 'State',
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: AppSizes.spaceBtwInputFields),
//               TextFormField(
//                 controller: controller.country,
//                 validator: (value) =>
//                     AppValidator.validateEmptyText('Country', value),
//                 decoration: const InputDecoration(
//                   prefixIcon: Icon(Iconsax.global),
//                   labelText: 'Country',
//                 ),
//               ),
//               const SizedBox(height: AppSizes.defaultSpace),

//               // Map Picker Button
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton.icon(
//                   icon: const Icon(Icons.map),
//                   label: const Text('Pick Location from Map'),
//                   onPressed: () => _pickLocationFromMap(context, controller),
//                 ),
//               ),
//               const SizedBox(height: AppSizes.spaceBtwItems),

//               // Save Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () => controller.addNewAddress(),
//                   child: const Text('Save Address'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // And update the _buildMapLocationCard to auto-fill form fields when map address is selected
//   Widget _buildMapLocationCard(
//     BuildContext context,
//     AddressController controller,
//   ) {
//     final selectedAddress = controller.selectedAddress.value;

//     // Auto-fill form fields when map address is selected
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (selectedAddress.id.startsWith('Map_')) {
//         _autoFillFormFromMap(controller, selectedAddress);
//       }
//     });

//     // Show card only if coordinates are set from map
//     if (selectedAddress.latitude == 0.0 && selectedAddress.longitude == 0.0) {
//       return const SizedBox();
//     }

//     return Card(
//       color: AppColors.success.withValues(alpha: 0.1),
//       margin: EdgeInsets.zero,
//       child: Padding(
//         padding: const EdgeInsets.all(AppSizes.md),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.check_circle, color: AppColors.success, size: 20),
//                 const SizedBox(width: AppSizes.sm),
//                 Text(
//                   'Location from Map',
//                   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.success,
//                   ),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   icon: Icon(Icons.close, size: 18),
//                   onPressed: () {
//                     // Clear map-selected location
//                     controller.selectedAddress.value = controller
//                         .selectedAddress
//                         .value
//                         .copyWith(latitude: 0.0, longitude: 0.0);
//                   },
//                   tooltip: 'Clear map location',
//                 ),
//               ],
//             ),
//             const SizedBox(height: AppSizes.sm),

//             // Coordinates
//             Text(
//               'Coordinates:',
//               style: Theme.of(
//                 context,
//               ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
//             ),
//             const SizedBox(height: AppSizes.xs),
//             Text(
//               '${selectedAddress.latitude.toStringAsFixed(6)}, ${selectedAddress.longitude.toStringAsFixed(6)}',
//               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                 fontFamily: 'monospace',
//                 color: AppColors.darkGrey,
//               ),
//             ),

//             // Auto-filled address if available
//             if (selectedAddress.street.isNotEmpty)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: AppSizes.sm),
//                   Text(
//                     'Address from map:',
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: AppSizes.xs),
//                   Text(
//                     selectedAddress.toString(),
//                     style: Theme.of(context).textTheme.bodySmall,
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _autoFillFormFromMap(
//     AddressController controller,
//     AddressModel mapAddress,
//   ) {
//     // Only auto-fill if fields are empty
//     if (controller.street.text.isEmpty && mapAddress.street.isNotEmpty) {
//       controller.street.text = mapAddress.street;
//     }
//     if (controller.city.text.isEmpty && mapAddress.city.isNotEmpty) {
//       controller.city.text = mapAddress.city;
//     }
//     if (controller.country.text.isEmpty && mapAddress.country.isNotEmpty) {
//       controller.country.text = mapAddress.country;
//     }
//     if (controller.name.text.isEmpty &&
//         mapAddress.name.isNotEmpty &&
//         mapAddress.name != 'N/A') {
//       controller.name.text =
//           'Map Location ${DateTime.now().hour}:${DateTime.now().minute}';
//     }
//   }

//   void _pickLocationFromMap(
//     BuildContext context,
//     AddressController controller,
//   ) {
//     // controller.navigateToMapPicker();
//     controller.openLocationPicker();
//   }
// }
