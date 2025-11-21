import 'package:cloud_firestore/cloud_firestore.dart';

import '../../personalization/models/address_model.dart';
import 'custom_questions_model.dart';

class PlaceModel {
  String id;
  String title;
  final String userId;
  String description;
  String thumbnail;
  List<String>? images;
  final bool? isFeatured;
  final DateTime? dateAdded;
  final AddressModel address;
  final String categoryId;
  final double averageRating;
  final int reviewsCount;
  final List<String>? tags;
  // final double? latitude;
  // final double? longitude;
  final String? websiteUrl;
  final Map<String, int> ratingDistribution;
  bool isFavorite;
  String? phoneNumber;
  String creatorName;
  String creatorAvatarUrl;
  int likeCount;
  final int followerCount;
  // New fields for custom questions and barcode
  final List<CustomQuestion>? customQuestions;
  final String? uniqueBarcode;
  final String barcodeData; // Store the place ID for scanning

  // Add getters for convenience
  double get latitude => address.latitude;
  double get longitude => address.longitude;

  PlaceModel({
    required this.id,
    required this.title,
    required this.address,
    required this.categoryId,
    required this.description,
    required this.averageRating,
    this.reviewsCount = 0,
    required this.userId,
    required this.thumbnail,
    this.ratingDistribution = const {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0},
    this.tags,
    this.images,
    bool? isFavorite,
    this.isFeatured,
    this.dateAdded,
    // this.latitude,
    // this.longitude,
    this.websiteUrl,
    this.phoneNumber,

    // New required fields with default safe values
    this.creatorName = 'Unknown Creator',
    this.creatorAvatarUrl = '', // Placeholder for no avatar
    this.likeCount = 0,
    this.followerCount = 0,
    this.customQuestions,
    this.uniqueBarcode,
    this.barcodeData = '',
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
    AddressModel? address,
    String? categoryId,
    double? averageRating,
    int? reviewsCount,
    List<String>? tags,
    // double? latitude,
    // double? longitude,
    String? websiteUrl,
    Map<String, int>? ratingDistribution,
    bool? isFavorite,
    String? phoneNumber,
    // New CopyWith arguments
    String? creatorName,
    String? creatorAvatarUrl,
    int? likeCount,
    int? followerCount,
    List<CustomQuestion>? customQuestions,
    String? uniqueBarcode,
    String? barcodeData,
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
      address: address ?? this.address,
      categoryId: categoryId ?? this.categoryId,
      averageRating: averageRating ?? this.averageRating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      tags: tags ?? this.tags,
      ratingDistribution: ratingDistribution ?? this.ratingDistribution,
      // latitude: latitude ?? this.latitude,
      // longitude: longitude ?? this.longitude,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      creatorName: creatorName ?? this.creatorName,
      creatorAvatarUrl: creatorAvatarUrl ?? this.creatorAvatarUrl,
      likeCount: likeCount ?? this.likeCount,
      followerCount: followerCount ?? this.followerCount,
      customQuestions: customQuestions ?? this.customQuestions,
      uniqueBarcode: uniqueBarcode ?? this.uniqueBarcode,
      barcodeData: barcodeData ?? this.barcodeData,
    );
  }

  /// -- Create Empty PlaceModel to create empty instance
  static PlaceModel empty() => PlaceModel(
    id: '',
    title: '',
    userId: '',
    address: AddressModel.empty(),
    categoryId: '',
    description: '',
    averageRating: 0.0,
    reviewsCount: 0,
    thumbnail: '',
    images: [],
    tags: [],
    ratingDistribution: {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0},
    creatorName: 'No Creator',
    creatorAvatarUrl: '',
    likeCount: 0,
    followerCount: 0,
  );

