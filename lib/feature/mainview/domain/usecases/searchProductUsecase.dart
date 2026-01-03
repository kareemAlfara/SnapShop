import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';
import 'package:shop_app/feature/mainview/domain/repository/repo.dart';

class Searchproductusecase {
  productRepo repo;
  Searchproductusecase(this.repo);

  Future<List<ProductEntity>> call(String query) {
    return repo.searchProducts(query);
  }
}
