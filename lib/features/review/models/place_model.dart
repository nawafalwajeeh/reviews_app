import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceModel {
  final String id;
  final String title;
  final String userId;
  final String description;
  final String thumbnail;
  final List<String>? images;
  final bool? isFeatured;
  final DateTime? dateAdded;
  final String location;
  final String categoryId;
  final double rating;
  final List<String>? amenities;
  final double? latitude;
  final double? longitude;
  final String? websiteUrl;
  bool isFavorite;

  PlaceModel({
    required this.id,
    required this.title,
    required this.location,
    required this.categoryId,
    required this.description,
    required this.rating,
    required this.userId,
    required this.thumbnail,
    this.amenities,
    this.images,
    bool? isFavorite,
    this.isFeatured,
    this.dateAdded,
    this.latitude,
    this.longitude,
    this.websiteUrl,
  }) : isFavorite = isFavorite ?? false;

  /// -- Create Empty PlaceModel to create empty instance
  static PlaceModel empty() => PlaceModel(
    id: '',
    title: '',
    userId: '',
    location: '',
    categoryId: '',
    description: '',
    rating: 0.0,
    thumbnail: '',
    images: [],
    amenities: [],
  );

  /// -- Json Format (To save data to Firestore)
  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      'Description': description,
      'UserId': userId,
      'Location': location,
      'CategoryId': categoryId,
      'Rating': rating,
      'Thumbnail': thumbnail,
      'Images': images ?? [],
      'Amenities': amenities ?? [],
      'IsFeatured': isFeatured ?? false,
      'DateAdded': dateAdded,
      'Latitude': latitude,
      'Longitude': longitude,
      'WebsiteUrl': websiteUrl,
    };
  }

  /// -- Map Json oriented document snapshot from Firebase to Model
  factory PlaceModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    if (document.data() == null) return PlaceModel.empty();
    final data = document.data()!;

    return PlaceModel(
      id: document.id,
      title: data['Title'] ?? '',
      userId: data['UserId'] ?? '',
      description: data['Description'] ?? '',
      location: data['Location'] ?? '',
      categoryId: data['CategoryId'] ?? '',
      rating: double.parse((data['Rating'] ?? 0.0).toString()),
      thumbnail: data['Thumbnail'] ?? '',
      isFeatured: data['IsFeatured'] ?? false,
      dateAdded: data['DateAdded'] != null
          ? (data['DateAdded'] as Timestamp).toDate()
          : null,
      latitude: double.tryParse((data['Latitude'] ?? 0.0).toString()),
      longitude: double.tryParse((data['Longitude'] ?? 0.0).toString()),
      websiteUrl: data['WebsiteUrl'],
      images: data['Images'] != null ? List<String>.from(data['Images']) : [],
      amenities: data['Amenities'] != null
          ? List<String>.from(data['Amenities'])
          : [],
      isFavorite: false,
    );
  }

  /// -- Map Json-oriented document snapshot from Query results (Fully Coded)
  factory PlaceModel.fromQuerySnapshot(
    QueryDocumentSnapshot<Object?> document,
  ) {
    final data = document.data() as Map<String, dynamic>;

    return PlaceModel(
      id: document.id,
      title: data['Title'] ?? '',
      userId: data['UserId'] ?? '',
      description: data['Description'] ?? '',
      location: data['Location'] ?? '',
      categoryId: data['CategoryId'] ?? '',
      rating: double.parse((data['Rating'] ?? 0.0).toString()),
      thumbnail: data['Thumbnail'] ?? '',
      isFeatured: data['IsFeatured'] ?? false,
      dateAdded: data['DateAdded'] != null
          ? (data['DateAdded'] as Timestamp).toDate()
          : null,
      latitude: double.tryParse((data['Latitude'] ?? 0.0).toString()),
      longitude: double.tryParse((data['Longitude'] ?? 0.0).toString()),
      websiteUrl: data['WebsiteUrl'],
      images: data['Images'] != null ? List<String>.from(data['Images']) : [],
      amenities: data['Amenities'] != null
          ? List<String>.from(data['Amenities'])
          : [],
      isFavorite: false,
    );
  }
}