  /// -- Json Format (To save data to Firestore)
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Title': title,
      'Description': description,
      'UserId': userId,
      'Address': address.toJson(),
      'CategoryId': categoryId,
      'Thumbnail': thumbnail,
      'Images': images ?? [],
      'Tags': tags ?? [],
      'IsFeatured': isFeatured ?? false,
      'DateAdded': dateAdded,
      // 'Latitude': latitude,
      // 'Longitude': longitude,
      'WebsiteUrl': websiteUrl,
      'PhoneNumber': phoneNumber,
      'ReviewCount': reviewsCount,
      'RatingDistribution': ratingDistribution,
      'CreatorName': creatorName,
      'CreatorAvatarUrl': creatorAvatarUrl,
      'LikeCount': likeCount,
      'FollowerCount': followerCount,
      'CustomQuestions': customQuestions?.map((q) => q.toJson()).toList() ?? [],
      'UniqueBarcode': uniqueBarcode,
      'BarcodeData': barcodeData,
    };
  }

  static double _calculateAverageRating(Map<String, int> distribution) {
    int totalScore =
        (distribution['5']! * 5) +
        (distribution['4']! * 4) +
        (distribution['3']! * 3) +
        (distribution['2']! * 2) +
        (distribution['1']! * 1);

    int totalReviews = distribution.values.fold<int>(
      0,
      (int sum, int count) => sum + count,
    );

    if (totalReviews == 0) return 0.0;

    // Calculate, then round the result to 2 decimal places
    double rawAverage = totalScore / totalReviews;
    return double.parse(rawAverage.toStringAsFixed(2));
  }

  /// -- Map Json oriented document snapshot from Firebase to Model
  factory PlaceModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    if (document.data() == null) return PlaceModel.empty();
    final data = document.data()!;

    final ratingDistributionData =
        data['RatingDistribution'] ?? {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0};
    final Map<String, int> ratingDistribution = {
      '5': (ratingDistributionData['5'] ?? 0).toInt(),
      '4': (ratingDistributionData['4'] ?? 0).toInt(),
      '3': (ratingDistributionData['3'] ?? 0).toInt(),
      '2': (ratingDistributionData['2'] ?? 0).toInt(),
      '1': (ratingDistributionData['1'] ?? 0).toInt(),
    };

    final calculatedAverageRating = _calculateAverageRating(ratingDistribution);
    final calculatedReviewCount = ratingDistribution.values.fold<int>(
      0,
      (int sum, int count) => sum + count,
    );

    final addressMap = data['Address'] as Map<String, dynamic>?;

    final loadedAddress = (addressMap != null)
        ? AddressModel.fromJson(addressMap)
        : AddressModel.empty();
    final double finalLatitude;
    final double finalLongitude;

    if (loadedAddress.latitude != 0.0 && loadedAddress.longitude != 0.0) {
      finalLatitude = loadedAddress.latitude;
      finalLongitude = loadedAddress.longitude;
    } else {
      // Fallback to direct fields (for old data)
      finalLatitude =
          double.tryParse((data['Latitude'] ?? 0.0).toString()) ?? 0.0;
      finalLongitude =
          double.tryParse((data['Longitude'] ?? 0.0).toString()) ?? 0.0;

      // Update the address with these coordinates
      if (finalLatitude != 0.0 && finalLongitude != 0.0) {
        loadedAddress.latitude = finalLatitude;
        loadedAddress.longitude = finalLongitude;
      }
    }
    final customQuestionsData = data['CustomQuestions'] as List<dynamic>?;
    final List<CustomQuestion> customQuestions = customQuestionsData != null
        ? customQuestionsData.map((q) => CustomQuestion.fromJson(q)).toList()
        : [];

    return PlaceModel(
      id: document.id,
      title: data['Title'] ?? '',
      userId: data['UserId'] ?? '',
      description: data['Description'] ?? '',
      address: loadedAddress,
      categoryId: data['CategoryId'] ?? '',
      averageRating: calculatedAverageRating,
      reviewsCount: calculatedReviewCount,
      thumbnail: data['Thumbnail'] ?? '',
      isFeatured: data['IsFeatured'] ?? false,
      dateAdded: data['DateAdded'] != null
          ? (data['DateAdded'] as Timestamp).toDate()
          : null,
      ratingDistribution: ratingDistribution,
      // latitude: double.tryParse((data['Latitude'] ?? 0.0).toString()),
      // longitude: double.tryParse((data['Longitude'] ?? 0.0).toString()),
      websiteUrl: data['WebsiteUrl'],
      images: data['Images'] != null ? List<String>.from(data['Images']) : [],
      tags: data['Tags'] != null ? List<String>.from(data['Tags']) : [],
      isFavorite: false,
      phoneNumber: data['PhoneNumber'] ?? '',

      // NEW: Parse creator and social fields
      creatorName: data['CreatorName'] ?? 'Unknown Creator',
      creatorAvatarUrl: data['CreatorAvatarUrl'] ?? '',
      likeCount: (data['LikeCount'] ?? 0).toInt(),
      followerCount: (data['FollowerCount'] ?? 0).toInt(),
      customQuestions: customQuestions,
      uniqueBarcode: data['UniqueBarcode'],
      barcodeData: data['BarcodeData'] ?? '',
    );
  }

  /// -- Map Json-oriented document snapshot from Query results (Fully Coded)
  factory PlaceModel.fromQuerySnapshot(
    QueryDocumentSnapshot<Object?> document,
  ) {
    final data = document.data() as Map<String, dynamic>;

    final ratingDistributionData =
        data['RatingDistribution'] ?? {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0};
    final Map<String, int> ratingDistribution = {
      '5': (ratingDistributionData['5'] ?? 0).toInt(),
      '4': (ratingDistributionData['4'] ?? 0).toInt(),
      '3': (ratingDistributionData['3'] ?? 0).toInt(),
      '2': (ratingDistributionData['2'] ?? 0).toInt(),
      '1': (ratingDistributionData['1'] ?? 0).toInt(),
    };

    final calculatedAverageRating = _calculateAverageRating(ratingDistribution);
    final calculatedReviewCount = ratingDistribution.values.fold<int>(
      0,
      (int sum, int count) => sum + count,
    );

    final addressMap = data['Address'] as Map<String, dynamic>?;
    final loadedAddress = (addressMap != null)
        ? AddressModel.fromJson(addressMap)
        : AddressModel.empty();

    final double finalLatitude;
    final double finalLongitude;

    if (loadedAddress.latitude != 0.0 && loadedAddress.longitude != 0.0) {
      finalLatitude = loadedAddress.latitude;
      finalLongitude = loadedAddress.longitude;
    } else {
      // Fallback to direct fields (for old data)
      finalLatitude =
          double.tryParse((data['Latitude'] ?? 0.0).toString()) ?? 0.0;
      finalLongitude =
          double.tryParse((data['Longitude'] ?? 0.0).toString()) ?? 0.0;

      // Update the address with these coordinates
      if (finalLatitude != 0.0 && finalLongitude != 0.0) {
        loadedAddress.latitude = finalLatitude;
        loadedAddress.longitude = finalLongitude;
      }
    }

    return PlaceModel(
      id: document.id,
      title: data['Title'] ?? '',
      userId: data['UserId'] ?? '',
      description: data['Description'] ?? '',
      address: loadedAddress,
      categoryId: data['CategoryId'] ?? '',
      averageRating: calculatedAverageRating,
      reviewsCount: calculatedReviewCount,
      thumbnail: data['Thumbnail'] ?? '',
      isFeatured: data['IsFeatured'] ?? false,
      dateAdded: data['DateAdded'] != null
          ? (data['DateAdded'] as Timestamp).toDate()
          : null,
      ratingDistribution: ratingDistribution,
      // latitude: double.tryParse((data['Latitude'] ?? 0.0).toString()),
      // longitude: double.tryParse((data['Longitude'] ?? 0.0).toString()),
      websiteUrl: data['WebsiteUrl'],
      images: data['Images'] != null ? List<String>.from(data['Images']) : [],
      tags: data['Tags'] != null ? List<String>.from(data['Tags']) : [],
      isFavorite: false,
      phoneNumber: data['PhoneNumber'] ?? '',
      creatorName: data['CreatorName'] ?? 'Unknown Creator',
      creatorAvatarUrl: data['CreatorAvatarUrl'] ?? '',
      likeCount: (data['LikeCount'] ?? 0).toInt(),
      followerCount: (data['FollowerCount'] ?? 0).toInt(),
    );
  }

  @override
  String toString() {
    return address.toString();
  }
}
