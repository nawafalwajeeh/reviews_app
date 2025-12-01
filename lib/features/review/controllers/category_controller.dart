import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/data/repositories/authentication/authentication_repository.dart';
import 'package:reviews_app/data/repositories/place/place_repository.dart';
import 'package:reviews_app/features/review/models/category_extension.dart';
import 'package:reviews_app/features/review/models/category_mapper.dart';
import 'package:uuid/uuid.dart';

import '../../../data/repositories/categories/category_repository.dart';
import '../../../data/services/category/category_formatter.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../models/category_model.dart';
import '../models/place_model.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find();

  final _categoryRepository = Get.put(CategoryRepository());
  final Uuid uuid = const Uuid();
  final GlobalKey<FormState> categoryFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final iconKey = 'default_icon'.obs; // Key for icon resource
  final gradientKey = 'default_grad'.obs; // Key for gradient resource
  final iconColorValue = 0xFF2D3A64.obs; // Hex color value
  final isLoading = false.obs;
  final RxList<CategoryModel> allCategories = <CategoryModel>[].obs;
  final RxList<CategoryModel> featuredCategories = <CategoryModel>[].obs;

  final RxInt selectedIndex = 0.obs;
  bool isSelected(int index) => index == selectedIndex.value;

  final RxList<String> categories = allCategoryNames.obs;

  // Cache for localized category names
  final Map<String, String> _localizedCategoryCache = {};
  final RxList<CategoryModel> mockCategories = allMockCategories.obs;
  // Observable list to store the fetched category models
  final RxList<CategoryModel> categoryModels = <CategoryModel>[].obs;
  List<String> get categoryNames => categoryModels.map((m) => m.name).toList();
  final RxString selectedCategoryName = ''.obs;

  @override
  void onReady() {
    fetchCategories();
    super.onReady();
  }

  /// -- Get Cached Localized CategoryName
  String getCachedLocalizedCategoryName(
    String categoryId,
    BuildContext context,
  ) {
    final cacheKey =
        '${categoryId}_${Localizations.localeOf(context).languageCode}';

    if (_localizedCategoryCache.containsKey(cacheKey)) {
      return _localizedCategoryCache[cacheKey]!;
    }

    // If not cached, get it and cache it
    final category = allCategories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => CategoryModel.empty(),
    );

    final localizedName = category.id.isNotEmpty
        ? category.getLocalizedName(context)
        : AppLocalizations.of(context).categoryNotFound;

    _localizedCategoryCache[cacheKey] = localizedName;
    return localizedName;
  }

  /// Clear cache when language changes
  void clearLocalizationCache() {
    _localizedCategoryCache.clear();
  }

  // Add this method to your CategoryController
  Future<String> getLocalizedSingularCategoryName(
    String categoryId,
    BuildContext context,
  ) async {
    try {
      final category = await getSelectedCategory(categoryId: categoryId);
      if (category.id.isNotEmpty) {
        return CategoryFormatter.getLocalizedSingularNameInContext(
          category.name,
          context,
        );
      } else {
        // return 'Unknown Category';
        return txt.unknownCategory;
      }
    } catch (e) {
      // return 'Unknown Category';
      return txt.unknownCategory;
    }
  }

  Future<String> getEnglishCategoryName(String categoryId) async {
    try {
      final category = await getSelectedCategory(categoryId: categoryId);
      if (category.id.isNotEmpty) {
        return category.name; // This should return the English name
      } else {
        return 'Other';
      }
    } catch (e) {
      return 'Other';
    }
  }

  /// -- load Category data
  Future<void> fetchCategories() async {
    try {
      // Start Loader while loading Categories
      isLoading.value = true;
      // Fetch Categories from the data source (Firestore, API, etc)
      final categories = await _categoryRepository.getAllCategories();

      // Update the categories list
      allCategories.assignAll(categories);

      // Filter Futured categories
      featuredCategories.assignAll(
        allCategories
            .where(
              (category) => category.isFeatured && category.parentId.isEmpty,
            )
            .take(8)
            .toList(),
      );

      // Update the observable list
      categoryModels.assignAll(categories);
      update();
    } catch (e) {
      // AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      AppLoaders.errorSnackBar(title: txt.ohSnap, message: e.toString());
    } finally {
      // Remove Loader
      isLoading.value = false;
    }
  }

  /// -- load Category data
  Future<CategoryModel> getSelectedCategory({
    required String categoryId,
  }) async {
    try {
      // Start Loader while loading Categories
      // Fetch Categories from the data source (Firestore, API, etc)
      final category = await _categoryRepository.getSelectedCategory(
        categoryId,
      );

      return category;
    } catch (e) {
      // AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      AppLoaders.errorSnackBar(title: txt.ohSnap, message: e.toString());
      return CategoryModel.empty();
    }
  }

  /// -- Load Selected Category data
  // Future<List<CategoryModel>> getSubCategories({
  //   required String categoryId,
  // }) async {
  //   try {
  //     // Fetch limited (4) products against each subCategory
  //     final subCategories = await _categoryRepository.getSubCategories(
  //       categoryId,
  //     );
  //     return subCategories;
  //   } catch (e) {
  //     AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
  //     return [];
  //   }
  // }

  Future<CategoryModel> getCategoryById(String categoryId) async {
    try {
      return await getSelectedCategory(categoryId: categoryId);
    } catch (e) {
      // Return a default category on error
      return CategoryModel(
        id: '0',
        name: 'Other',
        image: '',
        isFeatured: false,
        iconKey: 'default_icon',
        gradientKey: 'default_gradient',
        iconColorValue: 0xFF2D3A64,
      );
    }
  }

  /// -- Get CategoryName By Id
  Future<String> getCategoryName(String categoryId) async {
    try {
      final categoryName = await _categoryRepository.getCategoryNameById(
        categoryId,
      );
      selectedCategoryName.value = categoryName;
      return categoryName;
    } catch (e) {
      // AppLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
      AppLoaders.errorSnackBar(title: txt.ohSnap, message: e.toString());
      return '';
    }
  }

  /// Get localized category name by ID
  Future<String> getLocalizedCategoryName(
    String categoryId,
    BuildContext context,
  ) async {
    try {
      final category = await _categoryRepository.getSelectedCategory(
        categoryId,
      );
      if (category.id.isNotEmpty) {
        return category.getName(context); // Using the new helper method
      } else {
        // return 'Unknown Category';
        return txt.unknownCategory;
      }
    } catch (e) {
      // return 'Unknown Category';
      return txt.unknownCategory;
    }
  }

  /// Get list of localized category names
  List<String> getLocalizedCategoryNames(BuildContext context) {
    return allCategories.map((category) => category.getName(context)).toList();
  }

  /// Get featured categories with localized names
  List<CategoryModel> getLocalizedFeaturedCategories(BuildContext context) {
    return featuredCategories
        .map(
          (category) => category.copyWith(
            // This creates a copy with the localized name for display
          ),
        )
        .toList();
  }

  /// -- Get Category Places.
  Future<List<PlaceModel>> getCategoryPlaces({
    required String categoryId,
    int limit = 4,
  }) async {
    try {
      final places = await PlaceRepository.instance.getPlacesForCategory(
        categoryId,
        limit: limit,
      );
      return places;
    } catch (e) {
      // AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      AppLoaders.errorSnackBar(title: txt.ohSnap, message: e.toString());
      debugPrint(e.toString());
      return [];
    }
  }

  /// -- Stream Category Places (Stream)
  Stream<List<PlaceModel>> streamCategoryPlaces({required String categoryId}) {
    // This calls the new real-time streaming method in the repository.
    return PlaceRepository.instance.streamPlacesForCategory(
      categoryId: categoryId,
    );
  }

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
