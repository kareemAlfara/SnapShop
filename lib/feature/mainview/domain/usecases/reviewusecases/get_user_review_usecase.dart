// ====================================
// 📁 lib/feature/mainview/domain/usecases/get_user_review_usecase.dart
// ====================================

import 'package:shop_app/feature/mainview/domain/entities/review_entity.dart';
import 'package:shop_app/feature/mainview/domain/repository/repo.dart';

class GetUserReviewUseCase {
  final productRepo repository;

  GetUserReviewUseCase(this.repository);

  Future<ReviewEntity?> call({
    required String productId,
    required String userId,
  }) async {
    if (productId.trim().isEmpty) {
      throw Exception('Product ID cannot be empty');
    }

    if (userId.trim().isEmpty) {
      throw Exception('User ID cannot be empty');
    }

    return await repository.getUserReview(
      productId: productId,
      userId: userId,
    );
  }
}