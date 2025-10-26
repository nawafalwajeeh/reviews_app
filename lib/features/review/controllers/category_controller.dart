import 'package:get/get.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find();

  final RxInt selectedIndex = 0.obs;
  // final RxInt isSelected = 0.obs;

  bool isSelected(int index) => index == selectedIndex.value;

  final List<String> categories = [
    'All',
    'Restaurants',
    'Schools',
    'Cafes',
    'Hotels',
  ];
}
