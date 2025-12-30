// import 'package:shop_app/feature/mainview/domain/entities/favoritEntity.dart';
// import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';
// abstract class productRepo{
//   Future<List<ProductEntity>> getproducts();
//   Future<List<ProductEntity>> lastestArrrival();
//   Future<List<ProductEntity>> searchProducts(String query);

//   Future<List<ProductEntity>> getFavoriteProducts(String userId);
//    Future<favoritEntity> addFavorite({
//     required String productId,
//     required String userId,
//   });

//   /// 🔹 DELETE – remove a product from favorites
//   Future<void> deleteFavorite({
//     required String productId,
//     required String userId,
//   });
// }

import 'package:shop_app/feature/mainview/domain/entities/favoritEntity.dart';
import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';
import 'package:shop_app/feature/mainview/domain/entities/review_entity.dart';

abstract class productRepo {
  // ========== Products ==========
  Future<List<ProductEntity>> getproducts();
  Future<List<ProductEntity>> lastestArrrival();
  Future<List<ProductEntity>> searchProducts(String query);
  Future<ProductEntity> getProductById(String productId); // ⬅️ New

  // ========== Favorites ==========
  Future<List<ProductEntity>> getFavoriteProducts(String userId);
  Future<favoritEntity> addFavorite({
    required String productId,
    required String userId,
  });
  Future<void> deleteFavorite({
    required String productId,
    required String userId,
  });

  // ========== Reviews ========== ⬅️ New Section
  Future<ReviewEntity> addReview({
    required String productId,
    required String userId,
    required String name,
    required String descriptionMessage,
    required num ratingCount,
  });

  Future<List<ReviewEntity>> getProductReviews(String productId);

  Future<void> updateReview({
    required int reviewId,
    required String descriptionMessage,
    required num ratingCount,
  });

  Future<void> deleteReview(int reviewId);

  Future<bool> hasUserReviewed({
    required String productId,
    required String userId,
  });

  Future<ReviewEntity?> getUserReview({
    required String productId,
    required String userId,
  });
}