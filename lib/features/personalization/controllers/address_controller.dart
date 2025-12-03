import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/loaders/circular_loader.dart';
import 'package:reviews_app/common/widgets/texts/section_heading.dart';
import 'package:reviews_app/data/repositories/address/address_repository.dart';
import 'package:reviews_app/features/personalization/models/address_model.dart';
import 'package:reviews_app/features/personalization/screens/address/add_new_address.dart';
import 'package:reviews_app/features/personalization/screens/address/widgets/single_address.dart';
import 'package:reviews_app/features/review/screens/map/place_map.dart';
import 'package:reviews_app/localization/app_localizations.dart' show txt;
// import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/image_strings.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/cloud_helper_functions.dart';
import 'package:reviews_app/utils/helpers/network_manager.dart';
import 'package:reviews_app/utils/popups/full_screen_loader.dart';
import 'package:reviews_app/utils/popups/loaders.dart';

import '../../../utils/constants/colors.dart';

class AddressController extends GetxController {
  static AddressController get instance => Get.find();

  /// Variables
  final name = TextEditingController();
  final phoneNumber = TextEditingController();
  final street = TextEditingController();
  final postalCode = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final country = TextEditingController();
  GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();
  final refreshData = true.obs;
  final Rx<AddressModel> selectedAddress = AddressModel.empty().obs;
  final addressRepository = Get.put(AddressRepository());
  final RxList<AddressModel> allUserAddresses = <AddressModel>[].obs;

  /// Fetch all user specific addresses
  Future<List<AddressModel>> getAllUserAddresses() async {
    try {
      final addresses = await addressRepository.fetchUserAddresses();
      // Update the observable list in the controller
      allUserAddresses.assignAll(addresses);
      selectedAddress.value = addresses.firstWhere(
        (element) => element.selectedAddress,
        orElse: () => AddressModel.empty(),
      );
      return addresses;
    } catch (e) {
      AppLoaders.errorSnackBar(
        // title: 'Address not found',
        title: txt.addressNotFound,
        message: e.toString(),
      );
      return [];
    }
  }

