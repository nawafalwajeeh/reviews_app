// // Demo data model and list
// class Place {
//   final String imageUrl;
//   final String title;
//   final String location;
//   final String category;
//   final String subtitle;
//   final double rating;
//   final bool isFavorite;

//   Place({
//     required this.imageUrl,
//     required this.title,
//     required this.location,
//     required this.category,
//     required this.subtitle,
//     required this.rating,
//     this.isFavorite = false,
//   });
// }

// Place Model
class PlaceModel {
  final String thumbnail;
  final List<String> images;
  final String title;
  final String location;
  final String category;
  final String description;
  final double rating;
  final bool isFavorite;
  final List<String> amenities;
  final double pricePerNight;

  PlaceModel({
    required this.thumbnail,
    required this.images,
    required this.title,
    required this.location,
    required this.category,
    required this.description,
    required this.rating,
    this.isFavorite = false,
    required this.amenities,
    required this.pricePerNight,
  });
}
