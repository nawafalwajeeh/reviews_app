import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceModel {
  String id;
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
  final int reviewsCount;
  final List<String>? tags;
  final double? latitude;
  final double? longitude;
  final String? websiteUrl;
  bool isFavorite;
  String? phoneNumber;
  // String? openingHourse;

  PlaceModel({
    required this.id,
    required this.title,
    required this.location,
    required this.categoryId,
    required this.description,
    required this.rating,
    this.reviewsCount = 0,
    required this.userId,
    required this.thumbnail,
    this.tags,
    this.images,
    bool? isFavorite,
    this.isFeatured,
    this.dateAdded,
    this.latitude,
    this.longitude,
    this.websiteUrl,
    this.phoneNumber,
    // this.openingHourse,
  }) : isFavorite = isFavorite ?? false;

  /// Creates a new instance of PlaceModel with optional new values,
  /// preserving existing values if no new value is provided.
  PlaceModel copyWith({
    String? id,
    String? title,
    String? userId,
    String? description,
    String? thumbnail,
    List<String>? images,
    bool? isFeatured,
    DateTime? dateAdded,
    String? location,
    String? categoryId,
    double? rating,
    int? reviewsCount,
    List<String>? tags,
    double? latitude,
    double? longitude,
    String? websiteUrl,
    bool? isFavorite,
    String? phoneNumber,
  }) {
    return PlaceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      images: images ?? this.images,
      isFeatured: isFeatured ?? this.isFeatured,
      dateAdded: dateAdded ?? this.dateAdded,
      location: location ?? this.location,
      categoryId: categoryId ?? this.categoryId,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      tags: tags ?? this.tags,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  /// -- Create Empty PlaceModel to create empty instance
  static PlaceModel empty() => PlaceModel(
    id: '',
    title: '',
    userId: '',
    location: '',
    categoryId: '',
    description: '',
    rating: 0.0,
    reviewsCount: 0, // Default count
    thumbnail: '',
    images: [],
    tags: [],
  );

  /// -- Json Format (To save data to Firestore)
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Title': title,
      'Description': description,
      'UserId': userId,
      'Location': location,
      'CategoryId': categoryId,
      'Rating': rating,
      'Thumbnail': thumbnail,
      'Images': images ?? [],
      'Tags': tags ?? [],
      'IsFeatured': isFeatured ?? false,
      'DateAdded': dateAdded,
      'Latitude': latitude,
      'Longitude': longitude,
      'WebsiteUrl': websiteUrl,
      'PhoneNumber': phoneNumber,
      'ReviewCount': reviewsCount,
      // 'OpeningHourse': openingHourse,
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
      reviewsCount: (data['ReviewCount'] ?? 0).toInt(),
      thumbnail: data['Thumbnail'] ?? '',
      isFeatured: data['IsFeatured'] ?? false,
      dateAdded: data['DateAdded'] != null
          ? (data['DateAdded'] as Timestamp).toDate()
          : null,
      latitude: double.tryParse((data['Latitude'] ?? 0.0).toString()),
      longitude: double.tryParse((data['Longitude'] ?? 0.0).toString()),
      websiteUrl: data['WebsiteUrl'],
      images: data['Images'] != null ? List<String>.from(data['Images']) : [],
      tags: data['Tags'] != null ? List<String>.from(data['Tags']) : [],
      isFavorite: false,
      phoneNumber: data['PhoneNumber'] ?? '',
      // openingHourse: data['OpeningHourse'] ?? '',
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
      reviewsCount: (data['ReviewCount'] ?? 0).toInt(),
      thumbnail: data['Thumbnail'] ?? '',
      isFeatured: data['IsFeatured'] ?? false,
      dateAdded: data['DateAdded'] != null
          ? (data['DateAdded'] as Timestamp).toDate()
          : null,
      latitude: double.tryParse((data['Latitude'] ?? 0.0).toString()),
      longitude: double.tryParse((data['Longitude'] ?? 0.0).toString()),
      websiteUrl: data['WebsiteUrl'],
      images: data['Images'] != null ? List<String>.from(data['Images']) : [],
      tags: data['Tags'] != null ? List<String>.from(data['Tags']) : [],
      isFavorite: false,
      phoneNumber: data['PhoneNumber'] ?? '',
      // openingHourse: data['OpeningHourse'] ?? '',
    );
  }
}
