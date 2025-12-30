import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';
import 'package:shop_app/feature/mainview/domain/repository/repo.dart';

class Latestusecase {
    final productRepo repo;

  Latestusecase(this.repo);
  Future<List<ProductEntity>> call() {
    return repo.lastestArrrival();
  }
}