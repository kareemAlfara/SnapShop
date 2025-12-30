// ====================================
// 📁 lib/feature/mainview/domain/usecases/delete_review_usecase.dart
// ====================================

import 'package:shop_app/feature/mainview/domain/repository/repo.dart';

class DeleteReviewUseCase {
  final productRepo repository;

  DeleteReviewUseCase(this.repository);

  Future<void> call(int reviewId) async {
    if (reviewId <= 0) {
      throw Exception('Invalid review ID');
    }

    return await repository.deleteReview(reviewId);
  }
}