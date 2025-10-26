// ================== Data Model ==================
class ReviewModel {
  final String userName;
  final String avatarUrl;
  final int rating;
  final String comment;
  final String timeAgo;
  final int likes;

  const ReviewModel({
    required this.userName,
    required this.avatarUrl,
    required this.rating,
    required this.comment,
    required this.timeAgo,
    required this.likes,
  });
}
