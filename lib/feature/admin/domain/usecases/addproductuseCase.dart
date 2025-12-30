import 'package:shop_app/feature/admin/domain/repo/productsRepo.dart';
import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';

class Addproductusecase {
  final Productsrepo repository;

  Addproductusecase(this.repository);
  Future<ProductEntity> call({
  required String productname,
    required double productprice,
    required String productdescription,
    required String productcategory,
    required String productimage,
    required String id,
    required int quantity,
  }) async {
    return await repository.addproduct(
      id:id,
      quantity: quantity,
      productname: productname,
      productprice: productprice,
      productdescription: productdescription,
      productcategory: productcategory,
      productimage: productimage,
    );

  }
}
