// ====================================
// 📁 lib/feature/mainview/domain/usecases/get_product_reviews_usecase.dart
// ====================================

import 'package:shop_app/feature/mainview/domain/entities/review_entity.dart';
import 'package:shop_app/feature/mainview/domain/repository/repo.dart';

class GetProductReviewsUseCase {
  final productRepo repository;

  GetProductReviewsUseCase(this.repository);

  Future<List<ReviewEntity>> call(String productId) async {
    if (productId.trim().isEmpty) {
      throw Exception('Product ID cannot be empty');
    }

    return await repository.getProductReviews(productId);
  }
}