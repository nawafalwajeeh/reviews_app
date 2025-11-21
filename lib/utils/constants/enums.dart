/* --
      LIST OF Enums
      They cannot be created inside a class.
-- */

/// Switch of Custom Text-Size Widget
enum TextSizes { small, medium, large }

enum ImageType { asset, network, memory, file }

enum MediaCategory { folders, categories, places, users }

enum PaymentMethods {
  paypal,
  googlePay,
  applePay,
  visa,
  masterCard,
  creditCard,
  paystack,
  razorPay,
  paytm,
}

enum NotificationType {
  reviewAdded,
  reviewLiked,
  commentAdded,
  replyAdded,
  placeFeatured,
  milestoneReached,
  newFollower,
  systemAnnouncement,
}

enum QuestionType {
  rating,
  yesOrNo,
  text,
}