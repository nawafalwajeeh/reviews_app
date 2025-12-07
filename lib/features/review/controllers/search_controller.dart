// controllers/search_controller.dart - UPDATED WITH MULTILINGUAL SUPPORT
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reviews_app/features/review/models/category_extension.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:reviews_app/features/review/controllers/category_controller.dart';
import 'package:reviews_app/features/review/controllers/place_controller.dart';
import 'package:reviews_app/features/review/models/place_model.dart';
import 'package:reviews_app/features/review/models/category_model.dart';
import 'package:reviews_app/utils/popups/loaders.dart';

class AppSearchController extends GetxController {
  static AppSearchController get instance => Get.find();

  /// Variables
  final RxList<PlaceModel> searchResults = <PlaceModel>[].obs;
  final RxList<CategoryModel> categoryResults = <CategoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isListening = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString lastSearchQuery = ''.obs;
  final RxString selectedCategoryId = ''.obs;

  // Get existing controllers
  final categoryController = CategoryController.instance;
  final placeController = PlaceController.instance;

  // Speech to Text - Multilingual
  final stt.SpeechToText speechToText = stt.SpeechToText();
  final RxString recognizedText = ''.obs;
  final RxBool speechAvailable = false.obs;
  final RxString currentLanguage = 'en-US'.obs; // Default to English
  Timer? _listenTimer;

  // Language options
  final Map<String, String> languageOptions = {
    'en-US': 'English',
    'ar-SA': 'العربية',
    'fr-FR': 'Français',
    'de-DE': 'Deutsch',
    'es-ES': 'Español',
    'it-IT': 'Italiano',
    'pt-PT': 'Português',
    'ru-RU': 'Русский',
    'ja-JP': '日本語',
    'ko-KR': '한국어',
  };

  // Sorting options
  final List<String> sortingOptions = [
    'Relevance',
    'Highest Rated',
    'Most Reviewed',
    'Most Liked',
    'Newest',
    'Name (A-Z)',
    'Name (Z-A)',
    'Distance',
    'Price',
    'Rating',
    'Featured',
  ];
  final RxString selectedSortingOption = 'Relevance'.obs;

  // Filter options
  final RxDouble minRating = 0.0.obs;
  final RxBool showFeaturedOnly = false.obs;

  // Categories display
  final RxInt visibleCategoriesCount = 10.obs;
  final int categoriesPerPage = 10;

  @override
  void onInit() {
    super.onInit();
    _initializeSpeechToText();
  }

  /// Initialize Speech to Text with multilingual support
  void _initializeSpeechToText() async {
    try {
      // Check and request microphone permission
      final status = await Permission.microphone.request();

      if (status.isGranted) {
        bool available = await speechToText.initialize(
          onStatus: (status) {
            print('Speech status: $status');
            if (status == 'done' || status == 'notListening') {
              isListening.value = false;
              // Ensure loading is false too just in case
              if (recognizedText.value.isEmpty) {
                isLoading.value = false;
              }
            }
          },
          onError: (error) {
            print('Speech error: $error');
            isListening.value = false;
            isLoading.value = false;
          },
        );

        speechAvailable.value = available;

        if (!available) {
          print('Speech recognition not available on this device');
        }
      } else {
        speechAvailable.value = false;
        AppLoaders.warningSnackBar(
          // title: 'Microphone Permission Required',
          title: txt.microphonePermissionRequired,
          // message: 'Please enable microphone permission to use voice search.',
          message: txt.pleaseEnableMicrophone,
        );
      }
    } catch (e) {
      speechAvailable.value = false;
      print('Speech initialization error: $e');
    }
  }

