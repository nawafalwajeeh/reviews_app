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
  double latitude;
  double longitude;
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
    this.latitude = 0.0,
    this.longitude = 0.0,
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
    latitude: 0.0,
    longitude: 0.0,
  );



    AddressModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? street,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    DateTime? dateTime,
    bool? selectedAddress,
    double? latitude,
    double? longitude,
  }) {
    return AddressModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      dateTime: dateTime ?? this.dateTime,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

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
      'Latitude': latitude,
      'Longitude': longitude,
    };
  }

  // Helper function to safely extract doubles from Firestore, defaulting to 0.0
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Factory constructor to create an AddressModel from a Map
  factory AddressModel.fromJson(Map<String, dynamic> data) {
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
      latitude: _parseDouble(data['Latitude']),
      longitude: _parseDouble(data['Longitude']),
    );
  }

  String get shortAddress {
    // Create a list containing the city and country strings.
    // Use .where((s) => s.isNotEmpty) to filter out any fields that might be
    //  empty from the database, preventing an awkward ", Yemen" or "Taiz, ".
    final parts = [city, country].where((s) => s.isNotEmpty).toList();

    // Join the remaining parts with a comma and a space.
    return parts.join(', ');
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
      latitude: _parseDouble(data['Latitude']),
      longitude: _parseDouble(data['Longitude']),
    );
  }

  @override
  String toString() {
    return '$street, $city, $state $postalCode, $country';
  }
}
