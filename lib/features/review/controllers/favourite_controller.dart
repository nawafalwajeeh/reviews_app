import 'dart:convert';

import 'package:get/get.dart';
// import 'package:reviews_app/data/repositories/place/place_repository.dart';
// import 'package:reviews_app/features/review/models/place_model.dart';

import '../../../utils/local_storage/storage_utility.dart';
import '../../../utils/popups/loaders.dart';

class FavouritesController extends GetxController {
  static FavouritesController get instance => Get.find();

  /// Variables
  final favorites = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    initFavourites();
  }

  // Method to initialize favouirites by reading from storage
  void initFavourites() {
    final json = AppLocalStorage.instance().readData('favorites');
    if (json != null) {
      final storedFavorites = jsonDecode(json) as Map<String, dynamic>;
      favorites.assignAll(
        storedFavorites.map((key, value) => MapEntry(key, value as bool)),
      );
    }
  }

  bool isFavorite(String placeId) {
    return favorites[placeId] ?? false;
  }

  void toggleFavoritePlaces(String placeId) {
    if (!favorites.containsKey(placeId)) {
      favorites[placeId] = true;
      saveFavoritesToStorage();
      AppLoaders.customToast(message: 'Place has been added to Wishlist');
    } else {
      AppLocalStorage.instance().removeData(placeId);
      favorites.remove(placeId);
      saveFavoritesToStorage();
      favorites.refresh();
      AppLoaders.customToast(message: 'Place has been removed from Wishlist');
    }
  }

  void saveFavoritesToStorage() {
    final encodedFavorites = json.encode(favorites);
    AppLocalStorage.instance().writeData('favorites', encodedFavorites);
  }

  // Future<List<PlaceModel>> favoritePlaces() async {
  //   /// get all favorite places by thier ids's
  //   return await PlaceRepository.instance.getFavouritePlaces(
  //     favorites.keys.toList(),
  //   );
  // }
}
