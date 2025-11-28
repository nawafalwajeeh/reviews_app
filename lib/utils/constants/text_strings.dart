/// This class contains all the App Text in String formats.
final class AppTexts {
  // -- GLOBAL Texts
  static const String and = "and";
  static const String skip = "Skip";
  static const String done = "Done";
  static const String submit = "Submit";
  static const String appName = "Places";
  static const String tContinue = "Continue";
  static const String logout = 'Logout';
  static const String searchInStore = 'Search in Store';

  // -- Store Paths
  static const String categoriesStoragePath = '/Categories';
  static const String placesStoragePath = '/Places';
  static const String usersStoragePath = '/Users';

  // -- OnBoarding Texts
  static const String onBoardingTitle1 = "Discover Local Gems";
  static const String onBoardingTitle2 = "Share Your Honest Reviews";
  static const String onBoardingTitle3 = "Build a Trusted Community";

  static const String onBoardingSubTitle1 =
      "Explore a world of unique places, from cozy cafes to exciting new restaurants, all around you.";
  static const String onBoardingSubTitle2 =
      "Your insights help others make informed choices. Share your thoughts and photos with the community!";
  static const String onBoardingSubTitle3 =
      "Join fellow explorers, find recommendations from people you trust, and help local businesses thrive.";

  // -- Authentication Forms
  static const String firstName = "First Name";
  static const String lastName = "Last Name";
  static const String email = "E-Mail";
  static const String password = "Password";
  static const String newPassword = "New Password";
  static const String username = "Username";
  static const String gender = 'Gender';
  static const String birthDate = 'Birth Date';
  static const String phoneNo = "Phone Number";
  static const String rememberMe = "Remember Me";
  static const String forgetPassword = "Forget Password?";
  static const String signIn = "Sign In";
  static const String createAccount = "Create Account";
  static const String orSignInWith = "or sign in with";
  static const String orSignUpWith = "or sign up with";
  static const String iAgreeTo = "I agree to";
  static const String privacyPolicy = "Privacy Policy";
  static const String termsOfUse = "Terms of use";
  static const String verificationCode = "verificationCode";
  static const String resendEmail = "Resend Email";
  static const String resendEmailIn = "Resend email in";

  // -- Authentication Headings
  static const String loginTitle = "Welcome back,";
  // static const String loginSubTitle =
  //     "Discover Limitless Choices and Unmatched Convenience.";
  static const String loginSubTitle =
      "Login to continue reviewing your favorite places.";
  static const String signupTitle = "Let’s create your account";
  static const String forgetPasswordTitle = "Forget password";
  static const String forgetPasswordSubTitle =
      "Don’t worry sometimes people can forget too, enter your email and we will send you a password reset link.";
  static const String changeYourPasswordTitle = "Password Reset Email Sent";
  static const String changeYourPasswordSubTitle =
      "Your Account Security is Our Priority! We've Sent You a Secure Link to Safely Change Your Password and Keep Your Account Protected.";
  static const String confirmEmail = "Verify your email address!";
  static const String confirmEmailSubTitle =
      "Congratulations! Your Account Awaits: Verify Your Email to Start Shopping and Experience a World of Unrivaled Deals and Personalized Offers.";
  static const String emailNotReceivedMessage =
      "Didn’t get the email? Check your junk/spam or resend it.";
  static const String yourAccountCreatedTitle =
      "Your account successfully created!";
  static const String yourAccountCreatedSubTitle =
      "Welcome to Your Ultimate Shopping Destination: Your Account is Created, Unleash the Joy of Seamless Online Shopping!";

  // -- Places
  static const String popularPlaces = "Popular Places";

  // -- Home
  static const String homeAppbarTitle = "Good day for discovering";
  static const String homeAppbarSubTitle = "Nawaf Alwajeeh";
}


/*

// Before:
Text('Welcome back')

// After:
Text(AppLocalizations.of(context).loginTitle)

// With parameters:
Text(AppLocalizations.of(context).uploadPhotos(5))

// Validation:
AppValidator.validateEmptyText('Field Name', value, context)

*/