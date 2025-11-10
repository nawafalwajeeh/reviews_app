import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryImageModel {
  String id;
  String imageUrl;
  String collectionId; // Maps to Category ID of the place
  String? collectionTitle; // Maps to Category ID of the place
  String placeId; // ID of the parent Place
  String placeName; // Name of the parent Place
  DateTime timestamp;

  GalleryImageModel({
    required this.id,
    required this.imageUrl,
    required this.collectionId,
    this.collectionTitle,
    required this.placeId,
    required this.placeName,
    required this.timestamp,
  });

  /// Factory constructor to create a GalleryImageModel from a Firestore document
  factory GalleryImageModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    if (document.data() == null) {
      return GalleryImageModel.empty();
    }

    final data = document.data()!;
    return GalleryImageModel(
      id: document.id,
      imageUrl: data['ImageUrl'] ?? '',
      collectionId: data['CollectionId'] ?? '',
      collectionTitle: data['CollectionTitle'] ?? '',
      placeId: data['PlaceId'] ?? '',
      placeName: data['PlaceName'] ?? '',
      timestamp: (data['Timestamp'] as Timestamp).toDate(),
    );
  }

  /// Empty Gallery Image Model
  static GalleryImageModel empty() => GalleryImageModel(
    id: '',
    imageUrl: '',
    collectionId: '',
    placeId: '',
    placeName: '',
    timestamp: DateTime.now(),
  );

  /// Convert model to JSON structure for Firestore
  Map<String, dynamic> toJson() {
    return {
      'ImageUrl': imageUrl,
      'CollectionId': collectionId,
      'CollectionTitle': collectionTitle,
      'PlaceId': placeId,
      'PlaceName': placeName,
      'Timestamp': timestamp,
    };
  }
}
