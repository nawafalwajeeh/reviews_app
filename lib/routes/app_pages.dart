import 'package:get/get.dart';
import 'package:reviews_app/features/authentication/screens/login/login.dart';
import 'package:reviews_app/features/authentication/screens/onboarding/onboarding.dart';
import 'package:reviews_app/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:reviews_app/features/authentication/screens/signup/signup_screen.dart';
import 'package:reviews_app/features/authentication/screens/signup/verify_email.dart';
import 'package:reviews_app/features/personalization/screens/address/address.dart';
import 'package:reviews_app/features/personalization/screens/profile/profile.dart';
import 'package:reviews_app/features/personalization/screens/settings/settings.dart';
import 'package:reviews_app/features/review/screens/gallery/gallery.dart';
import 'package:reviews_app/features/review/screens/home/home.dart';
import 'package:reviews_app/features/review/screens/place/places_screen.dart';
import 'package:reviews_app/features/review/screens/place_details/place_details.dart';
import 'package:reviews_app/features/review/screens/search/search.dart';
import 'package:reviews_app/features/review/screens/wishlist/wishlist.dart';
import '../features/review/models/place_model.dart';
import '../features/review/screens/place_reviews/place_comments.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.favourites, page: () => const FavouriteScreen()),
    GetPage(name: AppRoutes.settings, page: () => const SettingsScreen()),
    GetPage(name: AppRoutes.search, page: () => SearchScreen()),
    GetPage(name: AppRoutes.allPlacess, page: () => const AllPlacesScreen()),
    GetPage(name: AppRoutes.gallery, page: () => const ImageGalleryScreen()),
    // GetPage(name: AppRoutes.gallery, page: () => const ImageGalleryScreen()),
    GetPage(
      name: AppRoutes.placesDetail,
      page: () => PlaceDetailsScreen(place: PlaceModel.empty()),
    ),
    GetPage(
      name: AppRoutes.placeReviews,
      page: () => PlaceCommentsScreen(place: PlaceModel.empty()),
    ),
    GetPage(name: AppRoutes.userProfile, page: () => const ProfileScreen()),
    GetPage(name: AppRoutes.userAddress, page: () => const UserAddressScreen()),
    GetPage(name: AppRoutes.signup, page: () => const SignupScreen()),
    GetPage(name: AppRoutes.verifyEmail, page: () => const VerifyEmailScreen()),
    GetPage(name: AppRoutes.signIn, page: () => const LoginScreen()),
    GetPage(
      name: AppRoutes.forgetPassword,
      page: () => const ForgetPasswordScreen(),
    ),
    GetPage(name: AppRoutes.onBoarding, page: () => const OnBoardingScreen()),
    // Add more GetPage entries as needed
  ];
}
