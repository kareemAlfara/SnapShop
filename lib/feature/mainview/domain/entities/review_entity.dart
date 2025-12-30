class ReviewEntity {
  final int? id;
  final String productId;
  final String userId;
  final String name;
  final String descriptionMessage;
  final num ratingCount;
  final String createdAt;

  ReviewEntity({
    this.id,
    required this.productId,
    required this.userId,
    required this.name,
    required this.descriptionMessage,
    required this.ratingCount,
    required this.createdAt,
  });
}