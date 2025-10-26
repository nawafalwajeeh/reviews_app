import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/features/personalization/controllers/address_controller.dart';
import 'package:reviews_app/features/personalization/models/address_model.dart';
import 'package:reviews_app/features/personalization/screens/address/widgets/single_address.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

import 'add_new_address.dart';

class UserAddressScreen extends StatelessWidget {
  const UserAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AddressController.instance;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: () => Get.to(() => const AddNewAddressScreen()),
        child: const Icon(Iconsax.add, color: AppColors.white),
      ),
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          'Addresses',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.defaultSpace),
          child: Obx(
            () => FutureBuilder(
              // Use key to trigger refresh
              key: Key(controller.refreshData.value.toString()),
              future: controller.getAllUserAddresses(),
              builder: (context, snapshot) {
                // final response = AppCloudHelperFunctions.checkMultiRecordState(
                //   snapshot: snapshot,
                // );
                // if (response != null) return response;

                // /// data found
                // final addresses = snapshot.data!;

                return ListView.builder(
                  // itemCount: addresses.length,
                  itemCount: 1,
                  shrinkWrap: true,
                  itemBuilder: (context, index) => SingleAddress(
                    address: AddressModel.empty(),
                    // address: addresses[index],
                    // onTap: () => controller.selectAddress(addresses[index]),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
