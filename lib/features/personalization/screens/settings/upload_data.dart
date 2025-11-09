import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../review/controllers/upload_data_controller.dart';
// import '../../controllers/upload_data_controller.dart';

class UploadDataScreen extends StatelessWidget {
  const UploadDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UploadDataController());
    return Scaffold(
      appBar: const CustomAppBar(
        title: Text('Upload Data'),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// -- Body
            Padding(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionHeading(
                    title: 'Main Record',
                    showActionButton: false,
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  ListTile(
                    leading: const Icon(
                      Iconsax.category,
                      size: 28,
                      color: AppColors.primaryColor,
                    ),
                    title: Text(
                      'Upload Categories',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: IconButton(
                      onPressed: () => controller.uploadCategories(),
                      // onPressed: (){},
                      icon: const Icon(
                        Iconsax.arrow_up_1,
                        size: 28,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  ListTile(
                    leading: const Icon(
                      Iconsax.shop,
                      size: 28,
                      color: AppColors.primaryColor,
                    ),
                    title: Text(
                      'Upload Brands',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: IconButton(
                      onPressed: (){},
                      // onPressed: () => controller.uploadBrands(),
                      icon: const Icon(
                        Iconsax.arrow_up_1,
                        size: 28,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  ListTile(
                    leading: const Icon(
                      Iconsax.shopping_cart,
                      size: 28,
                      color: AppColors.primaryColor,
                    ),
                    title: Text(
                      'Upload Products',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: IconButton(
                      onPressed: (){},
                      // onPressed: () => controller.uploadProducts(),
                      icon: const Icon(
                        Iconsax.arrow_up_1,
                        size: 28,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  ListTile(
                    leading: const Icon(
                      Iconsax.image,
                      size: 28,
                      color: AppColors.primaryColor,
                    ),
                    title: Text(
                      'Upload Banners',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: IconButton(
                      onPressed: (){},
                      // onPressed: () => controller.uploadBanners(),
                      icon: const Icon(
                        Iconsax.arrow_up_1,
                        size: 28,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwSections),
                  const AppSectionHeading(
                    title: 'Relationships',
                    showActionButton: false,
                  ),
                  const Text(
                    'Make sure you have already uploaded all the content above.',
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  ListTile(
                    leading: const Icon(
                      Iconsax.link,
                      size: 28,
                      color: AppColors.primaryColor,
                    ),
                    title: Text(
                      'Upload Brands & Categories Relation Data',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: IconButton(
                      onPressed: (){},
                      // onPressed: () => controller.uploadBrandCategory(),
                      icon: const Icon(
                        Iconsax.arrow_up_1,
                        size: 28,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  ListTile(
                    leading: const Icon(
                      Iconsax.link,
                      size: 28,
                      color: AppColors.primaryColor,
                    ),
                    title: Text(
                      'Upload Product Categories Relational Data',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: IconButton(
                      onPressed: (){},
                      // onPressed: () => controller.uploadProductCategories(),
                      icon: const Icon(
                        Iconsax.arrow_up_1,
                        size: 28,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
