import 'package:shop_app/feature/mainview/domain/entities/favoritEntity.dart';
import 'package:shop_app/feature/mainview/domain/entities/review_entity.dart';

class ProductEntity {
  final String id;
  final String title;
  final double price;
  final String category;
  final String description;
  final String image;
  final int quantity;
  final num avgRating;
  final List<favoritEntity> favorites;
  final List<ReviewEntity> reviews;

  ProductEntity({
    required this.favorites,
    required this.reviews,
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.description,
    required this.image,
    required this.quantity,
    this.avgRating = 0,
  });

  // Helper: Get review count
  int get reviewCount => reviews.length;

  // Helper: Check if has reviews
  bool get hasReviews => reviews.isNotEmpty;

  // Helper: Get rating percentage
  double get ratingPercentage => avgRating > 0 ? (avgRating / 5) * 100 : 0;

  // Helper: Get rating distribution
  Map<int, int> get ratingDistribution {
    final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var review in reviews) {
      final rating = review.ratingCount.round();
      if (rating >= 1 && rating <= 5) {
        distribution[rating] = (distribution[rating] ?? 0) + 1;
      }
    }
    return distribution;
  }

  // Helper: Get rating percentage for each star
  double getRatingPercentage(int stars) {
    if (reviews.isEmpty) return 0;
    final count = reviews.where((r) => r.ratingCount.round() == stars).length;
    return (count / reviews.length) * 100;
  }
}