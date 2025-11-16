import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/loaders/circular_loader.dart';
import 'package:reviews_app/common/widgets/texts/section_heading.dart';
import 'package:reviews_app/data/repositories/address/address_repository.dart';
import 'package:reviews_app/features/personalization/models/address_model.dart';
import 'package:reviews_app/features/personalization/screens/address/add_new_address.dart';
import 'package:reviews_app/features/personalization/screens/address/widgets/single_address.dart';
import 'package:reviews_app/utils/constants/image_strings.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/cloud_helper_functions.dart';
import 'package:reviews_app/utils/helpers/network_manager.dart';
import 'package:reviews_app/utils/popups/full_screen_loader.dart';
import 'package:reviews_app/utils/popups/loaders.dart';

import '../../../utils/constants/colors.dart';
import '../../review/screens/map/map.dart';

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
        title: 'Address not found',
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
        // show warningSnackbar('No Internet Connection') by default
        // becuase the _connectivitySubscription still call _updateConnectionStatus again and again.
        return;
      }

      // Clear the 'selected' field
      if (selectedAddress.value.id.isNotEmpty) {
        await addressRepository.updateSelectedField(
          selectedAddress.value.id,
          false,
        );
      }

      // Assign selected address
      newSelectedAddress.selectedAddress = true;
      selectedAddress.value = newSelectedAddress;

      // set the 'selected' field to true for the newly selected address
      await addressRepository.updateSelectedField(
        selectedAddress.value.id,
        true,
      );
      // close the loading dialog after operation completed
      Get.back();
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: 'Error in Selection!',
        message: e.toString(),
      );
    }
  }

  /// Add new address
  Future<void> addNewAddress() async {
    try {
      // Start loader
      AppFullScreenLoader.openLoadingDialog(
        'Storing Address...',
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

      // Save address data
      final address = AddressModel(
        id: '',
        name: name.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        street: street.text.trim(),
        city: city.text.trim(),
        state: state.text.trim(),
        postalCode: postalCode.text.trim(),
        country: country.text.trim(),
        selectedAddress: true,
      );
      final id = await addressRepository.addAddress(address);

      // Update selected address status
      address.id = id;
      await selectAddress(address);

      // Remove Loader
      AppFullScreenLoader.stopLoading();

      // show success message
      AppLoaders.successSnackBar(
        title: 'Congratulations',
        message: 'your address has been saved successfully.',
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
        title: 'Address not found',
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
  void navigateToMapPicker() {
    // Use Get.to and then() to capture the returned value (the AddressModel)
    // The result is the AddressModel created in MapPickerScreen
    Get.to(() => MapScreen(isPickerMode: true))?.then((result) {
      if (result != null && result is AddressModel) {
        // Use the unified selectAddress function to update the selectedAddress.value
        selectAddress(result);
      }
    });
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
            AppSectionHeading(title: 'Select Address', showActionButton: false),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.map, color: AppColors.primaryColor),
                label: const Text('Pick Location on Map'),
                onPressed: () {
                  Get.back(); // Close the bottom sheet first
                  navigateToMapPicker(); // Navigate to the Map screen
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
                child: const Text('Add new address'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