  /// Toggle language between English and Arabic
  void toggleLanguage() {
    if (currentLanguage.value == 'en-US') {
      currentLanguage.value = 'ar-SA';
    } else if (currentLanguage.value == 'ar-SA') {
      currentLanguage.value = 'fr-FR';
    } else if (currentLanguage.value == 'fr-FR') {
      currentLanguage.value = 'de-DE';
    } else if (currentLanguage.value == 'de-DE') {
      currentLanguage.value = 'es-ES';
    } else if (currentLanguage.value == 'es-ES') {
      currentLanguage.value = 'it-IT';
    } else if (currentLanguage.value == 'it-IT') {
      currentLanguage.value = 'pt-PT';
    } else if (currentLanguage.value == 'pt-PT') {
      currentLanguage.value = 'ru-RU';
    } else if (currentLanguage.value == 'ru-RU') {
      currentLanguage.value = 'ja-JP';
    } else if (currentLanguage.value == 'ja-JP') {
      currentLanguage.value = 'ko-KR';
    } else {
      currentLanguage.value = 'en-US';
    }
    print('Language changed to: ${currentLanguage.value}');
  }

  /// Get current language name
  String get currentLanguageName {
    return languageOptions[currentLanguage.value] ?? 'العربيه';
  }

  /// Start listening for voice input with real-time updates
  void startListening() async {
    if (!speechAvailable.value) {
      AppLoaders.warningSnackBar(
        // title: 'Voice Search Unavailable',
        title: txt.voiceSearchUnavailable,
        // message: 'Speech recognition is not available on this device.',
        message: txt.speechRecognitionNotAvailable,
      );
      return;
    }

    if (isListening.value) {
      stopListening();
      return;
    }

    isListening.value = true;
    isLoading.value = true; // Show loading while listening/processing
    recognizedText.value = '';
    searchQuery.value = ''; // Clear previous search

    // Cancel any existing timer
    _listenTimer?.cancel();

    // Set safety timer to force stop after 12 seconds (listenFor + buffer)
    _listenTimer = Timer(const Duration(seconds: 10), () {
      if (isListening.value) {
        print('⏰ Safety timer triggered: Stopping listening');
        stopListening();
      }
    });

    try {
      speechToText.listen(
        onResult: (result) {
          recognizedText.value = result.recognizedWords;

          // 🔥 CRITICAL FIX: Update search query in REAL-TIME as user speaks
          searchQuery.value = recognizedText.value;

          print('🎤 Speaking: ${recognizedText.value}');

          if (result.finalResult) {
            print('✅ Final speech result: ${recognizedText.value}');
            // Auto-search when speech is complete
            if (recognizedText.value.isNotEmpty) {
              searchPlaces(recognizedText.value);
            }
            stopListening();
          }
        },
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 2),
        // partialResults: true, // 🔥 This enables real-time partial results
        // listenMode: stt.ListenMode.dictation,
        // partialResults: ,
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
        ),
        localeId: currentLanguage.value,
        onSoundLevelChange: (level) {
          // Optional: You can use this for voice level visualization
        },
      );

