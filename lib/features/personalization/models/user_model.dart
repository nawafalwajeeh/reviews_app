import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reviews_app/utils/formatters/formatter.dart';

// import '../../shop/models/cart_model.dart';
import 'address_model.dart';

class UserModel {
  // Keep those values final which you do not want to update
  final String? id;
  String firstName;
  String lastName;
  String userName;
  final String email;
  String phoneNumber;
  String profilePicture;
  final List<AddressModel>? addresses;
  String? gender;
  DateTime? birthDate;

  /// Constructor for UserModel
  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.profilePicture,
    this.addresses,
    this.gender,
    this.birthDate,
  });

  /// Helper function to get the full name
  String get fullName => '$firstName $lastName';

  /// Helper function to format phone number
  String get formattedPhoneNo => AppFormatter.formatPhoneNumber(phoneNumber);

  /// static function to split full name into first and last name.
  static List<String> nameParts(String fullName) => fullName.split(' ');

  /// static function to generate a username from the full name.
  static String generateUsername(String fullName) {
    List<String> nameParts = fullName.split(' ');
    String firstName = nameParts[0].toLowerCase();
    String lastName = nameParts.length > 1 ? nameParts[1].toLowerCase() : '';

    String camelCaseUsername = '$firstName$lastName';
    String usernameWithPrefix = camelCaseUsername;
    return usernameWithPrefix;
  }

  /// static method to create instance without send parameters
  /// for example:
  /// ```dart
  /// final user = UserModel.empty()
  /// ```
  static UserModel empty() => UserModel(
    id: '',
    firstName: '',
    lastName: '',
    userName: '',
    email: '',
    phoneNumber: '',
    profilePicture: '',
  );

  /// method to convert from [UserModel] to [json]
  Map<String, dynamic> toJson() => {
    'FirstName': firstName,
    'LastName': lastName,
    'Username': userName,
    'Email': email,
    'PhoneNumber': phoneNumber,
    'ProfilePicture': profilePicture,
    'Gender': gender,
    'BirthDate': birthDate?.toIso8601String(),
  };

  /// convert from [json] to  [UserModel]
  factory UserModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    if (document.data() != null) {
      final data = document.data()!;
      return UserModel(
        id: document.id,
        firstName: data['FirstName'] ?? '',
        lastName: data['LastName'] ?? '',
        userName: data['Username'] ?? '',
        email: data['Email'] ?? '',
        phoneNumber: data['PhoneNumber'] ?? '',
        profilePicture: data['ProfilePicture'] ?? '',
        gender: data['Gender'],
        birthDate: data['BirthDate'] != null
            ? DateTime.parse(data['BirthDate'])
            : null,
      );
    } else {
      return empty();
    }
  }
}
