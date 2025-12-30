// ====================================
// 📁 lib/feature/mainview/domain/usecases/add_review_usecase.dart
// ====================================

import 'package:shop_app/feature/mainview/domain/entities/review_entity.dart';
import 'package:shop_app/feature/mainview/domain/repository/repo.dart';

class AddReviewUseCase {
  final productRepo repository;

  AddReviewUseCase(this.repository);

  Future<ReviewEntity> call({
    required String productId,
    required String userId,
    required String name,
    required String descriptionMessage,
    required num ratingCount,
  }) async {
    // ✅ Validation
    if (ratingCount < 1 || ratingCount > 5) {
      throw Exception('Rating must be between 1 and 5');
    }

    if (descriptionMessage.trim().isEmpty) {
      throw Exception('Review message cannot be empty');
    }

    if (name.trim().isEmpty) {
      throw Exception('Name cannot be empty');
    }

    // ✅ Check if user already reviewed
    final hasReviewed = await repository.hasUserReviewed(
      productId: productId,
      userId: userId,
    );

    if (hasReviewed) {
      throw Exception('You have already reviewed this product');
    }

    // ✅ Add review
    return await repository.addReview(
      productId: productId,
      userId: userId,
      name: name,
      descriptionMessage: descriptionMessage,
      ratingCount: ratingCount,
    );
  }
}