      print('🎤 Started listening in ${currentLanguage.value}');
    } catch (e) {
      print('❌ Listen error: $e');
      isListening.value = false;
      AppLoaders.errorSnackBar(
        // title: 'Speech Error',
        title: txt.speechError,
        // message: 'Could not start voice recognition. Please try again.',
        message: txt.couldNotStartVoiceRecognition,
      );
    }
  }

  /// Stop listening
  void stopListening() {
    try {
      speechToText.stop();
      print('🛑 Stopped listening');
    } catch (e) {
      print('Stop listening error: $e');
    } finally {
      _listenTimer?.cancel();
      isListening.value = false;
      // Ensure loading turned off if no text was recognized
      if (recognizedText.value.isEmpty) {
        isLoading.value = false;
      }
    }
  }

  /// Search places with filters
  Future<void> searchPlaces(
    String query, {
    String? categoryId,
    double? minRating,
    bool? featuredOnly,
    BuildContext? context,
  }) async {
    print('🔍 Searching for: "$query" with category ID: $categoryId');

    isLoading.value = true;
    lastSearchQuery.value = query;
    // searchQuery.value = query; // Ensure search field is updated

    try {
      Query firestoreQuery = FirebaseFirestore.instance.collection('Places');

      // If we have a category ID, search by category
      if (categoryId != null && categoryId.isNotEmpty) {
        print('🎯 Searching by category ID: $categoryId');
        firestoreQuery = firestoreQuery.where(
          'CategoryId',
          isEqualTo: categoryId,
        );

        // Get category name for display
        final category = categoryController.allCategories.firstWhere(
          (cat) => cat.id == categoryId,
          orElse: () => CategoryModel.empty(),
        );

        // if (category.id.isNotEmpty) {
        //   searchQuery.value = category.name; // Show category name in search bar
        // }
        if (category.id.isNotEmpty) {
          print(
            '🏷️ Category: ${category.name} (Localized: ${category.getLocalizedName(Get.context!)})',
          );
          // ❌ DON'T set searchQuery.value here
        }
      }
      // If we have a text query, search by text
      else if (query.isNotEmpty) {
        print('📝 Searching by text: $query');
        // We'll filter locally for better text search
        final allPlacesQuery = await FirebaseFirestore.instance
            .collection('Places')
            .get();

        List<PlaceModel> allPlaces = allPlacesQuery.docs.map((doc) {
          return PlaceModel.fromSnapshot(
            doc as DocumentSnapshot<Map<String, dynamic>>,
          );
        }).toList();

        print('📝 Searching by text: $query');
        searchQuery.value = query;

        final searchQueryLower = query.toLowerCase();
        List<PlaceModel> filteredPlaces = allPlaces.where((place) {
          return place.title.toLowerCase().contains(searchQueryLower) ||
              place.description.toLowerCase().contains(searchQueryLower) ||
              (place.tags ?? []).any(
                (tag) => tag.toLowerCase().contains(searchQueryLower),
              ) ||
              place.address.toString().toLowerCase().contains(
                searchQueryLower,
              ) ||
              place.address.shortAddress.toLowerCase().contains(
                searchQueryLower,
              );
        }).toList();

        // Apply additional filters to text search results
        if (minRating != null && minRating > 0) {
          filteredPlaces = filteredPlaces
              .where((place) => place.averageRating >= minRating)
              .toList();
        }

        if (featuredOnly == true) {
          filteredPlaces = filteredPlaces
              .where((place) => place.isFeatured == true)
              .toList();
        }

        _applySorting(filteredPlaces);
        searchResults.assignAll(filteredPlaces);

        // Also search categories for the query
        await _searchCategories(query);
        return;
      }
      // If no query and no category, clear results
      else {
        searchResults.clear();
        categoryResults.clear();
        isLoading.value = false;
        return;
      }

      // Apply additional filters to Firestore query
      if (minRating != null && minRating > 0) {
        firestoreQuery = firestoreQuery.where(
          'AverageRating',
          isGreaterThanOrEqualTo: minRating,
        );
      }

      if (featuredOnly == true) {
        firestoreQuery = firestoreQuery.where('IsFeatured', isEqualTo: true);
      }

      // Execute the query
      final querySnapshot = await firestoreQuery.get();
      List<PlaceModel> results = querySnapshot.docs.map((doc) {
        return PlaceModel.fromSnapshot(
          doc as DocumentSnapshot<Map<String, dynamic>>,
        );
      }).toList();

      print('✅ Found ${results.length} places');

      // Apply sorting
      _applySorting(results);

      searchResults.assignAll(results);

      // Clear category results when searching by category
      if (categoryId.isNotEmpty) {
        categoryResults.clear();
      }
    } catch (e) {
      print('❌ Search error: $e');
      AppLoaders.errorSnackBar(title: 'Search Error', message: e.toString());
      searchResults.clear();
      categoryResults.clear();
    } finally {
      isLoading.value = false;
      print('🔍 Current searchQuery after search: "${searchQuery.value}"');
    }
  }

  /// Search categories
  Future<void> _searchCategories(String query) async {
    try {
      final categories = categoryController.allCategories;
      final searchQueryLower = query.toLowerCase();

      final filteredCategories = categories.where((category) {
        return category.name.toLowerCase().contains(searchQueryLower);
      }).toList();

      categoryResults.assignAll(filteredCategories);
      print('🏷️ Found ${categoryResults.length} categories');
    } catch (e) {
      print('Category search error: $e');
      categoryResults.clear();
    }
  }

  /// Get search suggestions from actual categories with pagination
  List<String> getSearchSuggestions() {
    try {
      final categories = categoryController.allCategories;

      print(
        '📋 Total categories: ${CategoryController.instance.allCategories.length}',
      );
      print(
        '📋 First few categories: ${CategoryController.instance.allCategories.take(3).map((c) => c.name).toList()}',
      );

      final testCategory = categoryController.allCategories.first;
      print(
        '🧪 Translation test: ${testCategory.name} -> ${testCategory.getLocalizedName(Get.context!)}',
      );

      List<String> suggestions = categories
          .where((cat) => cat.name.isNotEmpty)
          .map((cat) => cat.name)
          .toList();

      print('💡 Total categories: ${suggestions.length}');
      return suggestions;
    } catch (e) {
      print('Error getting search suggestions: $e');
      return [];
    }
  }

  /// Get visible categories for display (with pagination)
  List<String> getVisibleCategories() {
    final allSuggestions = getSearchSuggestions();
    return allSuggestions.take(visibleCategoriesCount.value).toList();
  }

  /// Check if there are more categories to show
  bool get hasMoreCategories {
    final allSuggestions = getSearchSuggestions();
    return visibleCategoriesCount.value < allSuggestions.length;
  }

  /// Load more categories
  void loadMoreCategories() {
    final allSuggestions = getSearchSuggestions();
    if (visibleCategoriesCount.value < allSuggestions.length) {
      visibleCategoriesCount.value += categoriesPerPage;
      print(
        '📚 Loaded more categories. Now showing: ${visibleCategoriesCount.value}',
      );
    }
  }

  /// Show all categories
  void showAllCategories() {
    final allSuggestions = getSearchSuggestions();
    visibleCategoriesCount.value = allSuggestions.length;
    print('📚 Showing all categories: ${visibleCategoriesCount.value}');
  }

  /// Reset categories to initial count
  void resetCategories() {
    visibleCategoriesCount.value = categoriesPerPage;
  }

  /// Apply sorting to results
  void _applySorting(List<PlaceModel> results) {
    switch (selectedSortingOption.value) {
      case 'Highest Rated':
        results.sort((a, b) => b.averageRating.compareTo(a.averageRating));
        break;
      case 'Most Reviewed':
        results.sort((a, b) => b.reviewsCount.compareTo(a.reviewsCount));
        break;
      case 'Most Liked':
        results.sort((a, b) => b.likeCount.compareTo(a.likeCount));
        break;
      case 'Newest':
        results.sort((a, b) {
          final aDate = a.dateAdded ?? DateTime(2000);
          final bDate = b.dateAdded ?? DateTime(2000);
          return bDate.compareTo(aDate);
        });
        break;
      case 'Name (A-Z)':
        results.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Name (Z-A)':
        results.sort((a, b) => b.title.compareTo(a.title));
        break;
      // 'Relevance' - no sorting, keeps existing order
    }
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
    recognizedText.value = '';
    searchResults.clear();
    categoryResults.clear();
    selectedCategoryId.value = '';
    minRating.value = 0.0;
    showFeaturedOnly.value = false;
    resetCategories(); // Reset categories to initial count
  }

  /// Get trending places
  Future<List<PlaceModel>> getTrendingPlaces() async {
    try {
      if (placeController.featuredPlaces.isNotEmpty) {
        return placeController.featuredPlaces.take(5).toList();
      }
      return [];
    } catch (e) {
      print('Error getting trending places: $e');
      return [];
    }
  }

  /// Apply filters and search again
  void applyFiltersAndSearch() {
    searchPlaces(
      searchQuery.value,
      categoryId: selectedCategoryId.value.isEmpty
          ? null
          : selectedCategoryId.value,
      minRating: minRating.value > 0 ? minRating.value : null,
      featuredOnly: showFeaturedOnly.value ? true : null,
    );
  }

  /// Search by category name
  // Future<void> searchByCategoryName(
  //   String categoryName,
  //   BuildContext context,
  // ) async {
  //   print('🎯 Searching by category name: $categoryName');

  //   try {
  //     isLoading.value = true;

  //     // Find the category by name to get its ID
  //     final category = categoryController.allCategories.firstWhere(
  //       (cat) => cat.name.toLowerCase() == categoryName.toLowerCase(),
  //       orElse: () => CategoryModel.empty(),
  //     );
  //     // CategoryModel? category = categoryController.allCategories.firstWhere(
  //     //   (cat) => cat.name.toLowerCase() == categoryName.toLowerCase(),
  //     //   orElse: () => CategoryModel.empty(),
  //     // );

  //     // // If not found by English name, try to find by localized name
  //     // if (category.id.isEmpty) {
  //     //   category = categoryController.allCategories.firstWhere(
  //     //     (cat) =>
  //     //         cat.getLocalizedName(context).toLowerCase() ==
  //     //         categoryName.toLowerCase(),
  //     //     orElse: () => CategoryModel.empty(),
  //     //   );
  //     // }

  //     if (category.id.isNotEmpty) {
  //       print('✅ Found category: ${category.name} with ID: ${category.id}');

  //       // Clear previous results
  //       searchResults.clear();
  //       categoryResults.clear();
  //       // Update search query with localized name for display
  //       // searchQuery.value = category.getLocalizedName(context);
  //       // Search using the CATEGORY ID, not the name
  //       await searchPlaces(
  //         '', // Empty query because we're searching by category
  //         // category.name,
  //         categoryId: category.id, // Use the category ID
  //       );
  //     } else {
  //       print('❌ Category not found: $categoryName');
  //       // searchQuery.value = categoryName;
  //       // If category not found, fallback to text search
  //       await searchPlaces(categoryName);
  //     }
  //   } catch (e) {
  //     print('❌ Category search error: $e');
  //     // Fallback to text search
  //     // searchQuery.value = categoryName;
  //     await searchPlaces(categoryName);
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  /// Search by category name
  Future<void> searchByCategoryName(
    String categoryName,
    BuildContext context,
  ) async {
    print('🎯 Searching by category name: $categoryName');

    try {
      isLoading.value = true;

      CategoryModel? category = categoryController.allCategories.firstWhere(
        (cat) => cat.name.toLowerCase() == categoryName.toLowerCase(),
        orElse: () => CategoryModel.empty(),
      );

      if (category.id.isEmpty) {
        category = categoryController.allCategories.firstWhere(
          (cat) =>
              cat.getLocalizedName(context).toLowerCase() ==
              categoryName.toLowerCase(),
          orElse: () => CategoryModel.empty(),
        );
      }

      if (category.id.isNotEmpty) {
        print('✅ Found category: ${category.name} with ID: ${category.id}');

        searchResults.clear();
        categoryResults.clear();

        // ✅ Set display to localized name
        // searchQuery.value = category.getLocalizedName(context);
        searchQuery.value = categoryName;
        // ✅ But search with English name (empty string was the problem)
        await searchPlaces(
          category.name, // Use English name for search
          categoryId: category.id,
        );
      } else {
        print('❌ Category not found: $categoryName');
        searchQuery.value = categoryName;
        await searchPlaces(categoryName);
      }
    } catch (e) {
      print('❌ Category search error: $e');
      searchQuery.value = categoryName;
      await searchPlaces(categoryName);
    } finally {
      isLoading.value = false;
    }
  }

  /// Get category by ID
  CategoryModel? getCategoryById(String categoryId) {
    try {
      return categoryController.allCategories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => CategoryModel.empty(),
      );
    } catch (e) {
      return null;
    }
  }
}
