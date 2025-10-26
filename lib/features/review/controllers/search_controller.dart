// import 'package:get/get.dart';
// import 'package:shop_app/data/repositories/product/product_repository.dart';
// import 'package:shop_app/features/shop/models/product_model.dart';
// import 'package:shop_app/utils/popups/loaders.dart';

// class AppSearchController extends GetxController {
//   static AppSearchController get instance => Get.find();

//   /// Variables
//   RxList<ProductModel> searchResults = <ProductModel>[].obs;
//   RxBool isLoading = false.obs;
//   RxDouble minPrice = 0.0.obs;
//   RxDouble maxPrice = double.infinity.obs;
//   final RxString searchQuery = ''.obs;
//   RxString lastSearchQuery = ''.obs;
//   final RxString selectedCategoryId = ''.obs;
//   List<String> sortingOptions = [
//     'Name',
//     'Lowest Price',
//     'Highest Price',
//     'Popular',
//     'Newest',
//     'Suitable',
//   ];
//   RxString selectedSortingOption = 'Name'.obs;

//   void search() {
//     searchProducts(
//       searchQuery.value,
//       categoryId: selectedCategoryId.value.isNotEmpty
//           ? selectedCategoryId.value
//           : null,
//       minPrice: minPrice.value != 0.0 ? minPrice.value : null,
//       maxPrice: maxPrice.value != double.infinity ? minPrice.value : null,
//       sortingOption: selectedSortingOption.value,
//     );
//   }

//   void searchProducts(
//     String query, {
//     String? categoryId,
//     String? brandId,
//     double? minPrice,
//     double? maxPrice,
//     required String sortingOption,
//   }) async {
//     lastSearchQuery.value = query;
//     isLoading.value = true;

//     try {
//       final results = await ProductRepository.instance.searchProducts(
//         query,
//         categoryId: categoryId,
//         brandId: brandId,
//         minPrice: minPrice,
//         maxPrice: maxPrice,
//       );

//       // Apply sorting
//       switch (sortingOption) {
//         case 'Name':
//           // sort by name
//           results.sort((a, b) => a.title.compareTo(b.title));
//           break;
//         case 'Lowest Price':
//           // sort by price ascending order
//           results.sort((a, b) => a.price.compareTo(b.price));
//           break;
//         case 'Highest Price':
//           // sort by price descending order
//           results.sort((a, b) => b.price.compareTo(a.price));
//           break;
//       }

//       // Update searchResults with sorted results
//       searchResults.assignAll(results);
//     } catch (e) {
//       AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }
