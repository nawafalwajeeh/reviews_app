import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {},
    'ar': {},
  };

  Future<bool> load() async {
    String lang = locale.languageCode;

    // Load English strings
    String enData = await rootBundle.loadString('assets/l10n/intl_en.arb');
    _localizedValues['en'] = _parseArbFile(enData);

    // Load Arabic strings
    String arData = await rootBundle.loadString('assets/l10n/intl_ar.arb');
    _localizedValues['ar'] = _parseArbFile(arData);

    return true;
  }

  Map<String, String> _parseArbFile(String data) {
    Map<String, dynamic> json = _parseJson(data);
    Map<String, String> result = {};

    json.forEach((key, value) {
      if (!key.startsWith('@@') && key != '@locale' && value is String) {
        result[key] = value;
      }
    });

    return result;
  }

  Map<String, dynamic> _parseJson(String data) {
    // Simple JSON parser for ARB files
    // In a real app, you'd use dart:convert jsonDecode
    // This is a simplified version
    data = data.replaceAll('\n', '').replaceAll('\r', '');
    Map<String, dynamic> result = {};
    RegExp pattern = RegExp(r'"([^"]+)":\s*"([^"]*)"');

    for (var match in pattern.allMatches(data)) {
      if (match.groupCount >= 2) {
        String key = match.group(1)!;
        String value = match.group(2)!;
        result[key] = value;
      }
    }

    return result;
  }

  String get appName =>
      _localizedValues[locale.languageCode]!['appName'] ?? 'Places';
  String get skip => _localizedValues[locale.languageCode]!['skip'] ?? 'Skip';
  String get done => _localizedValues[locale.languageCode]!['done'] ?? 'Done';
  String get submit =>
      _localizedValues[locale.languageCode]!['submit'] ?? 'Submit';
  String get continueText =>
      _localizedValues[locale.languageCode]!['continue'] ?? 'Continue';
  String get logout =>
      _localizedValues[locale.languageCode]!['logout'] ?? 'Logout';
  String get searchInStore =>
      _localizedValues[locale.languageCode]!['searchInStore'] ??
      'Search in Store';

  // OnBoarding Texts
  String get onBoardingTitle1 =>
      _localizedValues[locale.languageCode]!['onBoardingTitle1'] ??
      'Discover Local Gems';
  String get onBoardingTitle2 =>
      _localizedValues[locale.languageCode]!['onBoardingTitle2'] ??
      'Share Your Honest Reviews';
  String get onBoardingTitle3 =>
      _localizedValues[locale.languageCode]!['onBoardingTitle3'] ??
      'Build a Trusted Community';

  String get onBoardingSubTitle1 =>
      _localizedValues[locale.languageCode]!['onBoardingSubTitle1'] ??
      'Explore a world of unique places...';
  String get onBoardingSubTitle2 =>
      _localizedValues[locale.languageCode]!['onBoardingSubTitle2'] ??
      'Your insights help others...';
  String get onBoardingSubTitle3 =>
      _localizedValues[locale.languageCode]!['onBoardingSubTitle3'] ??
      'Join fellow explorers...';

  // Authentication Forms
  String get firstName =>
      _localizedValues[locale.languageCode]!['firstName'] ?? 'First Name';
  String get lastName =>
      _localizedValues[locale.languageCode]!['lastName'] ?? 'Last Name';
  String get email =>
      _localizedValues[locale.languageCode]!['email'] ?? 'E-Mail';
  String get password =>
      _localizedValues[locale.languageCode]!['password'] ?? 'Password';
  String get newPassword =>
      _localizedValues[locale.languageCode]!['newPassword'] ?? 'New Password';
  String get username =>
      _localizedValues[locale.languageCode]!['username'] ?? 'Username';
  String get gender =>
      _localizedValues[locale.languageCode]!['gender'] ?? 'Gender';
  String get birthDate =>
      _localizedValues[locale.languageCode]!['birthDate'] ?? 'Birth Date';
  String get phoneNo =>
      _localizedValues[locale.languageCode]!['phoneNo'] ?? 'Phone Number';
  String get rememberMe =>
      _localizedValues[locale.languageCode]!['rememberMe'] ?? 'Remember Me';
  String get forgetPassword =>
      _localizedValues[locale.languageCode]!['forgetPassword'] ??
      'Forget Password?';
  String get signIn =>
      _localizedValues[locale.languageCode]!['signIn'] ?? 'Sign In';
  String get createAccount =>
      _localizedValues[locale.languageCode]!['createAccount'] ??
      'Create Account';
  String get orSignInWith =>
      _localizedValues[locale.languageCode]!['orSignInWith'] ??
      'or sign in with';
  String get orSignUpWith =>
      _localizedValues[locale.languageCode]!['orSignUpWith'] ??
      'or sign up with';
  String get iAgreeTo =>
      _localizedValues[locale.languageCode]!['iAgreeTo'] ?? 'I agree to';
  String get privacyPolicy =>
      _localizedValues[locale.languageCode]!['privacyPolicy'] ??
      'Privacy Policy';
  String get termsOfUse =>
      _localizedValues[locale.languageCode]!['termsOfUse'] ?? 'Terms of use';
  String get verificationCode =>
      _localizedValues[locale.languageCode]!['verificationCode'] ??
      'verificationCode';
  String get resendEmail =>
      _localizedValues[locale.languageCode]!['resendEmail'] ?? 'Resend Email';
  String get resendEmailIn =>
      _localizedValues[locale.languageCode]!['resendEmailIn'] ??
      'Resend email in';

  // Authentication Headings
  String get loginTitle =>
      _localizedValues[locale.languageCode]!['loginTitle'] ?? 'Welcome back,';
  String get loginSubTitle =>
      _localizedValues[locale.languageCode]!['loginSubTitle'] ??
      'Login to continue reviewing your favorite places.';
  String get signupTitle =>
      _localizedValues[locale.languageCode]!['signupTitle'] ??
      "Let's create your account";
  String get forgetPasswordTitle =>
      _localizedValues[locale.languageCode]!['forgetPasswordTitle'] ??
      'Forget password';
  String get forgetPasswordSubTitle =>
      _localizedValues[locale.languageCode]!['forgetPasswordSubTitle'] ??
      "Don't worry sometimes people can forget too...";

  // Places
  String get popularPlaces =>
      _localizedValues[locale.languageCode]!['popularPlaces'] ??
      'Popular Places';
  String get homeAppbarTitle =>
      _localizedValues[locale.languageCode]!['homeAppbarTitle'] ??
      'Good day for discovering';
  String get homeAppbarSubTitle =>
      _localizedValues[locale.languageCode]!['homeAppbarSubTitle'] ??
      'Nawaf Alwajeeh';

  // Navigation
  String get navigationHome =>
      _localizedValues[locale.languageCode]!['navigationHome'] ?? 'Home';
  String get navigationPlaces =>
      _localizedValues[locale.languageCode]!['navigationPlaces'] ?? 'Places';
  String get navigationMap =>
      _localizedValues[locale.languageCode]!['navigationMap'] ?? 'Map';
  String get navigationWishlist =>
      _localizedValues[locale.languageCode]!['navigationWishlist'] ??
      'Wishlist';
  String get navigationProfile =>
      _localizedValues[locale.languageCode]!['navigationProfile'] ?? 'Profile';

  // Favorites
  String get favorites =>
      _localizedValues[locale.languageCode]!['favorites'] ?? 'Favorites';
  String get searchForFavoritePlace =>
      _localizedValues[locale.languageCode]!['searchForFavoritePlace'] ??
      'Search for favorite place';
  String get wishlistEmpty =>
      _localizedValues[locale.languageCode]!['wishlistEmpty'] ??
      'Whoops! Wishlist is Empty...';
  String get letsAddSome =>
      _localizedValues[locale.languageCode]!['letsAddSome'] ?? "Let's add some";

  // Search
  String get searchPlaces =>
      _localizedValues[locale.languageCode]!['searchPlaces'] ?? 'Search Places';
  String get searchPlacesCategories =>
      _localizedValues[locale.languageCode]!['searchPlacesCategories'] ??
      'Search places, categories...';
  String get cancel =>
      _localizedValues[locale.languageCode]!['cancel'] ?? 'Cancel';
  String get noPlacesFound =>
      _localizedValues[locale.languageCode]!['noPlacesFound'] ??
      'No places found';
  String get tryDifferentKeywords =>
      _localizedValues[locale.languageCode]!['tryDifferentKeywords'] ??
      'Try searching with different keywords...';
  String get clearSearch =>
      _localizedValues[locale.languageCode]!['clearSearch'] ?? 'Clear Search';
  String get browseCategories =>
      _localizedValues[locale.languageCode]!['browseCategories'] ??
      'Browse Categories';
  String get trendingPlaces =>
      _localizedValues[locale.languageCode]!['trendingPlaces'] ??
      'Trending Places';
  String get allCategories =>
      _localizedValues[locale.languageCode]!['allCategories'] ??
      'All Categories';
  String get viewAll =>
      _localizedValues[locale.languageCode]!['viewAll'] ?? 'View All';
  String get exploreAllCategories =>
      _localizedValues[locale.languageCode]!['exploreAllCategories'] ??
      'Explore all categories';

  // Reviews & Comments
  String get ratingReviews =>
      _localizedValues[locale.languageCode]!['ratingReviews'] ??
      'Rating & Reviews';
  String get ratingsVerified =>
      _localizedValues[locale.languageCode]!['ratingsVerified'] ??
      'Ratings and reviews are verified...';
  String get reviews =>
      _localizedValues[locale.languageCode]!['reviews'] ?? 'reviews';
  String get noReviewsFound =>
      _localizedValues[locale.languageCode]!['noReviewsFound'] ??
      'No reviews found for this place.';

  String get comments =>
      _localizedValues[locale.languageCode]!['comments'] ?? 'Comments';
  String get noCommentsYet =>
      _localizedValues[locale.languageCode]!['noCommentsYet'] ??
      'No comments yet';
  String get beFirstToComment =>
      _localizedValues[locale.languageCode]!['beFirstToComment'] ??
      'Be the first to comment!';

  // Place Details
  String get description =>
      _localizedValues[locale.languageCode]!['description'] ?? 'Description';
  String get tags => _localizedValues[locale.languageCode]!['tags'] ?? 'Tags';
  String get locationOnMap =>
      _localizedValues[locale.languageCode]!['locationOnMap'] ??
      'Location on Map';
  String get locationCoordinates =>
      _localizedValues[locale.languageCode]!['locationCoordinates'] ??
      'Location Coordinates';

  // Review Writing
  String get writeReview =>
      _localizedValues[locale.languageCode]!['writeReview'] ?? 'Write a Review';
  String get editReview =>
      _localizedValues[locale.languageCode]!['editReview'] ??
      'Edit Your Review';
  String get yourReviewSubmitted =>
      _localizedValues[locale.languageCode]!['yourReviewSubmitted'] ??
      'Your Review (Submitted)';
  String get rateExperience =>
      _localizedValues[locale.languageCode]!['rateExperience'] ??
      'Rate your experience *';
  String get shareExperience =>
      _localizedValues[locale.languageCode]!['shareExperience'] ??
      'Share your experience... *';
  String get additionalQuestions =>
      _localizedValues[locale.languageCode]!['additionalQuestions'] ??
      'Additional Questions';
  String get updateReview =>
      _localizedValues[locale.languageCode]!['updateReview'] ?? 'Update Review';
  String get deleteReview =>
      _localizedValues[locale.languageCode]!['deleteReview'] ?? 'Delete Review';
  String get deleteReviewConfirmation =>
      _localizedValues[locale.languageCode]!['deleteReviewConfirmation'] ??
      'Are you sure you want to delete your review?...';

  // QR Code
  String get placeQRCode =>
      _localizedValues[locale.languageCode]!['placeQRCode'] ?? 'Place QR Code';
  String get scanToView =>
      _localizedValues[locale.languageCode]!['scanToView'] ??
      'Scan to view this place';
  String get sharePDF =>
      _localizedValues[locale.languageCode]!['sharePDF'] ?? 'Share PDF';
  String get savePDF =>
      _localizedValues[locale.languageCode]!['savePDF'] ?? 'Save PDF';

  // Place Creation
  String get discoverPlaces =>
      _localizedValues[locale.languageCode]!['discoverPlaces'] ??
      'Discover Places';
  String get createNewPlace =>
      _localizedValues[locale.languageCode]!['createNewPlace'] ??
      'Create New Place';
  String get shareFavoriteSpot =>
      _localizedValues[locale.languageCode]!['shareFavoriteSpot'] ??
      'Share your favorite spot with the community';
  String get editPlace =>
      _localizedValues[locale.languageCode]!['editPlace'] ?? 'Edit Place';
  String get updatePlaceInfo =>
      _localizedValues[locale.languageCode]!['updatePlaceInfo'] ??
      'Update your place information';

  // Form Fields
  String get placeName =>
      _localizedValues[locale.languageCode]!['placeName'] ?? 'Place Name';
  String get enterPlaceName =>
      _localizedValues[locale.languageCode]!['enterPlaceName'] ??
      'Enter the name of this place';
  String get selectCategory =>
      _localizedValues[locale.languageCode]!['selectCategory'] ??
      'Select Category';
  String get placeAddress =>
      _localizedValues[locale.languageCode]!['placeAddress'] ?? 'Place Address';
  String get placeDescription =>
      _localizedValues[locale.languageCode]!['placeDescription'] ?? 'Place Description';
  String get change =>
      _localizedValues[locale.languageCode]!['change'] ?? 'Change';
  String get selectAddress =>
      _localizedValues[locale.languageCode]!['selectAddress'] ??
      'Select Address';
  String get enterDescription =>
      _localizedValues[locale.languageCode]!['enterDescription'] ??
      'Tell us what makes this place special...';
  String get enterPhoneNumber =>
      _localizedValues[locale.languageCode]!['enterPhoneNumber'] ??
      'Enter your phone number';
  String get websiteUrlOptional =>
      _localizedValues[locale.languageCode]!['websiteUrlOptional'] ??
      'Website URL (Optional)';

  // Guidelines
  String get communityGuidelines =>
      _localizedValues[locale.languageCode]!['communityGuidelines'] ??
      'Community Guidelines';
  String get ensureAppropriate =>
      _localizedValues[locale.languageCode]!['ensureAppropriate'] ??
      'Please ensure your place is appropriate...';

  // Photos
  String get addPhotos =>
      _localizedValues[locale.languageCode]!['addPhotos'] ?? 'Add Photos';
  String uploadPhotos(int maxImages) =>
      (_localizedValues[locale.languageCode]!['uploadPhotos'] ??
              'Upload up to {maxImages} photos of this place')
          .replaceAll('{maxImages}', maxImages.toString());
  String get existingPhotos =>
      _localizedValues[locale.languageCode]!['existingPhotos'] ??
      'Existing Photos';
  String get newPhotos =>
      _localizedValues[locale.languageCode]!['newPhotos'] ?? 'New Photos';

  // Custom Questions
  String get customQuestionsOptional =>
      _localizedValues[locale.languageCode]!['customQuestionsOptional'] ??
      'Custom Questions (Optional)';
  String get addQuestion =>
      _localizedValues[locale.languageCode]!['addQuestion'] ?? 'Add Question';
  String get noCustomQuestions =>
      _localizedValues[locale.languageCode]!['noCustomQuestions'] ??
      'No custom questions added';
  String get addUpToQuestions =>
      _localizedValues[locale.languageCode]!['addUpToQuestions'] ??
      'Tap the + button to add up to 4 optional questions';
  String get question =>
      _localizedValues[locale.languageCode]!['question'] ?? 'Question';
  String get enterQuestion =>
      _localizedValues[locale.languageCode]!['enterQuestion'] ??
      'Enter your question here...';
  String get answerType =>
      _localizedValues[locale.languageCode]!['answerType'] ?? 'Answer Type';
  String get required =>
      _localizedValues[locale.languageCode]!['required'] ?? 'Required';
  String get starRating =>
      _localizedValues[locale.languageCode]!['starRating'] ?? 'Star Rating';
  String get yesNo =>
      _localizedValues[locale.languageCode]!['yesNo'] ?? 'Yes/No';
  String get textAnswer =>
      _localizedValues[locale.languageCode]!['textAnswer'] ?? 'Text Answer';

  // Premium Features
  String get premiumFeatures =>
      _localizedValues[locale.languageCode]!['premiumFeatures'] ??
      'Premium Features';
  String get unlockPremium =>
      _localizedValues[locale.languageCode]!['unlockPremium'] ??
      'Unlock Premium';
  String get getUnlimitedAccess =>
      _localizedValues[locale.languageCode]!['getUnlimitedAccess'] ??
      'Get unlimited access to premium features...';
  String get everythingYouNeed =>
      _localizedValues[locale.languageCode]!['everythingYouNeed'] ??
      'Everything you need for the perfect review experience';

  // Subscription
  String get subscriptionStatus =>
      _localizedValues[locale.languageCode]!['subscriptionStatus'] ??
      'Subscription Status';
  String get manage =>
      _localizedValues[locale.languageCode]!['manage'] ?? 'Manage';
  String get premiumMember =>
      _localizedValues[locale.languageCode]!['premiumMember'] ??
      'Premium Member';
  String get expires =>
      _localizedValues[locale.languageCode]!['expires'] ?? 'Expires';
  String get active =>
      _localizedValues[locale.languageCode]!['active'] ?? 'ACTIVE';
  String get createPlaces =>
      _localizedValues[locale.languageCode]!['createPlaces'] ?? 'Create Places';
  String get upgrade =>
      _localizedValues[locale.languageCode]!['upgrade'] ?? 'Upgrade';
  String get premiumFeature =>
      _localizedValues[locale.languageCode]!['premiumFeature'] ??
      'Premium Feature';
  String get upgradeToCreate =>
      _localizedValues[locale.languageCode]!['upgradeToCreate'] ??
      'Upgrade to create unlimited places';

  // Network
  String get internetConnected =>
      _localizedValues[locale.languageCode]!['internetConnected'] ??
      'Internet is Connected';
  String get noInternetConnection =>
      _localizedValues[locale.languageCode]!['noInternetConnection'] ??
      'No Internet Connection';

  // Validation Messages
  String validationRequired(String fieldName) =>
      (_localizedValues[locale.languageCode]!['validationRequired'] ??
              '{fieldName} is required.')
          .replaceAll('{fieldName}', fieldName);
  String get validationUsername =>
      _localizedValues[locale.languageCode]!['validationUsername'] ??
      'Username is not valid.';
  String get validationEmail =>
      _localizedValues[locale.languageCode]!['validationEmail'] ??
      'Invalid email address.';
  String get validationPassword =>
      _localizedValues[locale.languageCode]!['validationPassword'] ??
      'Password must be at least 6 characters long...';
  String get validationPhone =>
      _localizedValues[locale.languageCode]!['validationPhone'] ??
      'Invalid phone number format (12 digits required).';
  String get validationWebsite =>
      _localizedValues[locale.languageCode]!['validationWebsite'] ??
      'Please enter a valid website URL...';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
