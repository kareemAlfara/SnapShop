import 'package:shop_app/feature/mainview/domain/entities/favoritEntity.dart';
import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';
import 'package:shop_app/feature/mainview/domain/repository/repo.dart';
class GetFavoriteProductsUsecase {
  final productRepo repo;
  GetFavoriteProductsUsecase(this.repo);

  Future<List<ProductEntity>> call(String userId) async {
    return await repo.getFavoriteProducts(userId);
  }
}

class DeleteFavoriteUsecase {
  final productRepo repo;
  DeleteFavoriteUsecase(this.repo);

  Future<void> call({
    required String productId,
    required String userId,
  }) async {
    return await repo.deleteFavorite(productId: productId, userId: userId);
  }
}

class AddFavoriteUsecase {
  final productRepo repo;
  AddFavoriteUsecase(this.repo);

  Future<favoritEntity> call({
    required String productId,
    required String userId,
  }) async {
    return await repo.addFavorite(productId: productId, userId: userId);
  }
}