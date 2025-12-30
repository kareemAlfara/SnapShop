// ====================================
// 📁 lib/feature/mainview/domain/usecases/check_user_reviewed_usecase.dart
// ====================================

import 'package:shop_app/feature/mainview/domain/repository/repo.dart';

class CheckUserReviewedUseCase {
  final productRepo repository;

  CheckUserReviewedUseCase(this.repository);

  Future<bool> call({
    required String productId,
    required String userId,
  }) async {
    if (productId.trim().isEmpty) {
      throw Exception('Product ID cannot be empty');
    }

    if (userId.trim().isEmpty) {
      throw Exception('User ID cannot be empty');
    }

    return await repository.hasUserReviewed(
      productId: productId,
      userId: userId,
    );
  }
}