import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/data/repositories/authentication/authentication_repository.dart';
import 'package:uuid/uuid.dart';

import '../../../data/repositories/categories/category_repository.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../models/category_model.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find();

  final _categoryRepository = CategoryRepository();
  final Uuid uuid = const Uuid();
  final GlobalKey<FormState> categoryFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final iconKey = 'default_icon'.obs; // Key for icon resource
  final gradientKey = 'default_grad'.obs; // Key for gradient resource
  final iconColorValue = 0xFF2D3A64.obs; // Hex color value

  final RxInt selectedIndex = 0.obs;
  bool isSelected(int index) => index == selectedIndex.value;

  final List<String> categories = [
    'All',
    'Restaurants',
    'Schools',
    'Cafes',
    'Hotels',
  ];

  // Using .obs to make the list reactive for real-time updates
  final RxList<CategoryModel> mockCategories = <CategoryModel>[
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
      iconColorValue: 0xFF2D3A64,
    ),
    CategoryModel(
      id: '9',
      name: 'Parks',
      image: '',
      isFeatured: false,
      iconKey: 'park',
      gradientKey: 'green_grad',
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
      iconColorValue: 0xFF2D3A64,
    ),
    CategoryModel(
      id: '12',
      name: 'Malls',
      image: '',
      isFeatured: false,
      iconKey: 'mall',
      gradientKey: 'cyan_grad',
      iconColorValue: 0xFF2D3A64,
    ),
  ].obs;

  // ----------------------------------------------------
  /// -- Create new place category
  // ----------------------------------------------------
  Future<void> createPlaceCategory() async {
    try {
      // 1. Start Loading & Form Validation (Manual check for required fields)
      AppFullScreenLoader.openLoadingDialog(
        'Creating new category...',
        AppImages.docerAnimation,
      );

      final categoryName = nameController.text.trim();

      // Check if the name field is empty
      if (categoryName.isEmpty) {
        AppFullScreenLoader.stopLoading();
        AppLoaders.warningSnackBar(
          title: 'Category Name Required',
          message: 'Please enter a name for the new category.',
        );
        return;
      }

      // OPTIONAL: Check if a category with this name already exists
      if (mockCategories.any(
        (cat) => cat.name.toLowerCase() == categoryName.toLowerCase(),
      )) {
        AppFullScreenLoader.stopLoading();
        AppLoaders.warningSnackBar(
          title: 'Duplicate Category',
          message: 'A category with this name already exists.',
        );
        return;
      }

      // 2. Generate a unique ID
      final String categoryId = uuid.v4();
      final userId = AuthenticationRepository.instance.getUserID;

      // 3. Create Category Model
      final newCategory = CategoryModel(
        id: categoryId,
        name: categoryName,
        image:
            '', // No image upload logic needed for categories in this context
        isFeatured: false, // Default to not featured
        iconKey: iconKey.value,
        gradientKey: gradientKey.value,
        iconColorValue: iconColorValue.value,
        userId: userId,
      );

      // 4. Save Data to Repository
      await _categoryRepository.createCategory(newCategory);

      // 5. Update local observable list for immediate UI update
      mockCategories.add(newCategory);

      // 6. Success Handling & Cleanup
      AppLoaders.successSnackBar(
        title: 'Success!',
        message: 'The new category "$categoryName" has been created.',
      );

      // Clear the form fields
      _resetForm();
    } catch (e) {
      // 7. Error Handling
      AppLoaders.errorSnackBar(
        title: 'Oh Snap!',
        message: 'Could not create category: ${e.toString()}',
      );
    } finally {
      // 8. Stop Loading (Guaranteed execution)
      AppFullScreenLoader.stopLoading();
    }
  }

  /// Private method to reset the category creation form fields
  void _resetForm() {
    nameController.clear();
    // Reset reactive states to default/empty values if needed
    iconKey.value = 'default_icon';
    gradientKey.value = 'default_grad';
    iconColorValue.value = 0xFF2D3A64;
  }
}


//----------------------------
// import 'package:get/get.dart';

// import '../models/category_model.dart';

// class CategoryController extends GetxController {
//   static CategoryController get instance => Get.find();

//   final RxInt selectedIndex = 0.obs;
//   // final RxInt isSelected = 0.obs;

//   bool isSelected(int index) => index == selectedIndex.value;

//   final List<String> categories = [
//     'All',
//     'Restaurants',
//     'Schools',
//     'Cafes',
//     'Hotels',
//   ];

//   final List<CategoryModel> mockCategories = [
//     CategoryModel(
//       id: '1',
//       name: 'Restaurants',
//       image: '',
//       isFeatured: true,
//       iconKey: 'restaurant',
//       gradientKey: 'blue_grad',
//       iconColorValue: 0xFF2D3A64,
//     ),
//     CategoryModel(
//       id: '2',
//       name: 'Hotels',
//       image: '',
//       isFeatured: true,
//       iconKey: 'hotel',
//       gradientKey: 'dark_blue_grad',
//       iconColorValue: 0xFF2E3A59,
//     ),
//     CategoryModel(
//       id: '3',
//       name: 'Hospitals',
//       image: '',
//       isFeatured: true,
//       iconKey: 'hospital',
//       gradientKey: 'light_blue_grad',
//       iconColorValue: 0xFF2D3A64,
//     ),
//     CategoryModel(
//       id: '4',
//       name: 'Groceries',
//       image: '',
//       isFeatured: false,
//       iconKey: 'grocery',
//       gradientKey: 'navy_grad',
//       iconColorValue: 0xFF2D3A64,
//     ),
//     CategoryModel(
//       id: '5',
//       name: 'Gas Stations',
//       image: '',
//       isFeatured: false,
//       iconKey: 'gas',
//       gradientKey: 'pastel_grad',
//       iconColorValue: 0xFF2D3A64,
//     ),
//     CategoryModel(
//       id: '6',
//       name: 'Gyms',
//       image: '',
//       isFeatured: true,
//       iconKey: 'gym',
//       gradientKey: 'purple_grad',
//       iconColorValue: 0xFF2D3A64,
//     ),
//     CategoryModel(
//       id: '7',
//       name: 'Schools',
//       image: '',
//       isFeatured: false,
//       iconKey: 'school',
//       gradientKey: 'indigo_grad',
//       iconColorValue: 0xFF2D3A64,
//     ),
//     CategoryModel(
//       id: '8',
//       name: 'Museums',
//       image: '',
//       isFeatured: false,
//       iconKey: 'museum',
//       gradientKey: 'red_grad',
//       iconColorValue: 0xFF2D3A64,
//     ),
//     CategoryModel(
//       id: '9',
//       name: 'Parks',
//       image: '',
//       isFeatured: false,
//       iconKey: 'park',
//       gradientKey: 'green_grad',
//       iconColorValue: 0xFF2D3A64,
//     ),
//     CategoryModel(
//       id: '10',
//       name: 'Offices',
//       image: '',
//       isFeatured: false,
//       iconKey: 'office',
//       gradientKey: 'gray_grad',
//       iconColorValue: 0xFF5F2D64,
//     ),
//     CategoryModel(
//       id: '11',
//       name: 'Theatres',
//       image: '',
//       isFeatured: false,
//       iconKey: 'theatre',
//       gradientKey: 'yellow_grad',
//       iconColorValue: 0xFF2D3A64,
//     ),
//     CategoryModel(
//       id: '12',
//       name: 'Malls',
//       image: '',
//       isFeatured: false,
//       iconKey: 'mall',
//       gradientKey: 'cyan_grad',
//       iconColorValue: 0xFF2D3A64,
//     ),
//   ];


// }
