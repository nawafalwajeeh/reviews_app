// features/review/screens/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/common/widgets/place/place_card.dart';
import 'package:reviews_app/common/widgets/shimmers/big_card_shimmer.dart';
import 'package:reviews_app/common/widgets/texts/section_heading.dart';
import 'package:reviews_app/features/review/controllers/search_controller.dart';
import 'package:reviews_app/features/review/models/place_model.dart';
import 'package:reviews_app/features/review/screens/categories/all_categories.dart';
import 'package:reviews_app/features/review/screens/place_details/place_details.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  final searchController = AppSearchController.instance;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Sync text controller with search query
    _textEditingController.text = searchController.searchQuery.value;

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          'Search Places',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              searchController.clearSearch();
              Get.back();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Enhanced Search Bar with Real-time Voice & Clear Button
                _buildEnhancedSearchBar(context),
                const SizedBox(height: AppSizes.spaceBtwSections),

                /// Search Results or Initial State
                Obx(() => _buildSearchContent(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedSearchBar(BuildContext context) {
    return Column(
      children: [
        /// Language Toggle Button
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Chip(
                label: Text(
                  searchController.currentLanguageName,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: AppColors.white),
                ),
                backgroundColor: AppColors.primaryColor,
              ),
              IconButton(
                icon: Icon(Icons.translate, color: AppColors.primaryColor),
                onPressed: searchController.toggleLanguage,
                tooltip:
                    'Switch to ${searchController.currentLanguage.value == 'en-US' ? 'Arabic' : 'English'}',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.sm),

        /// Search Field with Real-time Voice & Clear Button
        Row(
          children: [
            /// Search Field
            Expanded(
              child: Obx(() {
                // Update text controller when search query changes (from voice or back navigation)
                if (_textEditingController.text !=
                    searchController.searchQuery.value) {
                  _textEditingController.text =
                      searchController.searchQuery.value;
                }

                return TextFormField(
                  autofocus: true,
                  controller: _textEditingController,
                  onChanged: (query) {
                    searchController.searchQuery.value = query; // Keep in sync
                    if (query.isNotEmpty) {
                      searchController.searchPlaces(query);
                    } else {
                      searchController.searchResults.clear();
                      searchController.categoryResults.clear();
                    }
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Iconsax.search_normal),
                    hintText: 'Search places, categories...',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Clear Button - Shows when there's text
                        if (searchController.searchQuery.value.isNotEmpty)
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: AppColors.primaryColor,
                              size: 20,
                            ),
                            onPressed: () {
                              searchController.clearSearch();
                              _textEditingController.clear();
                              FocusScope.of(context).unfocus();
                            },
                            tooltip: 'Clear search',
                          ),

                        // Voice Search Button
                        Obx(() {
                          if (searchController.isListening.value) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            );
                          }
                          return IconButton(
                            icon: Icon(
                              Icons.mic,
                              color: AppColors.primaryColor,
                              size: 20,
                            ),
                            onPressed: () {
                              // Clear previous search when starting new voice search
                              searchController.searchQuery.value = '';
                              _textEditingController.clear();
                              searchController.startListening();
                            },
                            tooltip:
                                'Voice Search (${searchController.currentLanguageName})',
                          );
                        }),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(width: AppSizes.spaceBtwItems),

            /// Filter Button
            OutlinedButton(
              onPressed: () => _showFilterBottomSheet(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.grey),
                padding: const EdgeInsets.all(12),
              ),
              child: const Icon(Iconsax.filter, size: 20),
            ),
          ],
        ),

        /// Real-time Speech Recognition Text
        Obx(() {
          if (searchController.recognizedText.value.isNotEmpty &&
              searchController.isListening.value) {
            return Padding(
              padding: const EdgeInsets.only(top: AppSizes.sm),
              child: Column(
                children: [
                  Text(
                    '🎤 Listening...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"${searchController.recognizedText.value}"',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        }),
      ],
    );
  }

  Widget _buildSearchContent(BuildContext context) {
    final hasSearchQuery = searchController.searchQuery.value.isNotEmpty;
    final hasResults =
        searchController.searchResults.isNotEmpty ||
        searchController.categoryResults.isNotEmpty;

    if (searchController.isLoading.value) {
      return const PlaceCardShimmer();
    }

    if (hasSearchQuery && !hasResults) {
      return _buildNoResultsState();
    }

    if (hasSearchQuery && hasResults) {
      return _buildSearchResults();
    }

    return _buildInitialState(context);
  }

  Widget _buildInitialState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Search Suggestions with Pagination
        _buildSearchSuggestions(context),

        const SizedBox(height: AppSizes.spaceBtwSections),

        /// Trending Places
        FutureBuilder<List<PlaceModel>>(
          future: searchController.getTrendingPlaces(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const PlaceCardShimmer();
            }

            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return _buildTrendingPlaces(snapshot.data!);
            }

            return const SizedBox();
          },
        ),

        const SizedBox(height: AppSizes.spaceBtwSections),

        /// Browse Categories
        _buildBrowseCategories(),
      ],
    );
  }

  Widget _buildSearchSuggestions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeading(title: 'Browse Categories', showActionButton: false),
        const SizedBox(height: AppSizes.spaceBtwItems),

        Obx(() {
          final categories = searchController.getVisibleCategories();
          final hasMore = searchController.hasMoreCategories;
          final totalCategories = searchController
              .getSearchSuggestions()
              .length;
          final isShowingAll =
              searchController.visibleCategoriesCount.value >= totalCategories;

          if (categories.isEmpty) {
            return const Text('No categories available');
          }

          return Column(
            children: [
              Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: categories.map((categoryName) {
                  return GestureDetector(
                    onTap: () {
                      searchController.searchByCategoryName(categoryName);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppHelperFunctions.isDarkMode(context)
                            ? AppColors.darkerGrey
                            : AppColors.grey,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.category,
                            size: 16,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: AppSizes.xs),
                          Text(
                            categoryName,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: AppHelperFunctions.isDarkMode(context)
                                      ? AppColors.white
                                      : AppColors.dark,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              if (totalCategories > 10) ...[
                const SizedBox(height: AppSizes.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hasMore && !isShowingAll)
                      ElevatedButton.icon(
                        onPressed: searchController.loadMoreCategories,
                        icon: const Icon(Icons.expand_more, size: 16),
                        label: Text(
                          'Show More (${totalCategories - categories.length} left)',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor.withOpacity(
                            0.1,
                          ),
                          foregroundColor: AppColors.primaryColor,
                        ),
                      )
                    else if (isShowingAll)
                      ElevatedButton.icon(
                        onPressed: searchController.resetCategories,
                        icon: const Icon(Icons.expand_less, size: 16),
                        label: const Text('Show Less'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor.withOpacity(
                            0.1,
                          ),
                          foregroundColor: AppColors.primaryColor,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _buildTrendingPlaces(List<PlaceModel> places) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeading(title: 'Trending Places', showActionButton: false),
        const SizedBox(height: AppSizes.spaceBtwItems),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: places.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSizes.spaceBtwItems),
          itemBuilder: (context, index) {
            final place = places[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.sm),
                child: Image.network(
                  place.thumbnail,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 50,
                    height: 50,
                    color: AppColors.grey,
                    child: const Icon(Icons.place),
                  ),
                ),
              ),
              title: Text(
                place.title,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                place.address.shortAddress,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Chip(
                label: Text('${place.averageRating}'),
                backgroundColor: AppColors.primaryColor.withOpacity(0.2),
              ),
              onTap: () => Get.to(() => PlaceDetailsScreen(place: place)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBrowseCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeading(
          title: 'All Categories',
          showActionButton: true,
          buttonTitle: 'View All',
          onPressed: () => Get.to(() => AllCategoriesScreen()),
        ),
        const SizedBox(height: AppSizes.spaceBtwItems),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            color: AppHelperFunctions.isDarkMode(Get.context!)
                ? AppColors.dark
                : AppColors.light,
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
            border: Border.all(color: AppColors.grey),
          ),
          child: Column(
            children: [
              Icon(Icons.explore, size: 40, color: AppColors.primaryColor),
              const SizedBox(height: AppSizes.sm),
              Text(
                'Explore all categories',
                style: Theme.of(Get.context!).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.sm),
              ElevatedButton(
                onPressed: () => Get.to(() => AllCategoriesScreen()),
                child: const Text('View All Categories'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final hasCategoryFilter =
              searchController.selectedCategoryId.value.isNotEmpty;
          final category = hasCategoryFilter
              ? searchController.getCategoryById(
                  searchController.selectedCategoryId.value,
                )
              : null;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.md),
            child: Text(
              hasCategoryFilter && category != null
                  ? 'Found ${searchController.searchResults.length} places in "${category.name}"'
                  : 'Found ${searchController.searchResults.length} places for "${searchController.searchQuery.value}"',
              style: Theme.of(
                Get.context!,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.darkerGrey),
            ),
          );
        }),

        if (searchController.categoryResults.isNotEmpty) ...[
          _buildCategoryResults(),
          const SizedBox(height: AppSizes.spaceBtwSections),
        ],

        _buildPlaceResults(),
      ],
    );
  }

  Widget _buildCategoryResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeading(title: 'Categories', showActionButton: false),
        const SizedBox(height: AppSizes.spaceBtwItems),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: searchController.categoryResults.length,
          itemBuilder: (context, index) {
            final category = searchController.categoryResults[index];
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.sm),
                  color: AppColors.primaryColor.withOpacity(0.1),
                ),
                child: Icon(Icons.category, color: AppColors.primaryColor),
              ),
              title: Text(category.name),
              trailing: const Icon(Iconsax.arrow_right_3, size: 16),
              onTap: () {
                searchController.selectedCategoryId.value = category.id;
                searchController.searchPlaces(
                  searchController.searchQuery.value,
                  categoryId: category.id,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildPlaceResults() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: searchController.searchResults.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppSizes.spaceBtwSections),
      itemBuilder: (context, index) {
        final place = searchController.searchResults[index];
        return PlaceCard(place: place, showEditOptions: false);
      },
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceBtwSections),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.grey),
            const SizedBox(height: AppSizes.spaceBtwItems),
            Text(
              'No places found',
              style: Theme.of(Get.context!).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            Text(
              'Try searching with different keywords or browse categories',
              style: Theme.of(Get.context!).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spaceBtwSections),
            ElevatedButton(
              onPressed: () => searchController.clearSearch(),
              child: const Text('Clear Search'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: AppSizes.defaultSpace,
          right: AppSizes.defaultSpace,
          top: AppSizes.defaultSpace,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppSectionHeading(
                    title: 'Filter Places',
                    showActionButton: false,
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Iconsax.close_square),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),

              Text('Sort by', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSizes.spaceBtwItems / 2),
              _buildSortingDropdown(),
              const SizedBox(height: AppSizes.spaceBtwSections),

              Text(
                'Minimum Rating',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSizes.spaceBtwItems),
              Obx(
                () => Column(
                  children: [
                    Slider(
                      value: searchController.minRating.value,
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: searchController.minRating.value.toStringAsFixed(
                        1,
                      ),
                      onChanged: (value) {
                        searchController.minRating.value = value;
                      },
                    ),
                    Text(
                      '${searchController.minRating.value.toStringAsFixed(1)} stars and above',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),

              Obx(
                () => CheckboxListTile(
                  title: const Text('Featured Places Only'),
                  value: searchController.showFeaturedOnly.value,
                  onChanged: (value) {
                    searchController.showFeaturedOnly.value = value ?? false;
                  },
                ),
              ),

              const SizedBox(height: AppSizes.spaceBtwSections),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    searchController.applyFiltersAndSearch();
                    Get.back();
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortingDropdown() {
    return Obx(
      () => DropdownButtonFormField<String>(
        initialValue: searchController.selectedSortingOption.value,
        onChanged: (String? newValue) {
          if (newValue != null) {
            searchController.selectedSortingOption.value = newValue;
          }
        },
        items: searchController.sortingOptions.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.md),
        ),
      ),
    );
  }
}
