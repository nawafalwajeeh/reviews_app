// // import 'package:cwt_ecommerce_app/features/shop/controllers/categories_controller.dart';
// // import 'package:cwt_ecommerce_app/features/shop/controllers/product/banner_controller.dart';
// import 'package:get/get.dart';
// import 'package:reviews_app/data/repositories/banners/banner_repository.dart';
// import 'package:reviews_app/data/repositories/product/product_repository.dart';

// import 'package:wakelock_plus/wakelock_plus.dart';
// import '../../../data/repositories/brands/brand_repository.dart';
// import '../../../data/repositories/categories/category_repository.dart';
// import '../../../utils/constants/image_strings.dart';
// import '../../../utils/popups/full_screen_loader.dart';
// import '../../../utils/popups/loaders.dart';

// class UploadDataController extends GetxController {
//   static UploadDataController get instance => Get.find();

//   // Future<void> uploadCategories() async {
//   //   try {
//   //     // The following line will enable the Android and iOS wakelock.
//   //     WakelockPlus.enable();

//   //     AppFullScreenLoader.openLoadingDialog(
//   //       'Sit Tight! Your CATEGORIES are uploading...',
//   //       AppImages.cloudUploadingAnimation,
//   //     );

//   //     final controller = Get.put(CategoryRepository());

//   //     // Upload All Categories and replace the Parent IDs in Firebase Console
//   //     await controller.uploadDummyData(AppDummyData.categories);

//   //     // Re-fetch latest Categories
//   //     await CategoryController.instance.fetchCategories();

//   //     AppLoaders.successSnackBar(
//   //       title: 'Congratulations',
//   //       message: 'All Categories Uploaded Successfully.',
//   //     );
//   //   } catch (e) {
//   //     AppLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
//   //   } finally {
//   //     // The next line disables the wakelock again.
//   //     WakelockPlus.disable();
//   //     AppFullScreenLoader.stopLoading();
//   //   }
//   // }

//   Future<void> uploadProductCategories() async {
//     try {
//       // The following line will enable the Android and iOS wakelock.
//       WakelockPlus.enable();

//       AppFullScreenLoader.openLoadingDialog(
//         'Sit Tight! Your PRODUCT CATEGORIES relationship is uploading...',
//         AppImages.cloudUploadingAnimation,
//       );

//       final controller = Get.put(CategoryRepository());

//       // Upload All Categories and replace the Parent IDs in Firebase Console
//       await controller.uploadProductCategoryDummyData(
//         AppDummyData.productCategories,
//       );

//       AppLoaders.successSnackBar(
//         title: 'Congratulations',
//         message: 'All Categories Uploaded Successfully.',
//       );
//     } catch (e) {
//       AppLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
//     } finally {
//       // The next line disables the wakelock again.
//       WakelockPlus.disable();
//       AppFullScreenLoader.stopLoading();
//     }
//   }

//   Future<void> uploadBrands() async {
//     try {
//       // The following line will enable the Android and iOS wakelock.
//       WakelockPlus.enable();

//       AppFullScreenLoader.openLoadingDialog(
//         'Sit Tight! Your BRANDS are uploading...',
//         AppImages.cloudUploadingAnimation,
//       );

//       final controller = Get.put(BrandRepository());

//       // Upload All Categories and replace the Parent IDs in Firebase Console
//       await controller.uploadDummyData(AppDummyData.brands);

//       // Re-fetch latest Brands
//       final brandController = Get.put(BrandController());
//       await brandController.getFeaturedBrands();

//       AppLoaders.successSnackBar(
//         title: 'Congratulations',
//         message: 'All Brands Uploaded Successfully.',
//       );
//     } catch (e) {
//       AppLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
//     } finally {
//       // The next line disables the wakelock again.
//       WakelockPlus.disable();
//       AppFullScreenLoader.stopLoading();
//     }
//   }

//   Future<void> uploadBrandCategory() async {
//     try {
//       // The following line will enable the Android and iOS wakelock.
//       WakelockPlus.enable();

//       AppFullScreenLoader.openLoadingDialog(
//         'Sit Tight! Your BRANDS & CATEGORIES relationship is uploading...',
//         AppImages.cloudUploadingAnimation,
//       );

//       final controller = Get.put(BrandRepository());

//       // Upload All Categories and replace the Parent IDs in Firebase Console
//       await controller.uploadBrandCategoryDummyData(AppDummyData.brandCategory);

//       AppLoaders.successSnackBar(
//         title: 'Congratulations',
//         message: 'All Brands Uploaded Successfully.',
//       );
//     } catch (e) {
//       AppLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
//     } finally {
//       // The next line disables the wakelock again.
//       WakelockPlus.disable();
//       AppFullScreenLoader.stopLoading();
//     }
//   }

//   Future<void> uploadProducts() async {
//     try {
//       // The following line will enable the Android and iOS wakelock.
//       WakelockPlus.enable();

//       AppFullScreenLoader.openLoadingDialog(
//         'Sit Tight! Your Products are uploading. It may take a while...',
//         AppImages.cloudUploadingAnimation,
//       );

//       final controller = Get.put(ProductRepository());

//       // Upload All Products and replace the Parent IDs in Firebase Console
//       await controller.uploadDummyData(AppDummyData.products);

//       // Re-fetch latest Featured Products
//       ProductController.instance.fetchFeaturedProducts();

//       AppLoaders.successSnackBar(
//         title: 'Congratulations',
//         message: 'All Products Uploaded Successfully.',
//       );
//     } catch (e) {
//       AppLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
//     } finally {
//       // The next line disables the wakelock again.
//       WakelockPlus.disable();
//       AppFullScreenLoader.stopLoading();
//     }
//   }

//   /// Upload Banners Data
//   Future<void> uploadBanners() async {
//     try {
//       // The following line will enable the Android and iOS wakelock.
//       WakelockPlus.enable();

//       AppFullScreenLoader.openLoadingDialog(
//         'Sit Tight! Your Banners are uploading. It may take a while...',
//         AppImages.cloudUploadingAnimation,
//       );

//       final controller = Get.put(BannerRepository());

//       // Upload All Products and replace the Parent IDs in Firebase Console
//       await controller.uploadBannersDummyData(AppDummyData.banners);

//       // Re-fetch latest Banners
//       final bannerController = Get.put(BannerController());
//       await bannerController.fetchBanners();

//       AppLoaders.successSnackBar(
//         title: 'Congratulations',
//         message: 'All Products Uploaded Successfully.',
//       );
//     } catch (e) {
//       AppLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
//     } finally {
//       // The next line disables the wakelock again.
//       WakelockPlus.disable();
//       AppFullScreenLoader.stopLoading();
//     }
//   }
// }
