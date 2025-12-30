// ====================================
// 📁 lib/feature/mainview/domain/usecases/update_review_usecase.dart
// ====================================

import 'package:shop_app/feature/mainview/domain/repository/repo.dart';

class UpdateReviewUseCase {
  final productRepo repository;

  UpdateReviewUseCase(this.repository);

  Future<void> call({
    required int reviewId,
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

    if (reviewId <= 0) {
      throw Exception('Invalid review ID');
    }

    // ✅ Update review
    return await repository.updateReview(
      reviewId: reviewId,
      descriptionMessage: descriptionMessage,
      ratingCount: ratingCount,
    );
  }
}