import 'package:cloud_firestore/cloud_firestore.dart';

class CollectionItem {
  String id;
  String collectionId;
  String title;
  String imageUrl;
  int photoCount;
  DateTime? lastUpdated;

  CollectionItem({
    required this.id,
    required this.title,
    required this.collectionId,
    required this.imageUrl,
    required this.photoCount,
    this.lastUpdated,
  });

  /// Convert model to JSON structure for Firestore
  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      'CollectionId': collectionId,
      'ImageUrl': imageUrl,
      'PhotoCount': photoCount,
      'LastUpdated': lastUpdated != null
          ? Timestamp.fromDate(lastUpdated!)
          : null,
    };
  }

  /// Factory constructor to create a CollectionItem from a Firestore document
  factory CollectionItem.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    if (document.data() == null) {
      return CollectionItem.empty();
    }

    final data = document.data()!;
    return CollectionItem(
      id: document.id,
      title: data['Title'] ?? '',
      collectionId: data['CollectionId'] ?? '',
      imageUrl: data['ImageUrl'] ?? '',
      photoCount: data['PhotoCount'] ?? 0,
      lastUpdated: data['LastUpdated'] != null
          ? (data['LastUpdated'] as Timestamp).toDate()
          : null,
    );
  }

  /// Empty Collection Item Model
  static CollectionItem empty() =>
      CollectionItem(id: '', title: '', imageUrl: '', photoCount: 0, collectionId: '');
}
