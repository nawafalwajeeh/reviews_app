import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../data/repositories/categories/category_repository.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import 'category_controller.dart';

class UploadDataController extends GetxController {
  static UploadDataController get instance => Get.find();

  final RxBool isUploading = false.obs;

  Future<void> uploadCategories() async {
    try {
      // The following line will enable the Android and iOS wakelock.
      WakelockPlus.enable();

      AppFullScreenLoader.openLoadingDialog(
        'Sit Tight! Your CATEGORIES are uploading...',
        AppImages.cloudUploadingAnimation,
      );

      final repository = Get.put(CategoryRepository());

      final controller = Get.put(CategoryController());

      // Upload All Categories and replace the Parent IDs in Firebase Console
      await repository.uploadDummyData(controller.mockCategories);

      // Re-fetch latest Categories
      await CategoryController.instance.fetchCategories();

      AppLoaders.successSnackBar(
        title: 'Congratulations',
        message: 'All Categories Uploaded Successfully.',
      );
    } catch (e) {
      AppLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      // The next line disables the wakelock again.
      WakelockPlus.disable();
      AppFullScreenLoader.stopLoading();
    }
  }
}
