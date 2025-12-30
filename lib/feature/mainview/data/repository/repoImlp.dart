
// import 'package:shop_app/feature/mainview/data/productRemotedata.dart';
// import 'package:shop_app/feature/mainview/data/mapping/mapper.dart';
// import 'package:shop_app/feature/mainview/domain/entities/favoritEntity.dart';
// import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';
// import 'package:shop_app/feature/mainview/domain/entities/review_entity.dart';
// import 'package:shop_app/feature/mainview/domain/repository/repo.dart';

// class RepoImlp extends productRepo {
//   @override
//   Future<List<ProductEntity>> getproducts() async {
//     final model = await Productremotedata().getproduct();
//     return productmapper.toEntity(model);
//   }

//   @override
//   Future<List<ProductEntity>> lastestArrrival() async {
//     final model = await Productremotedata().latestArrrival();
//     return productmapper.toEntity(model);
//   }

//   @override
//   Future<List<ProductEntity>> searchProducts(String query) async {
//     final model = await Productremotedata().searchProducts(query.trim());
//     return productmapper.toEntity(model);
//   }

//   @override
//   Future<favoritEntity> addFavorite({
//     required String productId,
//     required String userId,
//   }) async {
//     var model = await Productremotedata().addFavorite(
//       productId: productId,
//       userId: userId,
//     );
//     return productmapper.toFavoritesEntity(model);
//   }

//   @override
//   Future<void> deleteFavorite({
//     required String productId,
//     required String userId,
//   }) {
//     return Productremotedata().deleteFavorite(
//       productId: productId,
//       userId: userId,
//     );
//   }

//   @override
//   Future<List<ProductEntity>> getFavoriteProducts(String userId) async {
//     var model = await Productremotedata().getFavoriteProducts(userId);
//     return productmapper.toEntity(model);
//   }

//   @override
//   Future<ReviewEntity> addReview({required String productId, required String userId, required String name, required String descriptionMessage, required num ratingCount}) {
//     // TODO: implement addReview
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> deleteReview(int reviewId) {
//     // TODO: implement deleteReview
//     throw UnimplementedError();
//   }

//   @override
//   Future<ProductEntity> getProductById(String productId) {
//     // TODO: implement getProductById
//     throw UnimplementedError();
//   }

//   @override
//   Future<List<ReviewEntity>> getProductReviews(String productId) {
//     // TODO: implement getProductReviews
//     throw UnimplementedError();
//   }

//   @override
//   Future<ReviewEntity?> getUserReview({required String productId, required String userId}) {
//     // TODO: implement getUserReview
//     throw UnimplementedError();
//   }

//   @override
//   Future<bool> hasUserReviewed({required String productId, required String userId}) {
//     // TODO: implement hasUserReviewed
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> updateReview({required int reviewId, required String descriptionMessage, required num ratingCount}) {
//     // TODO: implement updateReview
//     throw UnimplementedError();
//   }
// }

import 'package:shop_app/feature/mainview/data/productRemotedata.dart';
import 'package:shop_app/feature/mainview/data/mapping/mapper.dart';
import 'package:shop_app/feature/mainview/data/mapping/reviewMapper.dart';
import 'package:shop_app/feature/mainview/domain/entities/favoritEntity.dart';
import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';
import 'package:shop_app/feature/mainview/domain/entities/review_entity.dart';
import 'package:shop_app/feature/mainview/domain/repository/repo.dart';

class RepoImlp extends productRepo {
  // ========== Products ==========
  @override
  Future<List<ProductEntity>> getproducts() async {
    final model = await Productremotedata().getproduct();
    return productmapper.toEntity(model);
  }

  @override
  Future<ProductEntity> getProductById(String productId) async {
    final model = await Productremotedata().getProductById(productId);
    return productmapper.toSingleEntity(model);
  }

  @override
  Future<List<ProductEntity>> lastestArrrival() async {
    final model = await Productremotedata().latestArrrival();
    return productmapper.toEntity(model);
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    final model = await Productremotedata().searchProducts(query.trim());
    return productmapper.toEntity(model);
  }

  // ========== Favorites ==========
  @override
  Future<favoritEntity> addFavorite({
    required String productId,
    required String userId,
  }) async {
    var model = await Productremotedata().addFavorite(
      productId: productId,
      userId: userId,
    );
    return productmapper.toFavoritesEntity(model);
  }

  @override
  Future<void> deleteFavorite({
    required String productId,
    required String userId,
  }) {
    return Productremotedata().deleteFavorite(
      productId: productId,
      userId: userId,
    );
  }

  @override
  Future<List<ProductEntity>> getFavoriteProducts(String userId) async {
    var model = await Productremotedata().getFavoriteProducts(userId);
    return productmapper.toEntity(model);
  }

  // ========== Reviews ========== ⬅️ New Section
  @override
  Future<ReviewEntity> addReview({
    required String productId,
    required String userId,
    required String name,
    required String descriptionMessage,
    required num ratingCount,
  }) async {
    // Check if user already reviewed
    final hasReviewed = await hasUserReviewed(
      productId: productId,
      userId: userId,
    );

    if (hasReviewed) {
      throw Exception('You have already reviewed this product');
    }

    final model = await Productremotedata().addReview(
      productId: productId,
      userId: userId,
      name: name,
      descriptionMessage: descriptionMessage,
      ratingCount: ratingCount,
    );

    return ReviewMapper.toEntity(model);
  }

  @override
  Future<List<ReviewEntity>> getProductReviews(String productId) async {
    final models = await Productremotedata().getProductReviews(productId);
    return ReviewMapper.toListEntity(models);
  }

  @override
  Future<void> updateReview({
    required int reviewId,
    required String descriptionMessage,
    required num ratingCount,
  }) async {
    await Productremotedata().updateReview(
      reviewId: reviewId,
      descriptionMessage: descriptionMessage,
      ratingCount: ratingCount,
    );
  }

  @override
  Future<void> deleteReview(int reviewId) async {
    await Productremotedata().deleteReview(reviewId);
  }

  @override
  Future<bool> hasUserReviewed({
    required String productId,
    required String userId,
  }) async {
    return await Productremotedata().hasUserReviewed(
      productId: productId,
      userId: userId,
    );
  }

  @override
  Future<ReviewEntity?> getUserReview({
    required String productId,
    required String userId,
  }) async {
    final model = await Productremotedata().getUserReview(
      productId: productId,
      userId: userId,
    );

    if (model == null) return null;

    return ReviewMapper.toEntity(model);
  }
}