  /// Select specific address and update in the firestore and ui
  Future<void> selectAddress(AddressModel newSelectedAddress) async {
    try {
      // Start circular loader
      Get.defaultDialog(
        title: '',
        onWillPop: () async => false,
        barrierDismissible: false,
        backgroundColor: Colors.transparent,
        content: const AppCircularLoader(),
      );

      // Check Internet Connectivity
      final isConnected = await AppNetworkManager.instance.isConnected();
      if (!isConnected) {
        Get.back();
        return;
      }

      // --Only update Firestore for addresses that exist in Firestore ---
      if (selectedAddress.value.id.isNotEmpty &&
          !selectedAddress.value.id.startsWith('Map_')) {
        // Clear the 'selected' field only for existing Firestore addresses
        await addressRepository.updateSelectedField(
          selectedAddress.value.id,
          false,
        );
      }

      // Assign selected address
      newSelectedAddress.selectedAddress = true;
      selectedAddress.value = newSelectedAddress;

      // --Only update Firestore for addresses that exist in Firestore ---
      if (!newSelectedAddress.id.startsWith('Map_')) {
        // set the 'selected' field to true for the newly selected address
        await addressRepository.updateSelectedField(
          newSelectedAddress.id,
          true,
        );
      }

      // close the loading dialog after operation completed
      Get.back();

      // Show success message
      AppLoaders.successSnackBar(
        // title: 'Location Selected',
        title: txt.locationSelected,
        message: newSelectedAddress.id.startsWith('Map_')
            // ? 'Map location selected successfully'
            // : 'Address selected successfully',
            ? txt.mapLocationSelected
            : txt.addressSelected,
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      AppLoaders.errorSnackBar(
        // title: 'Error in Selection!',
        title: txt.error,
        message: e.toString(),
      );
    }
  }

  /// Add new address
  Future<void> addNewAddress() async {
    try {
      // Start loader
      AppFullScreenLoader.openLoadingDialog(
        // 'Storing Address...',
        txt.storingAddress,
        AppImages.docerAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await AppNetworkManager.instance.isConnected();
      if (!isConnected) {
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Check Form validation
      if (!addressFormKey.currentState!.validate()) {
        AppFullScreenLoader.stopLoading();
        return;
      }

      // --Handle map addresses properly ---
      final bool isMapAddress = selectedAddress.value.id.startsWith('Map_');

      // Save address data - use coordinates from map if available
      final address = AddressModel(
        id: isMapAddress
            ? ''
            : selectedAddress
                  .value
                  .id, // Clear ID for map addresses to create new
        name: name.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        street: street.text.trim(),
        city: city.text.trim(),
        state: state.text.trim(),
        postalCode: postalCode.text.trim(),
        country: country.text.trim(),
        selectedAddress: true,
        // Use coordinates from map if available, otherwise default to 0.0
        latitude: isMapAddress ? selectedAddress.value.latitude : 0.0,
        longitude: isMapAddress ? selectedAddress.value.longitude : 0.0,
      );

      final id = await addressRepository.addAddress(address);

      // Update selected address status with the new Firestore ID
      address.id = id;
      await selectAddress(address);

      // Remove Loader
      AppFullScreenLoader.stopLoading();

      // show success message
      AppLoaders.successSnackBar(
        // title: 'Congratulations',
        title: txt.success,
        // message: 'Your address has been saved successfully.',
        message: txt.yourAddressHasBeenSaved,
      );

      // Refresh Address data
      refreshData.toggle();

      // Reset Fields
      resetFormFields();

      // Redirect to the previous screen
      Navigator.of(Get.context!).pop();
    } catch (e) {
      AppFullScreenLoader.stopLoading();
      AppLoaders.errorSnackBar(
        // title: 'Address not found',
        title: txt.addressNotFound,
        message: e.toString(),
      );
    }
  }

  /// Function to reset form fields
  void resetFormFields() {
    name.clear();
    phoneNumber.clear();
    street.clear();
    postalCode.clear();
    city.clear();
    state.clear();
    country.clear();
    addressFormKey.currentState?.reset();
  }

  /// Navigates to the Map Picker Screen and processes the result.
  void openLocationPicker() async {
    await PlacesMapScreen.openLocationPicker().then((result) {
      if (result != null) {
        if (result.id.startsWith('Map_')) {
          // Use separate method for map addresses
          selectMapAddress(result);
        } else {
          // Use regular method for Firestore addresses
          selectAddress(result);
        }
      }
    });
  }

  /// Handle map address selection separately
  Future<void> selectMapAddress(AddressModel mapAddress) async {
    try {
      // Simply update the selected address without Firestore operations
      selectedAddress.value = mapAddress;

      // Show success message
      AppLoaders.successSnackBar(
        // title: 'Map Location Selected',
        title: txt.mapLocationSelected,
        // message:
        //     'Map location has been selected. Save the address to persist it.',
        message: txt.mapLocationSelected,
      );
    } catch (e) {
      AppLoaders.errorSnackBar(
        // title: 'Error selecting map location',
        title: txt.error,
        message: e.toString(),
      );
    }
  }

  /// Show adresses ModalBottomSheet on Checkout
  Future<void> selectNewAddressPopup(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        height: MediaQuery.of(context).size.height * 0.6,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AppSectionHeading(title: 'Select Address', showActionButton: false),
            AppSectionHeading(
              title: txt.selectAddress,
              showActionButton: false,
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.map, color: AppColors.primaryColor),
                // label: const Text('Pick Location on Map'),
                label: Text(txt.pickLocationFromMap),
                onPressed: () {
                  Get.back(); // Close the bottom sheet first
                  // navigateToMapPicker(); // Navigate to the Map screen
                  openLocationPicker();
                },
              ),
            ),
            // const SizedBox(height: AppSizes.spaceBtwSections),
            Expanded(
              child: FutureBuilder(
                future: getAllUserAddresses(),
                builder: (_, snapshot) {
                  /// handle loader, no record, or error message
                  final response =
                      AppCloudHelperFunctions.checkMultiRecordState(
                        snapshot: snapshot,
                      );
                  if (response != null) return response;

                  final addresses = snapshot.data!;

                  return ListView.builder(
                    itemCount: addresses.length,
                    shrinkWrap: true,
                    itemBuilder: (_, index) => SingleAddress(
                      address: addresses[index],
                      onTap: () async {
                        await selectAddress(addresses[index]);
                        Get.back();
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSizes.defaultSpace * 2),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.to(() => const AddNewAddressScreen()),
                // child: const Text('Add new address'),
                child: Text(txt.addNewAddress),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Update address form with coordinates from map
  void updateAddressWithMapCoordinates(AddressModel mapAddress) {
    // Update the selected address with map coordinates
    selectedAddress.value = mapAddress;

    // Auto-fill form fields if they're empty and map provides address data
    if (name.text.isEmpty &&
        mapAddress.name.isNotEmpty &&
        mapAddress.name != 'N/A') {
      name.text = mapAddress.name;
    }

    if (street.text.isEmpty && mapAddress.street.isNotEmpty) {
      street.text = mapAddress.street;
    }

    if (city.text.isEmpty && mapAddress.city.isNotEmpty) {
      city.text = mapAddress.city;
    }

    if (country.text.isEmpty && mapAddress.country.isNotEmpty) {
      country.text = mapAddress.country;
    }

    // Show success message
    Get.snackbar(
      // 'Location Selected',
      // 'Coordinates have been set from map',
      txt.locationSelected,
      txt.locationCoordinates,
      backgroundColor: AppColors.success.withValues(alpha: 0.9),
      colorText: AppColors.white,
    );
  }
}
