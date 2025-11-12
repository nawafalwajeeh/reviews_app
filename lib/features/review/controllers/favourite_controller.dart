import 'dart:convert';
import 'package:get/get.dart';
import 'package:reviews_app/data/repositories/place/place_repository.dart';
import '../../../utils/local_storage/storage_utility.dart';
import '../../../utils/popups/loaders.dart';
import '../models/place_model.dart';

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
    try {
      final json = AppLocalStorage.instance().readData('favorites') ?? '';
      if (json != null && json.isNotEmpty) {
        final storedFavorites = jsonDecode(json) as Map<String, dynamic>;
        favorites.assignAll(
          storedFavorites.map((key, value) => MapEntry(key, value as bool)),
        );
      }
    } catch (e) {
      favorites.assignAll({});
      // AppLoaders.errorSnackBar(
      //   title: 'Error',
      //   message: 'Failed to load favorites: $e',
      // );
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

  Future<List<PlaceModel>> favoritePlaces() async {
    /// get all favorite places by thier ids's
    return await PlaceRepository.instance.getFavoritePlaces(
      favorites.keys.toList(),
    );
  }
}
