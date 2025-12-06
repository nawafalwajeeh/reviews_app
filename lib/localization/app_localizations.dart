import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class GlobalLocaleHelper {
  static AppLocalizations get _loc {
    final context = Get.key.currentContext;
    if (context != null) {
      return AppLocalizations.of(context);
    }
    throw FlutterError('GlobalLocaleHelper accessed without valid context');
  }
}

// Create a short alias for even quicker access
AppLocalizations get txt => GlobalLocaleHelper._loc;

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
    'de': {},
    'es': {},
    'fr': {},
    'it': {},
    'ja': {},
    'ko': {},
    'pt': {},
    'ru': {},
    'zh': {},
  };

  Future<bool> load() async {
    // String lang = locale.languageCode;
    // Load English strings
    String enData = await rootBundle.loadString('assets/l10n/intl_en.arb');
    _localizedValues['en'] = _parseArbFile(enData);

    // Load Arabic strings
    String arData = await rootBundle.loadString('assets/l10n/intl_ar.arb');
    _localizedValues['ar'] = _parseArbFile(arData);

    // Load German strings
    String deData = await rootBundle.loadString('assets/l10n/intl_de.arb');
    _localizedValues['de'] = _parseArbFile(deData);

    // Load Spanish strings
    String esData = await rootBundle.loadString('assets/l10n/intl_es.arb');
    _localizedValues['es'] = _parseArbFile(esData);

    // Load French strings
    String frData = await rootBundle.loadString('assets/l10n/intl_fr.arb');
    _localizedValues['fr'] = _parseArbFile(frData);

    // Load Hindi strings
    String hiData = await rootBundle.loadString('assets/l10n/intl_hi.arb');
    _localizedValues['hi'] = _parseArbFile(hiData);

    // Load Italian strings
    String itData = await rootBundle.loadString('assets/l10n/intl_it.arb');
    _localizedValues['it'] = _parseArbFile(itData);

    // Load Japanese strings
    String jaData = await rootBundle.loadString('assets/l10n/intl_ja.arb');
    _localizedValues['ja'] = _parseArbFile(jaData);

    // Load Korean strings
    String koData = await rootBundle.loadString('assets/l10n/intl_ko.arb');
    _localizedValues['ko'] = _parseArbFile(koData);

    // Load Portuguese strings
    String ptData = await rootBundle.loadString('assets/l10n/intl_pt.arb');
    _localizedValues['pt'] = _parseArbFile(ptData);

    // Load Russian strings
    String ruData = await rootBundle.loadString('assets/l10n/intl_ru.arb');
    _localizedValues['ru'] = _parseArbFile(ruData);

    // Load Chinese strings
    String zhData = await rootBundle.loadString('assets/l10n/intl_zh.arb');
    _localizedValues['zh'] = _parseArbFile(zhData);

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

  String get yourLocation =>
      _localizedValues[locale.languageCode]!['yourLocation'] ?? 'Your Location';
  String get couldNotLoadPlaces =>
      _localizedValues[locale.languageCode]!['couldNotLoadPlaces'] ??
      'Could not load places';

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
  String get name => _localizedValues[locale.languageCode]!['name'] ?? 'Name';
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
      _localizedValues[locale.languageCode]!['placeDescription'] ??
      'Place Description';
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
  // Profile Screen Getters
  String get profile =>
      _localizedValues[locale.languageCode]?['profile'] ?? 'Profile';
  String get changeProfilePicture =>
      _localizedValues[locale.languageCode]?['changeProfilePicture'] ??
      'Change Profile Picture';
  String get profileInformation =>
      _localizedValues[locale.languageCode]?['profileInformation'] ??
      'Profile Information';
  // String get name => _localizedValues[locale.languageCode]?['name'] ?? 'Name';
  // String get username => _localizedValues[locale.languageCode]?['username'] ?? 'Username';
  String get personalInformation =>
      _localizedValues[locale.languageCode]?['personalInformation'] ??
      'Personal Information';
  String get userId =>
      _localizedValues[locale.languageCode]?['userId'] ?? 'User ID';
  // String get email => _localizedValues[locale.languageCode]?['email'] ?? 'E-mail';
  String get phoneNumber =>
      _localizedValues[locale.languageCode]?['phoneNumber'] ?? 'Phone Number';
  // String get gender => _localizedValues[locale.languageCode]?['gender'] ?? 'Gender';
  String get dateOfBirth =>
      _localizedValues[locale.languageCode]?['dateOfBirth'] ?? 'Date of Birth';
  String get closeAccount =>
      _localizedValues[locale.languageCode]?['closeAccount'] ?? 'Close Account';
  String get copied =>
      _localizedValues[locale.languageCode]?['copied'] ?? 'Copied';
  String get userIdCopied =>
      _localizedValues[locale.languageCode]?['userIdCopied'] ??
      'User ID copied to clipboard';
  String get notSet =>
      _localizedValues[locale.languageCode]?['notSet'] ?? 'Not set';
  String get male => _localizedValues[locale.languageCode]?['male'] ?? 'Male';
  String get female =>
      _localizedValues[locale.languageCode]?['female'] ?? 'Female';
  String get other =>
      _localizedValues[locale.languageCode]?['other'] ?? 'Other';

  // Settings Screen Getters
  String get account =>
      _localizedValues[locale.languageCode]?['account'] ?? 'Account';
  String get accountSettings =>
      _localizedValues[locale.languageCode]?['accountSettings'] ??
      'Account Settings';
  String get appSettings =>
      _localizedValues[locale.languageCode]?['appSettings'] ?? 'App Settings';
  String get darkMode =>
      _localizedValues[locale.languageCode]?['darkMode'] ?? 'Dark Mode';
  String get lightMode =>
      _localizedValues[locale.languageCode]?['lightMode'] ?? 'Light Mode';
  String get switchTheme =>
      _localizedValues[locale.languageCode]?['switchTheme'] ??
      'Switch dark or light mode';
  // String get logout => _localizedValues[locale.languageCode]?['logout'] ?? 'Logout';

  // Account Settings Getters
  String get myAddresses =>
      _localizedValues[locale.languageCode]?['myAddresses'] ?? 'My Addresses';
  String get setDeliveryAddress =>
      _localizedValues[locale.languageCode]?['setDeliveryAddress'] ??
      'Set shopping delivery address';
  String get bankAccount =>
      _localizedValues[locale.languageCode]?['bankAccount'] ?? 'Bank Account';
  String get withdrawBalance =>
      _localizedValues[locale.languageCode]?['withdrawBalance'] ??
      'Withdraw balance to registered bank account';
  String get myCoupons =>
      _localizedValues[locale.languageCode]?['myCoupons'] ?? 'My Coupons';
  String get discountedCoupons =>
      _localizedValues[locale.languageCode]?['discountedCoupons'] ??
      'List of all the discounted coupons';
  String get notifications =>
      _localizedValues[locale.languageCode]?['notifications'] ??
      'Notifications';
  String get setNotifications =>
      _localizedValues[locale.languageCode]?['setNotifications'] ??
      'Set any kind of notification message';
  String get accountPrivacy =>
      _localizedValues[locale.languageCode]?['accountPrivacy'] ??
      'Account Privacy';
  String get manageDataUsage =>
      _localizedValues[locale.languageCode]?['manageDataUsage'] ??
      'Manage data usage and connected accounts';

  // App Settings Getters
  String get loadData =>
      _localizedValues[locale.languageCode]?['loadData'] ?? 'Load Data';
  String get uploadDataToCloud =>
      _localizedValues[locale.languageCode]?['uploadDataToCloud'] ??
      'Upload Data to your Cloud Firebase';
  String get geolocation =>
      _localizedValues[locale.languageCode]?['geolocation'] ?? 'Geolocation';
  String get recommendationBasedOnLocation =>
      _localizedValues[locale.languageCode]?['recommendationBasedOnLocation'] ??
      'Set recommendation based on location';
  String get safeMode =>
      _localizedValues[locale.languageCode]?['safeMode'] ?? 'Safe Mode';
  String get safeForAllAges =>
      _localizedValues[locale.languageCode]?['safeForAllAges'] ??
      'Search result is safe for all ages';
  String get hdImageQuality =>
      _localizedValues[locale.languageCode]?['hdImageQuality'] ??
      'HD Image Quality';
  String get setImageQuality =>
      _localizedValues[locale.languageCode]?['setImageQuality'] ??
      'Set image quality to be seen';

  // User Profile Editing Getters
  String get reAuthenticate =>
      _localizedValues[locale.languageCode]?['reAuthenticate'] ??
      'Re-Authenticate User';
  String get verify =>
      _localizedValues[locale.languageCode]?['verify'] ?? 'Verify';
  String get changeUsername =>
      _localizedValues[locale.languageCode]?['changeUsername'] ??
      'Change Username';
  String get chooseUniqueUsername =>
      _localizedValues[locale.languageCode]?['chooseUniqueUsername'] ??
      'Choose a unique username that represents you.';
  String get usernameHint =>
      _localizedValues[locale.languageCode]?['usernameHint'] ??
      'e.g., john_doe123';
  String get changePhoneNumber =>
      _localizedValues[locale.languageCode]?['changePhoneNumber'] ??
      'Change Phone Number';
  String get addPhoneForVerification =>
      _localizedValues[locale.languageCode]?['addPhoneForVerification'] ??
      'Add your phone number for verification and contact purposes.';
  String get phoneNumberHint =>
      _localizedValues[locale.languageCode]?['phoneNumberHint'] ??
      'e.g., +967 234 567 8900';
  String get changeName =>
      _localizedValues[locale.languageCode]?['changeName'] ?? 'Change Name';
  String get useRealNameForVerification =>
      _localizedValues[locale.languageCode]?['useRealNameForVerification'] ??
      'Use real name for easy verification. This name will appear on several pages.';
  String get selectGender =>
      _localizedValues[locale.languageCode]?['selectGender'] ?? 'Select Gender';
  String get selectBirthDate =>
      _localizedValues[locale.languageCode]?['selectBirthDate'] ??
      'Select Birth Date';
  String get selected =>
      _localizedValues[locale.languageCode]?['selected'] ?? 'Selected';
  String get noDateSelected =>
      _localizedValues[locale.languageCode]?['noDateSelected'] ??
      'No date selected';
  String get clearSelection =>
      _localizedValues[locale.languageCode]?['clearSelection'] ??
      'Clear Selection';
  String get save => _localizedValues[locale.languageCode]?['save'] ?? 'Save';

  // Address Screen Getters
  String get addNewAddress =>
      _localizedValues[locale.languageCode]?['addNewAddress'] ??
      'Add New Address';
  String get pickLocationFromMap =>
      _localizedValues[locale.languageCode]?['pickLocationFromMap'] ??
      'Pick Location from Map';
  String get addressName =>
      _localizedValues[locale.languageCode]?['addressName'] ?? 'Address Name';
  String get addressNameHint =>
      _localizedValues[locale.languageCode]?['addressNameHint'] ??
      'Home, Work, Office, etc.';
  String get street =>
      _localizedValues[locale.languageCode]?['street'] ?? 'Street';
  String get postalCode =>
      _localizedValues[locale.languageCode]?['postalCode'] ?? 'Postal Code';
  String get city => _localizedValues[locale.languageCode]?['city'] ?? 'City';
  String get state =>
      _localizedValues[locale.languageCode]?['state'] ?? 'State';
  String get country =>
      _localizedValues[locale.languageCode]?['country'] ?? 'Country';
  String get saveAddress =>
      _localizedValues[locale.languageCode]?['saveAddress'] ?? 'Save Address';
  String get locationFromMap =>
      _localizedValues[locale.languageCode]?['locationFromMap'] ??
      'Location from Map';
  String get clearMapLocation =>
      _localizedValues[locale.languageCode]?['clearMapLocation'] ??
      'Clear map location';
  String get coordinates =>
      _localizedValues[locale.languageCode]?['coordinates'] ?? 'Coordinates';
  String get addressFromMap =>
      _localizedValues[locale.languageCode]?['addressFromMap'] ??
      'Address from map';
  String get mapLocation =>
      _localizedValues[locale.languageCode]?['mapLocation'] ?? 'Map Location';

  // Forgot Password & Authentication Getters
  // String get forgetPasswordTitle => _localizedValues[locale.languageCode]?['forgetPasswordTitle'] ?? 'Forget password';
  // String get forgetPasswordSubTitle => _localizedValues[locale.languageCode]?['forgetPasswordSubTitle'] ?? 'Don\'t worry sometimes people can forget too, enter your email and we will send you a password reset link.';
  String get passwordResetEmailSent =>
      _localizedValues[locale.languageCode]?['passwordResetEmailSent'] ??
      'Password Reset Email Sent';
  String get accountSecurityPriority =>
      _localizedValues[locale.languageCode]?['accountSecurityPriority'] ??
      'Your Account Security is Our Priority! We\'ve Sent You a Secure Link to Safely Change Your Password and Keep Your Account Protected.';
  String get verifyEmailAddress =>
      _localizedValues[locale.languageCode]?['verifyEmailAddress'] ??
      'Verify your email address!';
  String get congratulationsAccountAwaits =>
      _localizedValues[locale.languageCode]?['congratulationsAccountAwaits'] ??
      'Congratulations! Your Account Awaits: Verify Your Email to Start Shopping and Experience a World of Unrivaled Deals and Personalized Offers.';
  String get emailNotReceived =>
      _localizedValues[locale.languageCode]?['emailNotReceived'] ??
      'Didn\'t get the email? Check your junk/spam or resend it.';
  String get accountCreatedSuccess =>
      _localizedValues[locale.languageCode]?['accountCreatedSuccess'] ??
      'Your account successfully created!';
  String get welcomeToDestination =>
      _localizedValues[locale.languageCode]?['welcomeToDestination'] ??
      'Welcome to Your Ultimate Shopping Destination: Your Account is Created, Unleash the Joy of Seamless Online Shopping!';

  // Authentication Success Getters
  String get changeYourPasswordTitle =>
      _localizedValues[locale.languageCode]?['changeYourPasswordTitle'] ??
      'Password Reset Email Sent';
  String get changeYourPasswordSubTitle =>
      _localizedValues[locale.languageCode]?['changeYourPasswordSubTitle'] ??
      'Your Account Security is Our Priority! We\'ve Sent You a Secure Link to Safely Change Your Password and Keep Your Account Protected.';
  String get confirmEmail =>
      _localizedValues[locale.languageCode]?['confirmEmail'] ??
      'Verify your email address!';
  String get confirmEmailSubTitle =>
      _localizedValues[locale.languageCode]?['confirmEmailSubTitle'] ??
      'Congratulations! Your Account Awaits: Verify Your Email to Start Shopping and Experience a World of Unrivaled Deals and Personalized Offers.';
  String get emailNotReceivedMessage =>
      _localizedValues[locale.languageCode]?['emailNotReceivedMessage'] ??
      'Didn\'t get the email? Check your junk/spam or resend it.';
  String get yourAccountCreatedTitle =>
      _localizedValues[locale.languageCode]?['yourAccountCreatedTitle'] ??
      'Your account successfully created!';
  String get yourAccountCreatedSubTitle =>
      _localizedValues[locale.languageCode]?['yourAccountCreatedSubTitle'] ??
      'Welcome to Your Ultimate Shopping Destination: Your Account is Created, Unleash the Joy of Seamless Online Shopping!';
  String get and => _localizedValues[locale.languageCode]?['and'] ?? 'And';
  // Add these to your existing AppLocalizations class
  String get removeQuestion =>
      _localizedValues[locale.languageCode]!['removeQuestion'] ??
      'Remove Question';
  String get loading =>
      _localizedValues[locale.languageCode]!['loading'] ?? 'Loading...';

  // Rating & Reviews Section
  // String get ratingReviews => _localizedValues[locale.languageCode]!['ratingReviews'] ?? 'Rating & Reviews';
  // String get ratingsVerified => _localizedValues[locale.languageCode]!['ratingsVerified'] ?? 'Ratings and reviews are verified and are from people who use the same type of device that you use.';
  String get loadingReviews =>
      _localizedValues[locale.languageCode]!['loadingReviews'] ??
      'Loading reviews...';
  String get errorLoadingReviews =>
      _localizedValues[locale.languageCode]!['errorLoadingReviews'] ??
      'Error loading reviews';

  // Plural-aware reviews count
  String reviewsCount(int count) {
    final key = 'reviewsCount';
    final pluralKey = count == 1 ? key : '${key}_other';

    final template =
        _localizedValues[locale.languageCode]![pluralKey] ??
        _localizedValues[locale.languageCode]![key] ??
        '{count} reviews';

    return template.replaceAll('{count}', count.toString());
  }

  // Business Card
  String get listYourBusiness =>
      _localizedValues[locale.languageCode]!['listYourBusiness'] ??
      'List Your Business';
  String get getDiscoveredByMillions =>
      _localizedValues[locale.languageCode]!['getDiscoveredByMillions'] ??
      'Get discovered by millions of customers and grow your business';
  String get getStarted =>
      _localizedValues[locale.languageCode]!['getStarted'] ?? 'Get Started';

  // Categories
  String get popularCategories =>
      _localizedValues[locale.languageCode]!['popularCategories'] ??
      'Popular Categories';
  String get noCategoriesFound =>
      _localizedValues[locale.languageCode]!['noCategoriesFound'] ??
      'No categories found';

  // QR Scanner
  String get scanQRCode =>
      _localizedValues[locale.languageCode]!['scanQRCode'] ?? 'Scan QR Code';
  String get alignQRCode =>
      _localizedValues[locale.languageCode]!['alignQRCode'] ??
      'Align QR code within the frame';
  String get processingQRCode =>
      _localizedValues[locale.languageCode]!['processingQRCode'] ??
      'Processing QR Code...';
  String get lookingUpPlace =>
      _localizedValues[locale.languageCode]!['lookingUpPlace'] ??
      '🔍 Looking Up Place...';
  String get checkingDatabase =>
      _localizedValues[locale.languageCode]!['checkingDatabase'] ??
      'Checking our database...';
  String get success =>
      _localizedValues[locale.languageCode]!['success'] ?? '✅ Success!';
  String get scanError =>
      _localizedValues[locale.languageCode]!['scanError'] ?? 'Scan Error';
  String get tryAgain =>
      _localizedValues[locale.languageCode]!['tryAgain'] ?? 'Try Again';
  String get invalidQRCode =>
      _localizedValues[locale.languageCode]!['invalidQRCode'] ??
      'Invalid QR Code';
  String get unrecognizedFormat =>
      _localizedValues[locale.languageCode]!['unrecognizedFormat'] ??
      'Unrecognized format.';
  String get viewDetails =>
      _localizedValues[locale.languageCode]!['viewDetails'] ?? 'View Details';
  String get noTrendingPlacesFound =>
      _localizedValues[locale.languageCode]!['noTrendingPlacesFound'] ??
      'No trending places found.';

  // Method for dynamic text with placeholders
  String redirectingTo(String placeName) {
    final template =
        _localizedValues[locale.languageCode]!['redirectingTo'] ??
        'Redirecting to {placeName}';
    return template.replaceAll('{placeName}', placeName);
  }

  // Error and loading states
  String get retry =>
      _localizedValues[locale.languageCode]!['retry'] ?? 'Retry';
  String get beFirstToReview =>
      _localizedValues[locale.languageCode]!['beFirstToReview'] ??
      'Be the first to write a review!';
  String get unknownError =>
      _localizedValues[locale.languageCode]!['unknownError'] ??
      'Unknown error occurred';

  String get ohSnap =>
      _localizedValues[locale.languageCode]!['ohSnap'] ?? 'Oh Snap!';
  String get somethingWentWrong =>
      _localizedValues[locale.languageCode]!['somethingWentWrong'] ??
      'Something went wrong. Please try again.';
  String get error =>
      _localizedValues[locale.languageCode]!['error'] ?? 'Error';
  String get warning =>
      _localizedValues[locale.languageCode]!['warning'] ?? 'Warning';
  // Error and Loading States
  String get errorLoading =>
      _localizedValues[locale.languageCode]!['errorLoading'] ?? 'Error Loading';
  String get categoryNotFound =>
      _localizedValues[locale.languageCode]!['categoryNotFound'] ??
      'Category Not Found';
  String get noDataFound =>
      _localizedValues[locale.languageCode]!['noDataFound'] ?? 'No Data Found';
  String get tapToRetry =>
      _localizedValues[locale.languageCode]!['tapToRetry'] ?? 'Tap to retry';
  // ReadMore Text variations
  String get showMore =>
      _localizedValues[locale.languageCode]!['showMore'] ?? 'Show more';
  String get showLess =>
      _localizedValues[locale.languageCode]!['showLess'] ?? 'Show less';
  String get readMore =>
      _localizedValues[locale.languageCode]!['readMore'] ?? 'Read more';
  String get readLess =>
      _localizedValues[locale.languageCode]!['readLess'] ?? 'Read less';
  String get viewMore =>
      _localizedValues[locale.languageCode]!['viewMore'] ?? 'View more';
  String get viewLess =>
      _localizedValues[locale.languageCode]!['viewLess'] ?? 'View less';

  // Places saved with proper pluralization
  String placesSaved(int count) {
    if (locale.languageCode == 'ar') {
      // Arabic pluralization
      final key = count == 1 ? 'placeSaved' : 'placesSaved';
      final template =
          _localizedValues[locale.languageCode]![key] ??
          (count == 1 ? 'تم حفظ {count} مكان' : 'تم حفظ {count} أماكن');
      return template.replaceAll('{count}', count.toString());
    } else {
      // English pluralization
      final key = count == 1 ? 'placeSaved' : 'placesSaved';
      final template =
          _localizedValues[locale.languageCode]![key] ??
          (count == 1 ? '{count} place saved' : '{count} places saved');
      return template.replaceAll('{count}', count.toString());
    }
  }

  // Search Screen
  String get voiceSearch =>
      _localizedValues[locale.languageCode]!['voiceSearch'] ?? 'Voice Search';
  String get listening =>
      _localizedValues[locale.languageCode]!['listening'] ?? 'Listening...';
  String get viewAllCategories =>
      _localizedValues[locale.languageCode]!['viewAllCategories'] ??
      'View All Categories';
  String get categories =>
      _localizedValues[locale.languageCode]!['categories'] ?? 'Categories';
  String get filterPlaces =>
      _localizedValues[locale.languageCode]!['filterPlaces'] ?? 'Filter Places';
  String get sortBy =>
      _localizedValues[locale.languageCode]!['sortBy'] ?? 'Sort by';
  String get minimumRating =>
      _localizedValues[locale.languageCode]!['minimumRating'] ??
      'Minimum Rating';
  String get starsAndAbove =>
      _localizedValues[locale.languageCode]!['starsAndAbove'] ??
      'stars and above';
  String get featuredPlacesOnly =>
      _localizedValues[locale.languageCode]!['featuredPlacesOnly'] ??
      'Featured Places Only';
  String get applyFilters =>
      _localizedValues[locale.languageCode]!['applyFilters'] ?? 'Apply Filters';
  String get left => _localizedValues[locale.languageCode]!['left'] ?? 'left';
  String get noCategoriesAvailable =>
      _localizedValues[locale.languageCode]!['noCategoriesAvailable'] ??
      'No categories available';

  // Sorting Options
  String get relevance =>
      _localizedValues[locale.languageCode]!['relevance'] ?? 'Relevance';
  String get highestRated =>
      _localizedValues[locale.languageCode]!['highestRated'] ?? 'Highest Rated';
  String get mostReviewed =>
      _localizedValues[locale.languageCode]!['mostReviewed'] ?? 'Most Reviewed';
  String get mostLiked =>
      _localizedValues[locale.languageCode]!['mostLiked'] ?? 'Most Liked';
  String get newest =>
      _localizedValues[locale.languageCode]!['newest'] ?? 'Newest';
  String get nameAZ =>
      _localizedValues[locale.languageCode]!['nameAZ'] ?? 'Name (A-Z)';
  String get nameZA =>
      _localizedValues[locale.languageCode]!['nameZA'] ?? 'Name (Z-A)';
  String get foundPlacesIn =>
      _localizedValues[locale.languageCode]!['foundPlacesIn'] ??
      'Found {count} places in';
  String get foundPlacesFor =>
      _localizedValues[locale.languageCode]!['foundPlacesFor'] ??
      'Found {count} places for';
  // Add these to your existing AppLocalizations class

  // Review Form Texts
  String get yes => _localizedValues[locale.languageCode]!['yes'] ?? 'Yes';
  String get no => _localizedValues[locale.languageCode]!['no'] ?? 'No';
  String get typeYourAnswer =>
      _localizedValues[locale.languageCode]!['typeYourAnswer'] ??
      'Type your answer...';
  // String get removeQuestion =>
  //     _localizedValues[locale.languageCode]!['removeQuestion'] ??
  //     'Remove Question';
  // String get deleteReview =>
  //     _localizedValues[locale.languageCode]!['deleteReview'] ?? 'Delete Review';
  // String get deleteReviewConfirmation =>
  //     _localizedValues[locale.languageCode]!['deleteReviewConfirmation'] ??
  //     'Are you sure you want to delete your review? This action cannot be undone.';
  // String get editReview =>
  //     _localizedValues[locale.languageCode]!['editReview'] ?? 'Edit Review';
  // String get updateReview =>
  //     _localizedValues[locale.languageCode]!['updateReview'] ?? 'Update Review';
  String get submitReview =>
      _localizedValues[locale.languageCode]!['submitReview'] ?? 'Submit Review';
  String get validationReviewTextRequired =>
      _localizedValues[locale.languageCode]!['validationReviewTextRequired'] ??
      'Review text is required.';

  // Add to your existing AppLocalizations class

  // Contact & Phone Options
  String get contactOptions =>
      _localizedValues[locale.languageCode]!['contactOptions'] ??
      'Contact Options';
  String get chooseHowToContact =>
      _localizedValues[locale.languageCode]!['chooseHowToContact'] ??
      'Choose how to contact';
  String get call => _localizedValues[locale.languageCode]!['call'] ?? 'Call';
  String get whatsApp =>
      _localizedValues[locale.languageCode]!['whatsApp'] ?? 'WhatsApp';
  String get message =>
      _localizedValues[locale.languageCode]!['message'] ?? 'Message';
  String get noMessagingApp =>
      _localizedValues[locale.languageCode]!['noMessagingApp'] ??
      'No Messaging App';
  String get couldNotFindMessagingApp =>
      _localizedValues[locale.languageCode]!['couldNotFindMessagingApp'] ??
      'We couldn\'t find a messaging app on your device. Choose an option below:';
  String get installMessagingApp =>
      _localizedValues[locale.languageCode]!['installMessagingApp'] ??
      'Install Messaging App';
  String get getMessagingAppFromPlayStore =>
      _localizedValues[locale.languageCode]!['getMessagingAppFromPlayStore'] ??
      'Get a messaging app from Play Store';
  String get useWhatsApp =>
      _localizedValues[locale.languageCode]!['useWhatsApp'] ?? 'Use WhatsApp';
  String get sendMessageViaWhatsApp =>
      _localizedValues[locale.languageCode]!['sendMessageViaWhatsApp'] ??
      'Send message via WhatsApp';
  String get copyNumber =>
      _localizedValues[locale.languageCode]!['copyNumber'] ?? 'Copy Number';
  String get copyPhoneNumberToClipboard =>
      _localizedValues[locale.languageCode]!['copyPhoneNumberToClipboard'] ??
      'Copy phone number to clipboard';
  String get cannotOpenStore =>
      _localizedValues[locale.languageCode]!['cannotOpenStore'] ??
      'Cannot Open Store';
  String get installMessagingAppManually =>
      _localizedValues[locale.languageCode]!['installMessagingAppManually'] ??
      'Please install a messaging app manually from Play Store';
  String get storeError =>
      _localizedValues[locale.languageCode]!['storeError'] ?? 'Store Error';
  String get failedToOpenAppStore =>
      _localizedValues[locale.languageCode]!['failedToOpenAppStore'] ??
      'Failed to open app store';
  String get copyFailed =>
      _localizedValues[locale.languageCode]!['copyFailed'] ?? 'Copy Failed';
  String get couldNotCopyPhoneNumber =>
      _localizedValues[locale.languageCode]!['couldNotCopyPhoneNumber'] ??
      'Could not copy phone number';
  String get whatsAppNotInstalled =>
      _localizedValues[locale.languageCode]!['whatsAppNotInstalled'] ??
      'WhatsApp is not installed';
  String get failedToOpenWhatsApp =>
      _localizedValues[locale.languageCode]!['failedToOpenWhatsApp'] ??
      'Failed to open WhatsApp';
  String get failedToMakeCall =>
      _localizedValues[locale.languageCode]!['failedToMakeCall'] ??
      'Failed to make call';
  String get failedToLaunchPhoneOptions =>
      _localizedValues[locale.languageCode]!['failedToLaunchPhoneOptions'] ??
      'Failed to launch phone options';
  String get couldNotMakeCall =>
      _localizedValues[locale.languageCode]!['couldNotMakeCall'] ??
      'Could not make call to';
  String get messageFailed =>
      _localizedValues[locale.languageCode]!['messageFailed'] ??
      'Message Failed';
  String get couldNotOpenMessagingApp =>
      _localizedValues[locale.languageCode]!['couldNotOpenMessagingApp'] ??
      'Could not open messaging app';
  String get cannotOpenLink =>
      _localizedValues[locale.languageCode]!['cannotOpenLink'] ??
      'Cannot Open Link';
  String get couldNotLaunchWebsite =>
      _localizedValues[locale.languageCode]!['couldNotLaunchWebsite'] ??
      'Could not launch the website';

  // Date Formatting
  String get today =>
      _localizedValues[locale.languageCode]!['today'] ?? 'Today';
  String get yesterday =>
      _localizedValues[locale.languageCode]!['yesterday'] ?? 'Yesterday';
  String get daysAgo =>
      _localizedValues[locale.languageCode]!['daysAgo'] ?? 'days ago';
  String get weeksAgo =>
      _localizedValues[locale.languageCode]!['weeksAgo'] ?? 'weeks ago';
  String get weekAgo =>
      _localizedValues[locale.languageCode]!['weekAgo'] ?? 'week ago';
  String get unknownDate =>
      _localizedValues[locale.languageCode]!['unknownDate'] ?? 'Unknown date';

  // Plural-aware date formatting method
  String formatRelativeDate(DateTime? date) {
    if (date == null) return unknownDate;

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return today;
    } else if (difference.inDays == 1) {
      return yesterday;
    } else if (difference.inDays < 7) {
      return '${difference.inDays} $daysAgo';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      final weekText = weeks == 1 ? weekAgo : weeksAgo;
      return '$weeks $weekText';
    } else {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      return '$day/$month/$year';
    }
  }

  // Add to your existing AppLocalizations class

  // Subscription Screen Texts
  String get placesReviewsPremium =>
      _localizedValues[locale.languageCode]!['placesReviewsPremium'] ??
      'Places Reviews Premium';
  String get unlimitedPlaceReviews =>
      _localizedValues[locale.languageCode]!['unlimitedPlaceReviews'] ??
      'Unlimited place reviews & ratings';
  String get advancedSearchFiltering =>
      _localizedValues[locale.languageCode]!['advancedSearchFiltering'] ??
      'Advanced search & filtering';
  String get priorityCustomerSupport =>
      _localizedValues[locale.languageCode]!['priorityCustomerSupport'] ??
      'Priority customer support';
  String get exclusiveInsiderRecommendations =>
      _localizedValues[locale
          .languageCode]!['exclusiveInsiderRecommendations'] ??
      'Exclusive insider recommendations';
  String get adFreeExperience =>
      _localizedValues[locale.languageCode]!['adFreeExperience'] ??
      'Ad-free experience';
  String get earlyAccessNewFeatures =>
      _localizedValues[locale.languageCode]!['earlyAccessNewFeatures'] ??
      'Early access to new features';
  String get choose =>
      _localizedValues[locale.languageCode]!['choose'] ?? 'Choose';
  String get freeTrialFooter =>
      _localizedValues[locale.languageCode]!['freeTrialFooter'] ??
      '✨ 7-day free trial • Cancel anytime • No hidden fees';
  String get bySubscribingAgree =>
      _localizedValues[locale.languageCode]!['bySubscribingAgree'] ??
      'By subscribing, you agree to our';
  String get termsOfService =>
      _localizedValues[locale.languageCode]!['termsOfService'] ??
      'Terms of Service';
  String get needHelp =>
      _localizedValues[locale.languageCode]!['needHelp'] ?? 'Need Help?';
  String get premiumSubscriptionHelp =>
      _localizedValues[locale.languageCode]!['premiumSubscriptionHelp'] ??
      'Our premium subscription gives you unlimited access to all features. You can cancel anytime during your free trial without being charged.';
  String get gotIt =>
      _localizedValues[locale.languageCode]!['gotIt'] ?? 'Got it';

  String get subscriptionDetails =>
      _localizedValues[locale.languageCode]!['subscriptionDetails'] ??
      'Subscription Details';
  String get youHaveActivePremium =>
      _localizedValues[locale.languageCode]!['youHaveActivePremium'] ??
      'You have an active Premium subscription.';
  String get withPremiumYouCan =>
      _localizedValues[locale.languageCode]!['withPremiumYouCan'] ??
      'With Premium you can:';
  String get createUnlimitedPlaces =>
      _localizedValues[locale.languageCode]!['createUnlimitedPlaces'] ??
      'Create unlimited places';
  String get accessAdvancedFeatures =>
      _localizedValues[locale.languageCode]!['accessAdvancedFeatures'] ??
      'Access advanced features';
  String get getPrioritySupport =>
      _localizedValues[locale.languageCode]!['getPrioritySupport'] ??
      'Get priority support';
  String get close =>
      _localizedValues[locale.languageCode]!['close'] ?? 'Close';

  // Comments & Reviews
  String get hide => _localizedValues[locale.languageCode]!['hide'] ?? 'Hide';
  String get show => _localizedValues[locale.languageCode]!['show'] ?? 'Show';
  String get reply =>
      _localizedValues[locale.languageCode]!['reply'] ?? 'reply';
  String get replies =>
      _localizedValues[locale.languageCode]!['replies'] ?? 'replies';
  String get edit => _localizedValues[locale.languageCode]!['edit'] ?? 'Edit';
  String get delete =>
      _localizedValues[locale.languageCode]!['delete'] ?? 'Delete';
  String get editComment =>
      _localizedValues[locale.languageCode]!['editComment'] ?? 'Edit Comment';
  String get editYourComment =>
      _localizedValues[locale.languageCode]!['editYourComment'] ??
      'Edit your comment...';
  String get deleteComment =>
      _localizedValues[locale.languageCode]!['deleteComment'] ??
      'Delete Comment';
  String get deleteCommentConfirmation =>
      _localizedValues[locale.languageCode]!['deleteCommentConfirmation'] ??
      'Are you sure you want to delete this comment?';
  String get replyToComment =>
      _localizedValues[locale.languageCode]!['replyToComment'] ??
      'Reply to comment';
  String get writeYourReply =>
      _localizedValues[locale.languageCode]!['writeYourReply'] ??
      'Write your reply...';
  String get typeYourReply =>
      _localizedValues[locale.languageCode]!['typeYourReply'] ??
      'Type your reply...';
  String get addNewComment =>
      _localizedValues[locale.languageCode]!['addNewComment'] ??
      'Add a new comment...';
  String get replyingTo =>
      _localizedValues[locale.languageCode]!['replyingTo'] ?? 'Replying to';
  String get justNow =>
      _localizedValues[locale.languageCode]!['justNow'] ?? 'Just now';
  String get minutesAgo =>
      _localizedValues[locale.languageCode]!['minutesAgo'] ?? 'm ago';
  String get hoursAgo =>
      _localizedValues[locale.languageCode]!['hoursAgo'] ?? 'h ago';
  String get monthsAgo =>
      _localizedValues[locale.languageCode]!['monthsAgo'] ?? 'mo ago';

  String get shareFailed =>
      _localizedValues[locale.languageCode]!['shareFailed'] ?? 'Share Failed';
  String get saveFailed =>
      _localizedValues[locale.languageCode]!['saveFailed'] ?? 'Save Failed';
  String get permissionRequired =>
      _localizedValues[locale.languageCode]!['permissionRequired'] ??
      'Permission Required';
  String get storagePermissionRequired =>
      _localizedValues[locale.languageCode]!['storagePermissionRequired'] ??
      'Storage permission is required to save PDF files. Please enable it in app settings.';
  String get openSettings =>
      _localizedValues[locale.languageCode]!['openSettings'] ?? 'Open Settings';
  String get fileExists =>
      _localizedValues[locale.languageCode]!['fileExists'] ?? 'File Exists';
  String get fileExistsMessage =>
      _localizedValues[locale.languageCode]!['fileExistsMessage'] ??
      'A PDF with this name already exists. Would you like to overwrite it?';
  String get overwrite =>
      _localizedValues[locale.languageCode]!['overwrite'] ?? 'Overwrite';
  String get fileOverwritten =>
      _localizedValues[locale.languageCode]!['fileOverwritten'] ??
      'File overwritten successfully';

  // Gallery
  String get gallery =>
      _localizedValues[locale.languageCode]!['gallery'] ?? 'Gallery';
  String get searchPhotos =>
      _localizedValues[locale.languageCode]!['searchPhotos'] ?? 'Search photos';
  String get recentPlaces =>
      _localizedValues[locale.languageCode]!['recentPlaces'] ?? 'Recent Places';
  String get collections =>
      _localizedValues[locale.languageCode]!['collections'] ?? 'Collections';
  String get allPlacePhotos =>
      _localizedValues[locale.languageCode]!['allPlacePhotos'] ??
      'All Place Photos';
  String get photos =>
      _localizedValues[locale.languageCode]!['photos'] ?? 'photos';
  String get collectionPhotos =>
      _localizedValues[locale.languageCode]!['collectionPhotos'] ??
      'Collection Photos';
  String get noPhotosFound =>
      _localizedValues[locale.languageCode]!['noPhotosFound'] ??
      'No photos found in this collection.';
  String get uncategorized =>
      _localizedValues[locale.languageCode]!['uncategorized'] ??
      'Uncategorized';

  // Reviews & Questions
  String get additionalAnswers =>
      _localizedValues[locale.languageCode]!['additionalAnswers'] ??
      'Additional Answers:';
  String get notAnswered =>
      _localizedValues[locale.languageCode]!['notAnswered'] ?? 'Not answered';
  String get stars =>
      _localizedValues[locale.languageCode]!['stars'] ?? 'stars';
  String get star => _localizedValues[locale.languageCode]!['star'] ?? 'star';

  // Map & Location
  String get chooseLocation =>
      _localizedValues[locale.languageCode]!['chooseLocation'] ??
      'Choose Location';
  String get searchForAddress =>
      _localizedValues[locale.languageCode]!['searchForAddress'] ??
      'Search for an address...';
  String get searchForPlaces =>
      _localizedValues[locale.languageCode]!['searchForPlaces'] ??
      'Search for places, addresses...';
  String get currentLocation =>
      _localizedValues[locale.languageCode]!['currentLocation'] ??
      'Current Location';
  String get nearbyPlaces =>
      _localizedValues[locale.languageCode]!['nearbyPlaces'] ?? 'Nearby Places';
  String get searchResultsFor =>
      _localizedValues[locale.languageCode]!['searchResultsFor'] ??
      'Search results for';
  String get loadingPlaces =>
      _localizedValues[locale.languageCode]!['loadingPlaces'] ??
      'Loading Places...';
  String get findingBestPlaces =>
      _localizedValues[locale.languageCode]!['findingBestPlaces'] ??
      'Finding the best places around you';
  String get filterByCategory =>
      _localizedValues[locale.languageCode]!['filterByCategory'] ??
      'Filter by Category';
  String get clear =>
      _localizedValues[locale.languageCode]!['clear'] ?? 'Clear';
  String get placesDisplayed =>
      _localizedValues[locale.languageCode]!['placesDisplayed'] ??
      'places displayed';
  String get noPlaces =>
      _localizedValues[locale.languageCode]!['noPlaces'] ?? 'No Places';
  String noPlacesFoundInCategory(String categoryName) {
    final template =
        _localizedValues[locale.languageCode]!['noPlacesFoundInCategory'] ??
        'No places found in {categoryName} category';
    return template.replaceAll('{categoryName}', categoryName);
  }

  String get selectedLocation =>
      _localizedValues[locale.languageCode]!['selectedLocation'] ??
      'Selected Location';
  String get tapToSelectLocation =>
      _localizedValues[locale.languageCode]!['tapToSelectLocation'] ??
      'Tap on the map to select a location';
  String get locationAddress =>
      _localizedValues[locale.languageCode]!['locationAddress'] ??
      'Location Address';
  String get confirmLocation =>
      _localizedValues[locale.languageCode]!['confirmLocation'] ??
      'Confirm Location';
  String get mapType =>
      _localizedValues[locale.languageCode]!['mapType'] ?? 'Map Type';
  String get defaultMap =>
      _localizedValues[locale.languageCode]!['default'] ?? 'Default';
  String get satellite =>
      _localizedValues[locale.languageCode]!['satellite'] ?? 'Satellite';
  String get terrain =>
      _localizedValues[locale.languageCode]!['terrain'] ?? 'Terrain';
  String get hybrid =>
      _localizedValues[locale.languageCode]!['hybrid'] ?? 'Hybrid';
  String get loadingMap =>
      _localizedValues[locale.languageCode]!['loadingMap'] ?? 'Loading Map...';
  String get loadingYourLocation =>
      _localizedValues[locale.languageCode]!['loadingYourLocation'] ??
      'Loading your location...';
  String get settingUpYourMap =>
      _localizedValues[locale.languageCode]!['settingUpYourMap'] ??
      'Please wait while we set up your map';

  String get stopListening =>
      _localizedValues[locale.languageCode]!['stopListening'] ??
      'Stop Listening';

  //---------new-------
  String get chooseLanguage =>
      _localizedValues[locale.languageCode]!['chooseLanguage']!;
  String get selectPreferredLanguage =>
      _localizedValues[locale.languageCode]!['selectPreferredLanguage']!;
  String get english => _localizedValues[locale.languageCode]!['english']!;
  String get arabic => _localizedValues[locale.languageCode]!['arabic']!;
  String get authenticationRequired =>
      _localizedValues[locale.languageCode]!['authenticationRequired']!;
  String get pleaseSignIn =>
      _localizedValues[locale.languageCode]!['pleaseSignIn']!;
  String get updateSuccess =>
      _localizedValues[locale.languageCode]!['updateSuccess']!;
  String get updateFailed =>
      _localizedValues[locale.languageCode]!['updateFailed']!;
  String get nameUpdated =>
      _localizedValues[locale.languageCode]!['nameUpdated']!;
  String get phoneUpdated =>
      _localizedValues[locale.languageCode]!['phoneUpdated']!;
  String get usernameUpdated =>
      _localizedValues[locale.languageCode]!['usernameUpdated']!;
  String get genderUpdated =>
      _localizedValues[locale.languageCode]!['genderUpdated']!;
  String get birthDateUpdated =>
      _localizedValues[locale.languageCode]!['birthDateUpdated']!;
  String get addressSelected =>
      _localizedValues[locale.languageCode]!['addressSelected']!;
  String get addressSaved =>
      _localizedValues[locale.languageCode]!['addressSaved']!;
  String get locationSelected =>
      _localizedValues[locale.languageCode]!['locationSelected']!;
  String get placeCreated =>
      _localizedValues[locale.languageCode]!['placeCreated']!;
  String get placeUpdated =>
      _localizedValues[locale.languageCode]!['placeUpdated']!;
  String get placeDeleted =>
      _localizedValues[locale.languageCode]!['placeDeleted']!;
  String get reviewSubmitted =>
      _localizedValues[locale.languageCode]!['reviewSubmitted']!;
  String get reviewUpdated =>
      _localizedValues[locale.languageCode]!['reviewUpdated']!;
  String get reviewDeleted =>
      _localizedValues[locale.languageCode]!['reviewDeleted']!;
  String get favoriteAdded =>
      _localizedValues[locale.languageCode]!['favoriteAdded']!;
  String get favoriteRemoved =>
      _localizedValues[locale.languageCode]!['favoriteRemoved']!;
  String get noInternet =>
      _localizedValues[locale.languageCode]!['noInternet']!;
  String get weAreUpdatingYourInformation =>
      _localizedValues[locale.languageCode]!['weAreUpdatingYourInformation']!;
  String get yourNameHasBeenUpdated =>
      _localizedValues[locale.languageCode]!['yourNameHasBeenUpdated']!;
  String get weAreUpdatingYourPhoneNumber =>
      _localizedValues[locale.languageCode]!['weAreUpdatingYourPhoneNumber']!;
  String get yourPhoneNumberHasBeenUpdated =>
      _localizedValues[locale.languageCode]!['yourPhoneNumberHasBeenUpdated']!;
  String get weAreUpdatingYourUsername =>
      _localizedValues[locale.languageCode]!['weAreUpdatingYourUsername']!;
  String get yourUsernameHasBeenUpdated =>
      _localizedValues[locale.languageCode]!['yourUsernameHasBeenUpdated']!;
  String get weAreUpdatingYourGender =>
      _localizedValues[locale.languageCode]!['weAreUpdatingYourGender']!;
  String get yourGenderHasBeenUpdated =>
      _localizedValues[locale.languageCode]!['yourGenderHasBeenUpdated']!;
  String get weAreUpdatingYourBirthDate =>
      _localizedValues[locale.languageCode]!['weAreUpdatingYourBirthDate']!;
  String get yourBirthDateHasBeenUpdated =>
      _localizedValues[locale.languageCode]!['yourBirthDateHasBeenUpdated']!;
  String get pleaseSelectYourBirthDate =>
      _localizedValues[locale.languageCode]!['pleaseSelectYourBirthDate']!;
  String get addressNotFound =>
      _localizedValues[locale.languageCode]!['addressNotFound']!;
  String get storingAddress =>
      _localizedValues[locale.languageCode]!['storingAddress']!;
  String get yourAddressHasBeenSaved =>
      _localizedValues[locale.languageCode]!['yourAddressHasBeenSaved']!;
  String get mapLocationSelected =>
      _localizedValues[locale.languageCode]!['mapLocationSelected']!;
  String get failedToLoadFavorites =>
      _localizedValues[locale.languageCode]!['failedToLoadFavorites']!;
  String get placeHasBeenAddedToWishlist =>
      _localizedValues[locale.languageCode]!['placeHasBeenAddedToWishlist']!;
  String get placeHasBeenRemovedFromWishlist =>
      _localizedValues[locale
          .languageCode]!['placeHasBeenRemovedFromWishlist']!;
  String get creatingNewPlace =>
      _localizedValues[locale.languageCode]!['creatingNewPlace']!;
  String get uploadingPhotos =>
      _localizedValues[locale.languageCode]!['uploadingPhotos']!;
  String get yourNewPlaceHasBeenCreated =>
      _localizedValues[locale.languageCode]!['yourNewPlaceHasBeenCreated']!;
  String get updatingPlace =>
      _localizedValues[locale.languageCode]!['updatingPlace']!;
  String get placeHasBeenUpdated =>
      _localizedValues[locale.languageCode]!['placeHasBeenUpdated']!;
  String get deletingPlace =>
      _localizedValues[locale.languageCode]!['deletingPlace']!;
  String get placeHasBeenDeleted =>
      _localizedValues[locale.languageCode]!['placeHasBeenDeleted']!;
  String get locationMissing =>
      _localizedValues[locale.languageCode]!['locationMissing']!;
  String get pleaseUseMapPicker =>
      _localizedValues[locale.languageCode]!['pleaseUseMapPicker']!;
  String get noImages => _localizedValues[locale.languageCode]!['noImages']!;
  String get pleaseSelectAtLeastOneImage =>
      _localizedValues[locale.languageCode]!['pleaseSelectAtLeastOneImage']!;
  String get categoryMissing =>
      _localizedValues[locale.languageCode]!['categoryMissing']!;
  String get pleaseSelectValidCategory =>
      _localizedValues[locale.languageCode]!['pleaseSelectValidCategory']!;
  String get limitReached =>
      _localizedValues[locale.languageCode]!['limitReached']!;
  String get youCanOnlyAddUpTo4Questions =>
      _localizedValues[locale.languageCode]!['youCanOnlyAddUpTo4Questions']!;
  String get creatingNewCategory =>
      _localizedValues[locale.languageCode]!['creatingNewCategory']!;
  String get categoryNameRequired =>
      _localizedValues[locale.languageCode]!['categoryNameRequired']!;
  String get pleaseEnterCategoryName =>
      _localizedValues[locale.languageCode]!['pleaseEnterCategoryName']!;
  String get duplicateCategory =>
      _localizedValues[locale.languageCode]!['duplicateCategory']!;
  String get categoryAlreadyExists =>
      _localizedValues[locale.languageCode]!['categoryAlreadyExists']!;
  String get categoryCreated =>
      _localizedValues[locale.languageCode]!['categoryCreated']!;
  String get dataNotSaved =>
      _localizedValues[locale.languageCode]!['dataNotSaved']!;
  String get couldNotSaveInformation =>
      _localizedValues[locale.languageCode]!['couldNotSaveInformation']!;
  String get deleteAccount =>
      _localizedValues[locale.languageCode]!['deleteAccount']!;
  String get deleteAccountConfirmation =>
      _localizedValues[locale.languageCode]!['deleteAccountConfirmation']!;
  String get processing =>
      _localizedValues[locale.languageCode]!['processing']!;
  String get accountDeleted =>
      _localizedValues[locale.languageCode]!['accountDeleted']!;
  String get permissionDenied =>
      _localizedValues[locale.languageCode]!['permissionDenied']!;
  String get pleaseAllowAccessToPhotos =>
      _localizedValues[locale.languageCode]!['pleaseAllowAccessToPhotos']!;
  String get profileImageUpdated =>
      _localizedValues[locale.languageCode]!['profileImageUpdated']!;
  String get requiresLogin =>
      _localizedValues[locale.languageCode]!['requiresLogin']!;
  String get pleaseLogInToUseFeature =>
      _localizedValues[locale.languageCode]!['pleaseLogInToUseFeature']!;

  // Method for parameterized strings
  String failedToLoadFavoritesWithError(String error) {
    return _localizedValues[locale.languageCode]!['failedToLoadFavorites']!
        .replaceAll('{error}', error);
  }

  String uploadingPhotosWithParams(int count, String placeId) {
    return _localizedValues[locale.languageCode]!['uploadingPhotos']!
        .replaceAll('{count}', count.toString())
        .replaceAll('{placeId}', placeId);
  }

  String yourNewPlaceHasBeenCreatedWithTitle(String title) {
    return _localizedValues[locale.languageCode]!['yourNewPlaceHasBeenCreated']!
        .replaceAll('{title}', title);
  }

  String placeHasBeenUpdatedWithTitle(String title) {
    return _localizedValues[locale.languageCode]!['placeHasBeenUpdated']!
        .replaceAll('{title}', title);
  }

  String placeHasBeenDeletedWithTitle(String title) {
    return _localizedValues[locale.languageCode]!['placeHasBeenDeleted']!
        .replaceAll('{title}', title);
  }

  String categoryCreatedWithName(String name) {
    return _localizedValues[locale.languageCode]!['categoryCreated']!
        .replaceAll('{name}', name);
  }

  String get imageDeleted =>
      _localizedValues[locale.languageCode]!['imageDeleted']!;

  String get imageDeletedFromStorage =>
      _localizedValues[locale.languageCode]!['imageDeletedFromStorage'] ??
      'Image successfully deleted from your cloud storage';

  String get deletePlace =>
      _localizedValues[locale.languageCode]!['deletePlace'] ?? 'Delete Place?';

  String deletePlaceMessage(String placeTitle) {
    final template =
        _localizedValues[locale.languageCode]!['deletePlaceMessage'] ??
        'Are you sure you want to delete "{placeTitle}"? This action cannot be undone.';
    return template.replaceAll('{placeTitle}', placeTitle);
  }

  // Add these to AppLocalizations class
  String get imageDeletedMessage =>
      _localizedValues[locale.languageCode]!['imageDeletedMessage'] ??
      'Image URL removed from list.';
  String get signInRequired =>
      _localizedValues[locale.languageCode]!['signInRequired'] ??
      'Sign In Required';
  String get signInRequiredMessage =>
      _localizedValues[locale.languageCode]!['signInRequiredMessage'] ??
      'Please sign in to like this place.';
  String get failedToToggleLike =>
      _localizedValues[locale.languageCode]!['failedToToggleLike'] ??
      'Failed to Toggle Like';

  String get streamError =>
      _localizedValues[locale.languageCode]!['streamError'] ?? 'Stream Error';
  String get uploadFailed =>
      _localizedValues[locale.languageCode]!['uploadFailed'] ??
      'Upload Failed!';

  String couldNotUploadPlaceImages(String error) {
    final template =
        _localizedValues[locale.languageCode]!['couldNotUploadPlaceImages'] ??
        'Could not upload place images: {error}';
    return template.replaceAll('{error}', error);
  }

  String get imageLimitReached =>
      _localizedValues[locale.languageCode]!['imageLimitReached'] ??
      'Image Limit Reached';

  String imageLimitMessage(int maxImages) {
    final template =
        _localizedValues[locale.languageCode]!['imageLimitMessage'] ??
        'You can only upload a maximum of {maxImages} images.';
    return template.replaceAll('{maxImages}', maxImages.toString());
  }

  String get imageSelectionFailed =>
      _localizedValues[locale.languageCode]!['imageSelectionFailed'] ??
      'Image Selection Failed';

  String couldNotSelectImages(String error) {
    final template =
        _localizedValues[locale.languageCode]!['couldNotSelectImages'] ??
        'Could not select images: {error}';
    return template.replaceAll('{error}', error);
  }

  String uploadingPhotosWithCount(int count, String placeId) {
    final template =
        _localizedValues[locale.languageCode]!['uploadingPhotos'] ??
        'Uploading {count} photos for Place ID: {placeId}...';
    return template
        .replaceAll('{count}', count.toString())
        .replaceAll('{placeId}', placeId);
  }

  String get pleaseSelectLocation =>
      _localizedValues[locale.languageCode]!['pleaseSelectLocation'] ??
      'Please select a location for the place.';

  String get deleteFailed =>
      _localizedValues[locale.languageCode]!['deleteFailed'] ?? 'Delete Failed';

  String get formValidationFailed =>
      _localizedValues[locale.languageCode]!['formValidationFailed'] ??
      'Form validation failed';

  String get noImagesSelected =>
      _localizedValues[locale.languageCode]!['noImagesSelected'] ?? 'No Images';

  String get pleaseSignInToSavePlaces =>
      _localizedValues[locale.languageCode]!['pleaseSignInToSavePlaces'] ??
      'Please sign in or create an account to save your favorite places.';

  // LoginController strings
  String get loggingYouIn =>
      _localizedValues[locale.languageCode]!['loggingYouIn'] ??
      'Logging you in...';

  String get enteringAsGuest =>
      _localizedValues[locale.languageCode]!['enteringAsGuest'] ??
      'Entering as guest...';

  String couldNotSkipLogin(String error) {
    final template =
        _localizedValues[locale.languageCode]!['couldNotSkipLogin'] ??
        'Could not skip login. Please check your connection or try again: {error}';
    return template.replaceAll('{error}', error);
  }

  // ForgetPasswordController strings
  String get processingYourRequest =>
      _localizedValues[locale.languageCode]!['processingYourRequest'] ??
      'Processing your request...';

  String get emailSent =>
      _localizedValues[locale.languageCode]!['emailSent'] ?? 'Email Sent';

  String get emailLinkSentResetPassword =>
      _localizedValues[locale.languageCode]!['emailLinkSentResetPassword'] ??
      'Email Link Sent to Reset your Password';

  // SignupController strings
  String get weAreProcessingYourInformation =>
      _localizedValues[locale
          .languageCode]!['weAreProcessingYourInformation'] ??
      'We are processing your information...';

  String get acceptPrivacyPolicy =>
      _localizedValues[locale.languageCode]!['acceptPrivacyPolicy'] ??
      'Accept Privacy Policy';

  String get privacyPolicyMessage =>
      _localizedValues[locale.languageCode]!['privacyPolicyMessage'] ??
      'In order to create account, you must have to read and accept the Privacy Policy & Terms of Use.';

  String get congratulations =>
      _localizedValues[locale.languageCode]!['congratulations'] ??
      'Congratulations';

  String get accountCreatedVerifyEmail =>
      _localizedValues[locale.languageCode]!['accountCreatedVerifyEmail'] ??
      'Your account has been created! Verify email to continue.';

  // VerifyEmailController strings
  String get pleaseCheckInboxVerifyEmail =>
      _localizedValues[locale.languageCode]!['pleaseCheckInboxVerifyEmail'] ??
      'Please Check your inbox and verify your email.';

  String get yourAccountCreated =>
      _localizedValues[locale.languageCode]!['yourAccountCreated'] ??
      'Your account has been created';

  // ReviewController strings
  String get submittingReview =>
      _localizedValues[locale.languageCode]!['submittingReview'] ??
      'Submitting Review...';

  String get pleaseSignInToAddReview =>
      _localizedValues[locale.languageCode]!['pleaseSignInToAddReview'] ??
      'Please sign in or create an account to add your review.';

  String get ratingRequired =>
      _localizedValues[locale.languageCode]!['ratingRequired'] ??
      'Rating Required';

  String get pleaseSelectStarRating =>
      _localizedValues[locale.languageCode]!['pleaseSelectStarRating'] ??
      'Please select a star rating for your experience.';

  String get submissionSuccess =>
      _localizedValues[locale.languageCode]!['submissionSuccess'] ??
      'Submission Success!';

  String get reviewUpdatedSuccess =>
      _localizedValues[locale.languageCode]!['reviewUpdatedSuccess'] ??
      'Your review has been successfully updated.';

  String get reviewSubmittedSuccess =>
      _localizedValues[locale.languageCode]!['reviewSubmittedSuccess'] ??
      'Your review has been submitted.';

  String get submissionFailed =>
      _localizedValues[locale.languageCode]!['submissionFailed'] ??
      'Submission Failed';

  String get reviewRequired =>
      _localizedValues[locale.languageCode]!['reviewRequired'] ??
      'Review Required';

  String get pleaseWriteReviewText =>
      _localizedValues[locale.languageCode]!['pleaseWriteReviewText'] ??
      'Please write your review text.';

  String get answerRequired =>
      _localizedValues[locale.languageCode]!['answerRequired'] ??
      'Answer Required';

  String pleaseAnswerRequiredQuestion(String question) {
    final template =
        _localizedValues[locale
            .languageCode]!['pleaseAnswerRequiredQuestion'] ??
        'Please answer the required question: {question}';
    return template.replaceAll('{question}', question);
  }

  String get deletingReview =>
      _localizedValues[locale.languageCode]!['deletingReview'] ??
      'Deleting Review...';

  String get reviewDeletedSuccess =>
      _localizedValues[locale.languageCode]!['reviewDeletedSuccess'] ??
      'Review deleted successfully.';

  // SearchController strings
  String get microphonePermissionRequired =>
      _localizedValues[locale.languageCode]!['microphonePermissionRequired'] ??
      'Microphone Permission Required';

  String get pleaseEnableMicrophone =>
      _localizedValues[locale.languageCode]!['pleaseEnableMicrophone'] ??
      'Please enable microphone permission to use voice search.';

  String get voiceSearchUnavailable =>
      _localizedValues[locale.languageCode]!['voiceSearchUnavailable'] ??
      'Voice Search Unavailable';

  String get speechRecognitionNotAvailable =>
      _localizedValues[locale.languageCode]!['speechRecognitionNotAvailable'] ??
      'Speech recognition is not available on this device.';

  String get speechError =>
      _localizedValues[locale.languageCode]!['speechError'] ?? 'Speech Error';

  String get couldNotStartVoiceRecognition =>
      _localizedValues[locale.languageCode]!['couldNotStartVoiceRecognition'] ??
      'Could not start voice recognition. Please try again.';

  String get searchError =>
      _localizedValues[locale.languageCode]!['searchError'] ?? 'Search Error';

  String get creatingNewPlacesPremium =>
      _localizedValues[locale.languageCode]!['creatingNewPlacesPremium'] ??
      'Creating new places is a premium feature.';

  String get upgradeToPremiumToUnlock =>
      _localizedValues[locale.languageCode]!['upgradeToPremiumToUnlock'] ??
      'Upgrade to Premium to unlock:';

  String get unlimitedPlaceCreation =>
      _localizedValues[locale.languageCode]!['unlimitedPlaceCreation'] ??
      'Unlimited place creation';

  String get advancedReviewFeatures =>
      _localizedValues[locale.languageCode]!['advancedReviewFeatures'] ??
      'Advanced review features';

  String get prioritySupport =>
      _localizedValues[locale.languageCode]!['prioritySupport'] ??
      'Priority support';

  String get maybeLater =>
      _localizedValues[locale.languageCode]!['maybeLater'] ?? 'Maybe Later';

  String get upgradeNow =>
      _localizedValues[locale.languageCode]!['upgradeNow'] ?? 'Upgrade Now';
  String get placeNotFound =>
      _localizedValues[locale.languageCode]!['placeNotFound'] ??
      'Place Not Found';

  // General strings
  String failedToLoadRecentFeaturedImages(String error) {
    final template =
        _localizedValues[locale
            .languageCode]!['failedToLoadRecentFeaturedImages'] ??
        'Failed to load recent featured images: {error}';
    return template.replaceAll('{error}', error);
  }

  String get featuredPlaces =>
      _localizedValues[locale.languageCode]!['featuredPlaces'] ??
      'Featured Places';

  String get unknownCategory =>
      _localizedValues[locale.languageCode]!['unknownCategory'] ??
      'Unknown Category';
  String get commentAddedSuccessfully =>
      _localizedValues[locale.languageCode]!['commentAddedSuccessfully'] ??
      'Comment added successfully';
  String get failedToAddComment =>
      _localizedValues[locale.languageCode]!['failedToAddComment'] ??
      'Failed To Add Comment';
  // Add these getters to AppLocalizations class:

  // Comment update success
  String get commentUpdatedSuccess =>
      _localizedValues[locale.languageCode]!['commentUpdatedSuccess'] ??
      'Comment updated successfully';

  // Comment delete success
  String get commentDeletedSuccess =>
      _localizedValues[locale.languageCode]!['commentDeletedSuccess'] ??
      'Comment deleted successfully';

  // Comment update error
  String get commentUpdateError =>
      _localizedValues[locale.languageCode]!['commentUpdateError'] ??
      'Oh Snap!';

  String failedToUpdateComment(String error) {
    final template =
        _localizedValues[locale.languageCode]!['failedToUpdateComment'] ??
        'Failed to update comment: {error}';
    return template.replaceAll('{error}', error);
  }

  // Comment delete error
  String get commentDeleteError =>
      _localizedValues[locale.languageCode]!['commentDeleteError'] ??
      'Oh Snap!';

  String failedToDeleteComment(String error) {
    final template =
        _localizedValues[locale.languageCode]!['failedToDeleteComment'] ??
        'Failed to delete comment: {error}';
    return template.replaceAll('{error}', error);
  }

  // Comment react error
  String get commentReactError =>
      _localizedValues[locale.languageCode]!['commentReactError'] ?? 'Oh Snap!';

  String failedToReact(String error) {
    final template =
        _localizedValues[locale.languageCode]!['failedToReact'] ??
        'Failed to react to comment: {error}';
    return template.replaceAll('{error}', error);
  }

  String get youMustBeLoggedIn =>
      _localizedValues[locale.languageCode]!['youMustBeLoggedIn'] ??
      'You must be logged in to react';

  String failedToReactToReply(String error) {
    final template =
        _localizedValues[locale.languageCode]!['failedToReactToReply'] ??
        'Failed to react to reply: {error}';
    return template.replaceAll('{error}', error);
  }

  // Map Controller Texts
  String get loadingError =>
      _localizedValues[locale.languageCode]!['loadingError'] ?? 'Loading Error';

  String get filterError =>
      _localizedValues[locale.languageCode]!['filterError'] ?? 'Filter Error';

  String get couldNotFilterPlaces =>
      _localizedValues[locale.languageCode]!['couldNotFilterPlaces'] ??
      'Could not filter places by category';

  String get noPlacesFoundForCategory =>
      _localizedValues[locale.languageCode]!['noPlacesFoundForCategory'] ??
      'No places found for the selected category';

  String get locationRequired =>
      _localizedValues[locale.languageCode]!['locationRequired'] ??
      'Location Required';

  String get pleaseWaitForLocation =>
      _localizedValues[locale.languageCode]!['pleaseWaitForLocation'] ??
      'Please wait for your location to load';

  String get errorLoadingNearbyPlaces =>
      _localizedValues[locale.languageCode]!['errorLoadingNearbyPlaces'] ??
      'Could not load nearby places';

  String foundPlacesNearby(int count) {
    final template =
        _localizedValues[locale.languageCode]!['foundPlacesNearby'] ??
        'Found {count} places nearby';
    return template.replaceAll('{count}', count.toString());
  }

  String noPlacesFoundWithinDistance(double distance) {
    final template =
        _localizedValues[locale.languageCode]!['noPlacesFoundWithinDistance'] ??
        'No places found within {distance}km';
    return template.replaceAll('{distance}', distance.toStringAsFixed(1));
  }

  String get errorLoadingLocationDetails =>
      _localizedValues[locale.languageCode]!['errorLoadingLocationDetails'] ??
      'Could not load location details';

  String get gettingLocation =>
      _localizedValues[locale.languageCode]!['gettingLocation'] ??
      'Getting location...';

  String get locationNameNotFound =>
      _localizedValues[locale.languageCode]!['locationNameNotFound'] ??
      'Location name not found';

  String get unknownLocation =>
      _localizedValues[locale.languageCode]!['unknownLocation'] ??
      'Unknown Location';

  String get searchResult =>
      _localizedValues[locale.languageCode]!['searchResult'] ?? 'Search Result';

  String get locationFromSearch =>
      _localizedValues[locale.languageCode]!['locationFromSearch'] ??
      'Location from search';

  String get googlePlacesLocation =>
      _localizedValues[locale.languageCode]!['googlePlacesLocation'] ??
      'Google Places location';

  String get googlePlaces =>
      _localizedValues[locale.languageCode]!['googlePlaces'] ?? 'Google Places';

  String get searchSystem =>
      _localizedValues[locale.languageCode]!['searchSystem'] ?? 'Search System';

  String get appInitializationError =>
      _localizedValues[locale.languageCode]!['appInitializationError'] ??
      'App initialization error';

  String get speechInitializationError =>
      _localizedValues[locale.languageCode]!['speechInitializationError'] ??
      'Speech initialization error';

  String get enhancedSearchError =>
      _localizedValues[locale.languageCode]!['enhancedSearchError'] ??
      'Enhanced search error';

  String get suggestionSelectionError =>
      _localizedValues[locale.languageCode]!['suggestionSelectionError'] ??
      'Suggestion selection error';

  String get initialLocationFetchError =>
      _localizedValues[locale.languageCode]!['initialLocationFetchError'] ??
      'Initial Location Fetch Error';

  String get liveLocationStreamError =>
      _localizedValues[locale.languageCode]!['liveLocationStreamError'] ??
      'Live Location Stream Error';

  String get reverseGeocodingError =>
      _localizedValues[locale.languageCode]!['reverseGeocodingError'] ??
      'Reverse Geocoding Error';

  String get googlePlacesSearchError =>
      _localizedValues[locale.languageCode]!['googlePlacesSearchError'] ??
      'Google Places search error';

  String get nearbyPlacesError =>
      _localizedValues[locale.languageCode]!['nearbyPlacesError'] ??
      'Error loading nearby places';

  // Image Viewer Texts
  String get imageViewer =>
      _localizedValues[locale.languageCode]!['imageViewer'] ?? 'Image Viewer';
  String get downloadImage =>
      _localizedValues[locale.languageCode]!['downloadImage'] ??
      'Download Image';
  String get imageDownloaded =>
      _localizedValues[locale.languageCode]!['imageDownloaded'] ??
      'Image downloaded successfully';
  String get failedToDownload =>
      _localizedValues[locale.languageCode]!['failedToDownload'] ??
      'Failed to download image';
  String get shareImage =>
      _localizedValues[locale.languageCode]!['shareImage'] ?? 'Share Image';
  String get saveToGallery =>
      _localizedValues[locale.languageCode]!['saveToGallery'] ??
      'Save to Gallery';
  String get zoomed =>
      _localizedValues[locale.languageCode]!['zoomed'] ?? 'Zoomed';
  String get imageShared =>
      _localizedValues[locale.languageCode]!['imageShared'] ??
      'Image shared successfully';
  String get failedToShare =>
      _localizedValues[locale.languageCode]!['failedToShare'] ??
      'Failed to share image';
  String get allowPermission =>
      _localizedValues[locale.languageCode]!['allowPermission'] ??
      'Allow Permission';
  String get doubleTapToZoom =>
      _localizedValues[locale.languageCode]!['doubleTapToZoom'] ??
      'Double tap to zoom';
  String get pinchToZoom =>
      _localizedValues[locale.languageCode]!['pinchToZoom'] ?? 'Pinch to zoom';
  String get tapToClose =>
      _localizedValues[locale.languageCode]!['tapToClose'] ?? 'Tap to close';
  String get viewOriginal =>
      _localizedValues[locale.languageCode]!['viewOriginal'] ?? 'View Original';

  String get failedToLoadImage =>
      _localizedValues[locale.languageCode]!['failedToLoadImage'] ??
      'Failed to load image';

  String get swipeLeftOrRightToViewImages =>
      _localizedValues[locale.languageCode]!['swipeLeftOrRightToViewImages'] ??
      'Swipe left or right to view other images';

  String get youSelected =>
      _localizedValues[locale.languageCode]!['youSelected'] ?? 'You Selected';

  String get allLanguages =>
      _localizedValues[locale.languageCode]!['allLanguages'] ?? 'All Languages';

  String get search =>
      _localizedValues[locale.languageCode]!['search'] ?? 'Search';

  // Directions and Map Features
  String get directions =>
      _localizedValues[locale.languageCode]!['directions'] ?? 'Directions';

  String get directionsFound =>
      _localizedValues[locale.languageCode]!['directionsFound'] ??
      'Directions Found';

  String routeReady(String placeName) =>
      (_localizedValues[locale.languageCode]!['routeReady'] ??
              'Route to {placeName} is ready')
          .replaceAll('{placeName}', placeName);

  String get noRouteFound =>
      _localizedValues[locale.languageCode]!['noRouteFound'] ??
      'No Route Found';

  String get couldNotFindRoute =>
      _localizedValues[locale.languageCode]!['couldNotFindRoute'] ??
      'Could not find a route to this location';

  String get couldNotFetchDirections =>
      _localizedValues[locale.languageCode]!['couldNotFetchDirections'] ??
      'Could not fetch directions';

  // Distance and Map Features
  String get away => _localizedValues[locale.languageCode]!['away'] ?? 'away';

  String get meters => _localizedValues[locale.languageCode]!['meters'] ?? 'm';

  String get kilometers =>
      _localizedValues[locale.languageCode]!['kilometers'] ?? 'km';

  String get distance =>
      _localizedValues[locale.languageCode]!['distance'] ?? 'Distance';

  // Search Filters
  String get searchFilters =>
      _localizedValues[locale.languageCode]!['searchFilters'] ??
      'Search Filters';

  String get searchInThisArea =>
      _localizedValues[locale.languageCode]!['searchInThisArea'] ??
      'Search in this area';

  String get redoSearchInArea =>
      _localizedValues[locale.languageCode]!['redoSearchInArea'] ??
      'Redo search in this area';

  String get distanceRadius =>
      _localizedValues[locale.languageCode]!['distanceRadius'] ??
      'Distance Radius';

  String get selectArea =>
      _localizedValues[locale.languageCode]!['selectArea'] ?? 'Select Area';

  String get selectCity =>
      _localizedValues[locale.languageCode]!['selectCity'] ?? 'Select City';

  String get selectCountry =>
      _localizedValues[locale.languageCode]!['selectCountry'] ??
      'Select Country';

  String get filterByArea =>
      _localizedValues[locale.languageCode]!['filterByArea'] ??
      'Filter by Area';

  String get clearFilters =>
      _localizedValues[locale.languageCode]!['clearFilters'] ?? 'Clear Filters';

  String get activeFilters =>
      _localizedValues[locale.languageCode]!['activeFilters'] ??
      'Active Filters';

  String get noFiltersActive =>
      _localizedValues[locale.languageCode]!['noFiltersActive'] ??
      'No filters active';

  String get resultsFound =>
      _localizedValues[locale.languageCode]!['resultsFound'] ??
      '{count} results found';

  // Distance Ranges
  String get within1km =>
      _localizedValues[locale.languageCode]!['within1km'] ?? 'Within 1 km';

  String get within5km =>
      _localizedValues[locale.languageCode]!['within5km'] ?? 'Within 5 km';

  String get within10km =>
      _localizedValues[locale.languageCode]!['within10km'] ?? 'Within 10 km';

  String get within25km =>
      _localizedValues[locale.languageCode]!['within25km'] ?? 'Within 25 km';

  String get within50km =>
      _localizedValues[locale.languageCode]!['within50km'] ?? 'Within 50 km';

  String get customRadius =>
      _localizedValues[locale.languageCode]!['customRadius'] ?? 'Custom Radius';

  String get anyDistance =>
      _localizedValues[locale.languageCode]!['anyDistance'] ?? 'Any Distance';

  // Area Selection
  String get allAreas =>
      _localizedValues[locale.languageCode]!['allAreas'] ?? 'All Areas';

  String get popularAreas =>
      _localizedValues[locale.languageCode]!['popularAreas'] ?? 'Popular Areas';

  String get recentAreas =>
      _localizedValues[locale.languageCode]!['recentAreas'] ?? 'Recent Areas';

  String get searchCity =>
      _localizedValues[locale.languageCode]!['searchCity'] ?? 'Search city...';

  // Quick Filters
  String get quickFilters =>
      _localizedValues[locale.languageCode]!['quickFilters'] ?? 'Quick Filters';

  String get nearbyOnly =>
      _localizedValues[locale.languageCode]!['nearbyOnly'] ?? 'Nearby Only';

  String get mostPopular =>
      _localizedValues[locale.languageCode]!['mostPopular'] ?? 'Most Popular';

  String get recentlyAdded =>
      _localizedValues[locale.languageCode]!['recentlyAdded'] ??
      'Recently Added';

  // Map Controls and Premium Features
  String get mapControls =>
      _localizedValues[locale.languageCode]!['mapControls'] ?? 'Map Controls';

  String get searchHistory =>
      _localizedValues[locale.languageCode]!['searchHistory'] ??
      'Search History';

  String get savedLocations =>
      _localizedValues[locale.languageCode]!['savedLocations'] ??
      'Saved Locations';

  String get clusterView =>
      _localizedValues[locale.languageCode]!['clusterView'] ?? 'Cluster View';

  String get listView =>
      _localizedValues[locale.languageCode]!['listView'] ?? 'List View';

  String get exploreThisArea =>
      _localizedValues[locale.languageCode]!['exploreThisArea'] ??
      'Explore This Area';

  String get showingResults =>
      _localizedValues[locale.languageCode]!['showingResults'] ??
      'Showing {count} results';

  String get filterPresets =>
      _localizedValues[locale.languageCode]!['filterPresets'] ??
      'Filter Presets';

  String get cityWide =>
      _localizedValues[locale.languageCode]!['cityWide'] ?? 'City-wide';

  String get searchRadius =>
      _localizedValues[locale.languageCode]!['searchRadius'] ?? 'Search Radius';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return [
      'en',
      'ar',
      'de',
      'es',
      'fr',
      'hi',
      'it',
      'ja',
      'ko',
      'pt',
      'ru',
      'zh',
    ].contains(locale.languageCode);
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
