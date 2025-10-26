import 'package:intl/intl.dart';

class AppFormatter {
  static String formatDate(DateTime? date) {
    date ??= DateTime.now();
    return DateFormat('dd-MMM-yyyy').format(date);
  }

  static String formatCurrency(
    double amount, {
    String locale = 'en_US',
    String symbol = '\$',
  }) {
    return NumberFormat.currency(locale: locale, symbol: symbol).format(amount);
  }

  static String formatPhoneNumber(String phoneNumber) {
    // Assuming a 9-digit phone number format (778) 228-445
    if (phoneNumber.length == 9 || phoneNumber.length == 10) {
      return '(${phoneNumber.substring(0, 3)}) ${phoneNumber.substring(3, 6)} ${phoneNumber.substring(6)}';
    } else if (phoneNumber.length == 11) {
      return '(${phoneNumber.substring(0, 4)}) ${phoneNumber.substring(4, 7)} ${phoneNumber.substring(7)}';
    }

    return phoneNumber;
  }

  static String internationalFormatPhoneNumber(
    String phoneNumber, {
    String suppliedCountryCode = '+967',
  }) {
    // Remove any non-digit characters from the phone number
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Extract the country code from the digitsOnly
    final String countryCode = '+${digitsOnly.substring(0, 2)}';

    // Add the remaining digits with proper formatting
    final formattedNumber = StringBuffer();
    formattedNumber.write('($countryCode)');

    int i = 0;
    while (i < digitsOnly.length) {
      int groupLength = 2;
      if (i == 0 && countryCode == suppliedCountryCode) {
        groupLength = 3;
      }

      final int end = i + groupLength;
      formattedNumber.write(digitsOnly.substring(i, end));

      if (end < digitsOnly.length) {
        formattedNumber.write(' ');
      }
      i = end;
    }

    return formattedNumber.toString();
  }
}
