class ReviewModel {
  final int? id;
  final String productId;
  final String userId;
  final String name;
  final String descriptionMessage;
  final num ratingCount;
  final String createdAt;

  ReviewModel({
    this.id,
    required this.productId,
    required this.userId,
    required this.name,
    required this.descriptionMessage,
    required this.ratingCount,
    required this.createdAt,
  });

  // From JSON (Supabase → Model)
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as int?,
      productId: json['product_id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      descriptionMessage: json['descriptionmessage'] as String,
      ratingCount: json['ratingcount'] as num,
      createdAt: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  // To JSON (Model → Supabase)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'product_id': productId,
      'user_id': userId,
      'name': name,
      'descriptionmessage': descriptionMessage,
      'ratingcount': ratingCount,
      'created_at': createdAt,
    };
  }
}