import 'package:cloud_firestore/cloud_firestore.dart';

class CollectionItem {
  String id;
  String title;
  String imageUrl;
  int photoCount;

  CollectionItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.photoCount,
  });

  /// Factory constructor to create a CollectionItem from a Firestore document
  factory CollectionItem.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() == null) {
      return CollectionItem.empty();
    }

    final data = document.data()!;
    return CollectionItem(
      id: document.id,
      title: data['Title'] ?? '',
      imageUrl: data['ImageUrl'] ?? '',
      photoCount: data['PhotoCount'] ?? 0,
    );
  }

  /// Empty Collection Item Model
  static CollectionItem empty() => CollectionItem(id: '', title: '', imageUrl: '', photoCount: 0);

  /// Convert model to JSON structure for Firestore
  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      'ImageUrl': imageUrl,
      'PhotoCount': photoCount,
    };
  }
}

// class CollectionItem {
//   final String imageUrl;
//   final String title;
//   final int photoCount;

//   const CollectionItem({
//     required this.imageUrl,
//     required this.title,
//     required this.photoCount,
//   });
// }