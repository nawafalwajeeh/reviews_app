/// VALIDATION CLASS
class AppValidator {
  /// Empty Text Validation
  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required.';
    }

    return null;
  }

  /// Username Validation
  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Username is required.';
    }

    // Define a regular expression pattern for the username.
    const pattern = r"^[a-zA-Z0-9_-]{3,20}$";

    // Create a RegExp instance from the pattern.
    final regex = RegExp(pattern);

    // Use the hasMatch method to check if the username matches the pattern.
    bool isValid = regex.hasMatch(username);

    // Check if the username doesn't start or end with an underscore or hyphen.
    if (isValid) {
      isValid =
          !username.startsWith('_') &&
          !username.startsWith('-') &&
          !username.endsWith('_') &&
          !username.endsWith('-');
    }

    if (!isValid) {
      return 'Username is not valid.';
    }

    return null;
  }

  /// Email Validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required.';
    }

    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return 'Invalid email address.';
    }

    return null;
  }

  /// Password Validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    // Check for minimum password length
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }

    // Check for uppercase letters
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }

    // Check for numbers
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number.';
    }

    // Check for special characters
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character.';
    }

    return null;
  }

  /// Phone Number Validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required.';
    }

    // Regular expression for phone number validation (assuming a 10-digit US phone number format)
    final phoneRegExp = RegExp(r'^\d{12}$');

    if (!phoneRegExp.hasMatch(value)) {
      return 'Invalid phone number format (12 digits required).';
    }

    return null;
  }

    /// Validates a website URL.
  /// Returns null when valid (or empty since field is optional), otherwise returns an error message.
  static String? validateWebsite(String? value) {
    if (value == null || value.trim().isEmpty) {
      // optional field: consider empty as valid
      return null;
    }

    final input = value.trim();

    // quick length guard
    if (input.length > 2000) return 'URL is too long';

    // Try to parse as URI. Accepts full URLs with scheme.
    Uri? uri = Uri.tryParse(input);

    bool isValid = false;
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty) {
      // ensure host looks like a domain (contains a dot)
      if (uri.host.contains('.')) isValid = true;
    } else {
      // Accept scheme-less entries like "example.com" by prefixing https:// and re-checking
      final withScheme = Uri.tryParse('https://$input');
      if (withScheme != null && withScheme.host.isNotEmpty && withScheme.host.contains('.')) {
        isValid = true;
      }
    }

    return isValid ? null : 'Please enter a valid website URL (e.g. https://example.com)';
  }

  // Add more custom validators as needed for your specific requirements.
}
