    import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';

class CartEntity {
      final ProductEntity product;
       int quantity;

  CartEntity({required this.product,required this.quantity });

  getPrice() {
    return product.price * quantity;
  }
  
}