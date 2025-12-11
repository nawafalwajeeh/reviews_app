import 'package:get/get.dart';
import 'package:reviews_app/features/review/controllers/category_controller.dart';
import 'package:reviews_app/features/review/controllers/favourite_controller.dart';
import 'package:reviews_app/features/review/controllers/gallery_controller.dart';
import 'package:reviews_app/features/review/controllers/place_controller.dart';
import 'package:reviews_app/features/review/controllers/place_map_controller.dart';
import 'package:reviews_app/features/review/controllers/search_controller.dart';
import 'package:reviews_app/utils/helpers/network_manager.dart';
import '../features/personalization/controllers/address_controller.dart';
import '../features/personalization/controllers/user_controller.dart';
import '../features/review/controllers/images_controller.dart';
// import '../features/review/controllers/notification_controller.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    /// -- Core
    Get.put(AppNetworkManager(), permanent: true);
    Get.put(CategoryController());
    // Get.lazyPut(() => NotificationController());

    /// -- User
    Get.put(UserController());
    Get.put(AddressController());

    /// -- Place
    Get.put(ImagesController());
    Get.put(PlaceController());
    Get.put(PlacesMapController(), permanent: true);
    Get.lazyPut(() => GalleryController());
    Get.lazyPut(() => FavouritesController());
    Get.lazyPut(() => AppSearchController());
  }
}
