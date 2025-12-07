class FeaturedImagesModel {
  final String id;
  final String title;    // Place Name
  final String subtitle; // Category Name
  final String imageUrl;

  FeaturedImagesModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });

  static FeaturedImagesModel empty() => FeaturedImagesModel(
      id: '', title: '', subtitle: '', imageUrl: '');
}
