import 'package:flutter/material.dart';
import 'package:reviews_app/features/review/controllers/category_controller.dart';
import 'package:reviews_app/features/review/models/category_model.dart'
    show CategoryModel;
import '../../../data/services/category/category_formatter.dart';
import '../../../features/review/models/category_mapper.dart';
import '../../../utils/constants/colors.dart';
import '../../../localization/app_localizations.dart';

class CategoryNameText extends StatelessWidget {
  final String categoryId;
  final bool showIcon;
  final double iconSize;
  final double spacing;
  final bool isSingular;
  final Color? textColor;

  const CategoryNameText({
    super.key,
    required this.categoryId,
    this.showIcon = true,
    this.iconSize = 16.0,
    this.spacing = 6.0,
    this.isSingular = true,
    this.textColor = AppColors.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final controller = CategoryController.instance;
    final appLocalizations = AppLocalizations.of(context);

    return FutureBuilder<String>(
      future: controller.getLocalizedCategoryName(categoryId, context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: 80,
            child: LinearProgressIndicator(
              color: AppColors.primaryColor,
              backgroundColor: AppColors.primaryColor.withValues(alpha: 0.2),
            ),
          );
        }

        if (snapshot.hasError) {
          return Text(
            appLocalizations.errorLoading,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
          );
        }

        final pluralCategoryName =
            snapshot.data ?? appLocalizations.categoryNotFound;

        // Convert to singular form for display
        final singularCategoryName =
            CategoryFormatter.getLocalizedSingularNameInContext(
              pluralCategoryName,
              context,
            );
        debugPrint('Singular CategoryName: $singularCategoryName');

        // Get icon data using CategoryMapper
        final iconData = _getCategoryIconData(categoryId, pluralCategoryName);

        if (showIcon && iconData != null) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(iconData, size: iconSize, color: textColor),
              SizedBox(width: spacing),
              Expanded(
                child: Text(
                  isSingular ? singularCategoryName : pluralCategoryName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    // color:  AppColors.primaryColor,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }

        // Original text-only version as fallback
        return Text(
          singularCategoryName,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.primaryColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  // Helper method to get icon data using your existing CategoryMapper
  IconData? _getCategoryIconData(String categoryId, String categoryName) {
    try {
      // First try to get the category model to access iconKey
      final category = allMockCategories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => allMockCategories.firstWhere(
          (cat) => cat.name == categoryName,
          orElse: () => _getDefaultCategory(),
        ),
      );

      return CategoryMapper.getIcon(category.iconKey);
    } catch (e) {
      // Fallback: map category name directly to icon key
      final iconKey = _getIconKeyFromCategoryName(categoryName);
      return CategoryMapper.getIcon(iconKey);
    }
  }

  // Fallback mapping from category name to icon key
  String _getIconKeyFromCategoryName(String categoryName) {
    switch (categoryName) {
      // Food & Drink
      case 'Restaurants':
        return 'dining_fork';
      case 'Cafes':
        return 'coffee_cup';
      case 'Bars & Pubs':
        return 'pint_glass';
      case 'Nightclubs':
        return 'disco_ball';
      case 'Bakeries':
        return 'bread_loaf';
      case 'Dessert Shops':
        return 'ice_cream';
      case 'Food Trucks':
        return 'truck_food';

      // Accommodation & Residence
      case 'Hotels':
        return 'hotel_star';
      case 'Motels':
        return 'motel_sign';
      case 'Hostels':
        return 'hostel_bed';
      case 'Apartments':
        return 'apartment_building';
      case 'Housing Communities':
        return 'community_house';

      // Health & Wellness
      case 'Hospitals':
        return 'hospital_cross';
      case 'Clinics':
        return 'medical_bag';
      case 'Pharmacies':
        return 'pharmacy_pill';
      case 'Dentists':
        return 'dental_drill';
      case 'Therapy Centers':
        return 'therapy_hands';
      case 'Veterinarians':
        return 'vet_paw';

      // Education & Culture
      case 'Schools':
        return 'school_bag';
      case 'Universities':
        return 'university_hat';
      case 'Libraries':
        return 'library_books';
      case 'Museums':
        return 'museum_pillar';
      case 'Art Galleries':
        return 'gallery_palette';
      case 'Historical Sites':
        return 'historical_monument';

      // Entertainment & Recreation
      case 'Parks':
        return 'park_bench';
      case 'Playgrounds':
        return 'playground_swing';
      case 'Stadiums':
        return 'stadium_goal';
      case 'Theatres':
        return 'theater_mask';
      case 'Movie Theatres':
        return 'cinema_reel';
      case 'Gyms':
        return 'gym_dumbbell';
      case 'Spas':
        return 'spa_stone';
      case 'Fitness Studios':
        return 'studio_weights';

      // Retail & Shopping
      case 'Malls':
        return 'mall_basket';
      case 'Supermarkets':
        return 'market_cart';
      case 'Convenience Stores':
        return 'cstore_door';
      case 'Electronics Stores':
        return 'electronics_chip';
      case 'Clothing Stores':
        return 'clothing_hanger';
      case 'Bookstores':
        return 'bookstore_open';
      case 'Hardware Stores':
        return 'hardware_wrench';
      case 'Pet Stores':
        return 'petstore_bone';

      // Service & Utility
      case 'Gas Stations':
        return 'gas_pump';
      case 'Car Repair':
        return 'car_wrench';
      case 'Banks':
        return 'bank_vault';
      case 'ATMs':
        return 'atm_machine';
      case 'Post Offices':
        return 'post_stamp';
      case 'Laundromats':
        return 'laundry_washer';
      case 'Dry Cleaners':
        return 'dryclean_shirt';
      case 'Hair Salons':
        return 'salon_scissors';
      case 'Barbershops':
        return 'barber_pole';

      // Transport & Travel
      case 'Bus Stops':
        return 'bus_stop';
      case 'Train Stations':
        return 'train_rail';
      case 'Airports':
        return 'airport_plane';
      case 'Parking Lots':
        return 'parking_sign';
      case 'Car Rental':
        return 'rental_key';

      // Government & Public Safety
      case 'Police Stations':
        return 'police_badge';
      case 'Fire Stations':
        return 'fire_truck';
      case 'Government Offices':
        return 'government_flag';

      // Spiritual & Religious
      case 'Churches':
        return 'church_cross';
      case 'Mosques':
        return 'mosque_dome';
      case 'Temples':
        return 'temple_statue';

      // Business & Work
      case 'Offices & Coworking':
        return 'office_desk';
      case 'Factories & Industrial':
        return 'factory_gear';
      case 'Conference Centers':
        return 'conference_mic';

      // Catch All
      case 'Other':
        return 'misc_question';

      default:
        return 'default_icon';
    }
  }

  // Default category for fallback
  CategoryModel _getDefaultCategory() {
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
//-------------------------
// import 'package:flutter/material.dart';
// import 'package:reviews_app/features/review/controllers/category_controller.dart';
// import '../../../data/services/category/category_formatter.dart';
// import '../../../utils/constants/colors.dart';
// import '../../../localization/app_localizations.dart';

// class CategoryNameText extends StatelessWidget {
//   final String categoryId;

//   const CategoryNameText({super.key, required this.categoryId});

//   @override
//   Widget build(BuildContext context) {
//     final controller = CategoryController.instance;
//     final appLocalizations = AppLocalizations.of(context);

//     return FutureBuilder<String>(
//       future: controller.getLocalizedCategoryName(categoryId, context),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return SizedBox(
//             width: 80,
//             child: LinearProgressIndicator(
//               color: AppColors.primaryColor,
//               backgroundColor: AppColors.primaryColor.withValues(alpha: 0.2),
//             ),
//           );
//         }

//         if (snapshot.hasError) {
//           return Text(
//             appLocalizations.errorLoading,
//             style: Theme.of(
//               context,
//             ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
//           );
//         }

//         final pluralCategoryName =
//             snapshot.data ?? appLocalizations.categoryNotFound;

//         // Convert to singular form for display
//         final singularCategoryName =
//             CategoryFormatter.getLocalizedSingularNameInContext(
//               pluralCategoryName,
//               context,
//             );
//         debugPrint('Singular CategoryName: $singularCategoryName');
//         return Text(
//           singularCategoryName,
//           style: Theme.of(
//             context,
//           ).textTheme.bodyMedium?.copyWith(color: AppColors.primaryColor),
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         );
//       },
//     );
//   }
// }





//--------------------------------
// import 'package:flutter/material.dart';
// import 'package:reviews_app/features/review/controllers/category_controller.dart';
// import '../../../utils/constants/colors.dart';
// import '../../../localization/app_localizations.dart';

// class CategoryNameText extends StatelessWidget {
//   final String categoryId;

//   const CategoryNameText({super.key, required this.categoryId});

//   @override
//   Widget build(BuildContext context) {
//     final controller = CategoryController.instance;
//     final appLocalizations = AppLocalizations.of(context);

//     return FutureBuilder<String>(
//       // Updated to pass the context for localization
//       future: controller.getLocalizedCategoryName(categoryId, context),
//       builder: (context, snapshot) {
//         // Show a small loading indicator while fetching
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return SizedBox(
//             width: 80,
//             child: LinearProgressIndicator(
//               color: AppColors.primaryColor,
//               backgroundColor: AppColors.primaryColor.withValues(alpha:0.2),
//             ),
//           );
//         }

//         // Handle error state
//         if (snapshot.hasError) {
//           return Text(
//             appLocalizations.errorLoading, // Add this to your ARB files
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               color: AppColors.error,
//             ),
//           );
//         }

//         // Display the retrieved localized category name
//         final categoryName = snapshot.data ?? appLocalizations.categoryNotFound;

//         return Text(
//           categoryName,
//           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//             color: AppColors.primaryColor,
//           ),
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         );
//       },
//     );
//   }
// }


//--------------------------------
// import 'package:flutter/material.dart';
// import 'package:reviews_app/features/review/controllers/category_controller.dart';
// import 'package:reviews_app/localization/app_localizations.dart';

// import '../../../utils/constants/colors.dart';

// class CategoryNameText extends StatelessWidget {
//   final String categoryId;

//   const CategoryNameText({super.key, required this.categoryId});

//   @override
//   Widget build(BuildContext context) {
//     // We instantiate the repository here to fetch the data.
//     final controller = CategoryController.instance;

//     return FutureBuilder<String>(
//       // Call the method to asynchronously fetch the name
//       future: controller.getCategoryName(categoryId),
//       builder: (context, snapshot) {
//         // Show a small loading indicator while fetching
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const SizedBox(
//             width: 80,
//             child: LinearProgressIndicator(color: AppColors.primaryColor),
//           );
//         }

//         // Handle error state
//         if (snapshot.hasError) {
//           return Text(
//             'Error Loading',
//             // AppLocalizations.of(  context).errorLoading),
//             style: Theme.of(
//               context,
//             ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
//           );
//         }

//         // Display the retrieved category name
//         final categoryName = snapshot.data ?? 'Category Not Found';

//         return Text(
//           categoryName,
//           style: Theme.of(
//             context,
//           ).textTheme.bodyMedium?.copyWith(color: AppColors.primaryColor),
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         );
//       },
//     );
//   }
// }
