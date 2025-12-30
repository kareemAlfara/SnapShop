import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';
import 'package:shop_app/feature/mainview/domain/repository/repo.dart';

class Getproductsusecase {
  final productRepo repo;

  Getproductsusecase(this.repo);
  Future<List<ProductEntity>> call() {
    return repo.getproducts();
  }
}
