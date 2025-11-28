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
  String get name => _localizedValues[locale.languageCode]!['Name'] ?? 'Name';
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
  String get errorLoading => _localizedValues[locale.languageCode]!['errorLoading'] ?? 'Error Loading';
  String get categoryNotFound => _localizedValues[locale.languageCode]!['categoryNotFound'] ?? 'Category Not Found';
    String get noDataFound => _localizedValues[locale.languageCode]!['noDataFound'] ?? 'No Data Found';
  String get tapToRetry => _localizedValues[locale.languageCode]!['tapToRetry'] ?? 'Tap to retry';
    // ReadMore Text variations
  String get showMore => _localizedValues[locale.languageCode]!['showMore'] ?? 'Show more';
  String get showLess => _localizedValues[locale.languageCode]!['showLess'] ?? 'Show less';
  String get readMore => _localizedValues[locale.languageCode]!['readMore'] ?? 'Read more';
  String get readLess => _localizedValues[locale.languageCode]!['readLess'] ?? 'Read less';
  String get viewMore => _localizedValues[locale.languageCode]!['viewMore'] ?? 'View more';
  String get viewLess => _localizedValues[locale.languageCode]!['viewLess'] ?? 'View less';
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
