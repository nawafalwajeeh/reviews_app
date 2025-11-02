import 'package:get/get.dart';

import '../models/category_model.dart';

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

  final List<CategoryModel> mockCategories = [
    CategoryModel(
      id: '1',
      name: 'Restaurants',
      image: '',
      isFeatured: true,
      iconKey: 'restaurant',
      gradientKey: 'blue_grad',
      iconColorValue: 0xFF2D3A64,
    ),
    CategoryModel(
      id: '2',
      name: 'Hotels',
      image: '',
      isFeatured: true,
      iconKey: 'hotel',
      gradientKey: 'dark_blue_grad',
      iconColorValue: 0xFF2E3A59,
    ),
    CategoryModel(
      id: '3',
      name: 'Hospitals',
      image: '',
      isFeatured: true,
      iconKey: 'hospital',
      gradientKey: 'light_blue_grad',
      iconColorValue: 0xFF2D3A64,
    ),
    CategoryModel(
      id: '4',
      name: 'Groceries',
      image: '',
      isFeatured: false,
      iconKey: 'grocery',
      gradientKey: 'navy_grad',
      iconColorValue: 0xFF2D3A64,
    ),
    CategoryModel(
      id: '5',
      name: 'Gas Stations',
      image: '',
      isFeatured: false,
      iconKey: 'gas',
      gradientKey: 'pastel_grad',
      iconColorValue: 0xFF2D3A64,
    ),
    CategoryModel(
      id: '6',
      name: 'Gyms',
      image: '',
      isFeatured: true,
      iconKey: 'gym',
      gradientKey: 'purple_grad',
      iconColorValue: 0xFF2D3A64,
    ),
    CategoryModel(
      id: '7',
      name: 'Schools',
      image: '',
      isFeatured: false,
      iconKey: 'school',
      gradientKey: 'indigo_grad',
      iconColorValue: 0xFF2D3A64,
    ),
    CategoryModel(
      id: '8',
      name: 'Museums',
      image: '',
      isFeatured: false,
      iconKey: 'museum',
      gradientKey: 'red_grad',
      // iconColorValue: 0xFF642D2D,
      iconColorValue: 0xFF2D3A64,
    ),
    CategoryModel(
      id: '9',
      name: 'Parks',
      image: '',
      isFeatured: false,
      iconKey: 'park',
      gradientKey: 'green_grad',
      // iconColorValue: 0xFF2D642D,
      iconColorValue: 0xFF2D3A64,
    ),
    CategoryModel(
      id: '10',
      name: 'Offices',
      image: '',
      isFeatured: false,
      iconKey: 'office',
      gradientKey: 'gray_grad',
      iconColorValue: 0xFF5F2D64,
    ),
    CategoryModel(
      id: '11',
      name: 'Theatres',
      image: '',
      isFeatured: false,
      iconKey: 'theatre',
      gradientKey: 'yellow_grad',
      // iconColorValue: 0xFF664400,
      iconColorValue: 0xFF2D3A64,
    ),
    CategoryModel(
      id: '12',
      name: 'Malls',
      image: '',
      isFeatured: false,
      iconKey: 'mall',
      gradientKey: 'cyan_grad',
      // iconColorValue: 0xFF006677,
      iconColorValue: 0xFF2D3A64,
    ),
  ];
}
