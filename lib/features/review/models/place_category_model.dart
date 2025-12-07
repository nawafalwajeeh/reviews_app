import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceCategoryModel {
  final String id;
  final String placeId;
  final String categoryId;
  String? userId;

  PlaceCategoryModel({
    this.id = '',
    required this.placeId,
    required this.categoryId,
    this.userId = '',
  });

  Map<String, dynamic> toJson() {
    return {'placeId': placeId, 'categoryId': categoryId, 'userId': userId};
  }

  factory PlaceCategoryModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return PlaceCategoryModel(
      id: snapshot.id,
      placeId: data['placeId'] as String,
      categoryId: data['categoryId'] as String,
      userId: (data['userId'] ?? '') as String,
    );
  }
}
