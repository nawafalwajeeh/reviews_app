import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  String id;
  String name;
  String image;
  String parentId;
  bool isFeatured;
  String iconKey;
  String gradientKey;
  int iconColorValue;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.isFeatured,
    this.parentId = '',
    this.iconKey = 'default_icon',
    this.gradientKey = 'default_gradient',
    this.iconColorValue = 0xFFFFFFFF,
  });

  /// Empty Helper Function
  static CategoryModel empty() => CategoryModel(
    id: '',
    name: '',
    image: '',
    isFeatured: false,
    iconKey: '',
    gradientKey: '',
    iconColorValue: 0xFFFFFFFF,
  );

  /// Convert Model to json structure so that you can store data in Firestore
  Map<String, dynamic> toJson() => {
    'Name': name,
    'Image': image,
    'ParentId': parentId,
    'IsFeatured': isFeatured,
    'IconKey': iconKey,
    'GradientKey': gradientKey,
    'IconColorValue': iconColorValue,
  };

  /// Map json oriented document snapshot from Firestore to CategoryModel
  factory CategoryModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    if (document.data() != null) {
      final data = document.data()!;

      // Map Json Record to the Model
      return CategoryModel(
        id: document.id,
        name: data['Name'] ?? '',
        image: data['Image'] ?? '',
        parentId: data['ParentId'] ?? '',
        isFeatured: data['IsFeatured'] ?? false,
        iconKey: data['IconKey'] ?? '',
        gradientKey: data['GradientKey'] ?? '',
        // Ensure color value is retrieved as an int
        iconColorValue: (data['IconColorValue'] is int)
            ? data['IconColorValue']
            : 0xFFFFFFFF,
      );
    } else {
      return CategoryModel.empty();
    }
  }
}
