import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reviews_app/utils/formatters/formatter.dart';

class AddressModel {
  String id;
  final String name;
  final String phoneNumber;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final DateTime? dateTime;
  bool selectedAddress;

  AddressModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.dateTime,
    this.selectedAddress = true,
  });

  String get formattedPhoneNo => AppFormatter.formatPhoneNumber(phoneNumber);

  static AddressModel empty() => AddressModel(
    id: '',
    name: '',
    phoneNumber: '',
    street: '',
    city: '',
    state: '',
    postalCode: '',
    country: '',
  );

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'PhoneNumber': phoneNumber,
      'Street': street,
      'City': city,
      'State': state,
      'PostalCode': postalCode,
      'Country': country,
      'DateTime': DateTime.now(),
      'SelectedAddress': selectedAddress,
    };
  }

  // Factory constructor to create an AddressModel from a Map
  factory AddressModel.fromMap(Map<String, dynamic> data) {
    return AddressModel(
      id: (data['Id'] ?? '') as String,
      name: (data['Name'] ?? '') as String,
      phoneNumber: (data['PhoneNumber'] ?? '') as String,
      street: (data['Street'] ?? '') as String,
      city: (data['City'] ?? '') as String,
      state: (data['State'] ?? '') as String,
      postalCode: (data['PostalCode'] ?? '') as String,
      country: (data['Country'] ?? '') as String,
      // Check for null before casting to bool. Default to false.
      selectedAddress: (data['SelectedAddress'] ?? false) as bool,
      // Use a null-aware cascade to handle the null Timestamp.
      dateTime: (data['DateTime'] as Timestamp?)?.toDate(),
    );
  }

  // Factory constructor to create an AddressModel from a DocumentSnapshot
  factory AddressModel.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return AddressModel(
      id: snapshot.id,
      name: (data['Name'] ?? '') as String,
      phoneNumber: (data['PhoneNumber'] ?? '') as String,
      street: (data['Street'] ?? '') as String,
      city: (data['City'] ?? '') as String,
      state: (data['State'] ?? '') as String,
      postalCode: (data['PostalCode'] ?? '') as String,
      country: (data['Country'] ?? '') as String,
      selectedAddress: (data['SelectedAddress'] ?? false) as bool,
      dateTime: (data['DateTime'] as Timestamp?)?.toDate(),
    );
  }

  @override
  String toString() {
    return '$street, $city, $state $postalCode, $country';
  }
}
