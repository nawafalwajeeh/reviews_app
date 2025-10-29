import 'package:get/get.dart';

import '../models/place_model.dart';

class PlaceController extends GetxController {
  static PlaceController get instance => Get.find();

  //   final demoPlaces = [
  //   Place(
  //     imageUrl:
  //         'https://images.unsplash.com/photo-1470338745628-171cf53de3a8?auto=format&fit=crop&w=800&q=80',
  //     title: 'Bella Vista Restaurant',
  //     location: 'Downtown • 2.5 km away',
  //     category: 'Italian Cuisine',
  //     subtitle: 'Open until 11:00 PM',
  //     rating: 4.8,
  //   ),
  //   Place(
  //     imageUrl:
  //         'https://images.unsplash.com/photo-1468273519810-d3fe4c125cdb?auto=format&fit=crop&w=800&q=80',
  //     title: 'Riverside Elementary School',
  //     location: 'Westside • 1.8 km away',
  //     category: 'Public School',
  //     subtitle: 'Grades K-5 • Excellent Rating',
  //     rating: 4.6,
  //   ),
  //   Place(
  //     imageUrl:
  //         'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
  //     title: 'The Coffee Corner',
  //     location: 'City Center • 0.8 km away',
  //     category: 'Coffee & Pastries',
  //     subtitle: 'Open 24/7 • Free WiFi',
  //     rating: 4.9,
  //     isFavorite: true,
  //   ),
  //   Place(
  //     imageUrl:
  //         'https://images.unsplash.com/photo-1614957004131-9e8f2a13123c?auto=format&fit=crop&w=800&q=80',
  //     title: 'Grand Plaza Hotel',
  //     location: 'Business District • 3.2 km away',
  //     category: 'Luxury Hotel',
  //     subtitle: '5-Star • Pool & Spa',
  //     rating: 4.7,
  //   ),
  // ];

  // Demo place data (NOTE: These asset paths must exist in your Flutter project)
  final demoPlaces = [
    PlaceModel(
      thumbnail:
          'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
      images: [
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
      ],
      title: 'Tropical Paradise Resort',
      location: 'Maldives, Indian Ocean',
      category: 'Resort',
      description:
          'Experience the serene beauty of the Maldives with our overwater bungalows and crystal-clear lagoon access. Perfect for honeymooners and families looking for a luxury escape. This detailed description helps guests understand the unique offerings and atmosphere of the destination.',
      rating: 4.8,
      isFavorite: true,
      amenities: [
        'Free Wi-Fi',
        'Swimming Pool',
        'Beach Access',
        'Restaurant',
        'Spa',
        'Gym',
      ],
      id: '1',
    ),
    PlaceModel(
      thumbnail:
          'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
      images: [
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
      ],
      title: 'Tropical Paradise Resort',
      location: 'Maldives, Indian Ocean',
      category: 'Resort',
      description:
          'Experience the serene beauty of the Maldives with our overwater bungalows and crystal-clear lagoon access. Perfect for honeymooners and families looking for a luxury escape. This detailed description helps guests understand the unique offerings and atmosphere of the destination.',
      rating: 4.8,
      isFavorite: true,
      amenities: [
        'Free Wi-Fi',
        'Swimming Pool',
        'Beach Access',
        'Restaurant',
        'Spa',
        'Gym',
      ],
      id: '2',
    ),
  ];

  final List<String> categories = const [
    'All',
    'Restaurant',
    'Hotel',
    'School',
    'Cafe',
    'Park',
  ];
}

/*
import 'package:get/get.dart';
import 'package:shop_app/data/repositories/product/product_repository.dart';
import 'package:shop_app/features/shop/models/product_model.dart';
import 'package:shop_app/utils/constants/enums.dart';
import 'package:shop_app/utils/popups/loaders.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();

  /// Variables
  final isLoading = false.obs;
  final productRepository = Get.put(ProductRepository());
  RxList<ProductModel> featuredProducts = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchFeaturedProducts();
  }

  Future<void> fetchFeaturedProducts() async {
    try {
      // Show loader while loading products
      isLoading.value = true;

      // Fetch Products
      final products = await productRepository.getFeaturedProducts();

      // Assign Products to the list
      featuredProducts.assignAll(products);
    } catch (e) {
      AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<ProductModel>> fetchAllFeaturedProducts() async {
    try {
      // Fetch Products
      final products = await productRepository.getAllFeaturedProducts();
      return products;
    } catch (e) {
      AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  /// Get Product Price or price range for variations.
  String getProductPrice(ProductModel product) {
    double smallestPrice = double.infinity;
    double largestPrice = 0.0;

    // if no variations exist, return the simple price or sale price.
    if (product.productType == ProductType.single.toString()) {
      return (product.salePrice > 0 ? product.salePrice : product.price)
          .toString();
    } else {
      // Calculate the smallest and largest prices among variations
      for (var variation in product.productVariations!) {
        // Determine the price to consider (salePrice if available, otherwise regular price)
        double priceToConsider = variation.salePrice > 0.0
            ? variation.salePrice
            : variation.price;

        // Update smallest and largest prices
        if (priceToConsider < smallestPrice) {
          smallestPrice = priceToConsider;
        }

        if (priceToConsider > largestPrice) {
          largestPrice = priceToConsider;
        }
      }
    }

    // If smallest and largest prices are the same, reaturn a single price
    if (smallestPrice.isEqual(largestPrice)) {
      return largestPrice.toString();
    } else {
      // Otherwise, return a price range
      return '$smallestPrice -\$$largestPrice';
    }
  }

  /// Calculate Discount Percentage
  String? calculateSalePercentage(double originalPrice, double? salePrice) {
    if (salePrice == null || salePrice <= 0.0) return null;
    if (originalPrice <= 0) return null;

    double percentage = ((originalPrice - salePrice) / originalPrice) * 100;
    return percentage.toStringAsFixed(0);
  }

  /// Check Product Stock Status
  String getProductStockStatus(int stock) {
    return stock > 0 ? 'In Stock' : 'Out of Stock';
  }
}
*/
