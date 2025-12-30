import 'package:shop_app/feature/mainview/domain/entities/cartEntity.dart';
import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';

class AllCartEntity {
  final List<CartEntity> carts;

  AllCartEntity({required this.carts});
  getallCartPrice() {
    double total = 0.0;
    for (var cart in carts) {
      total += cart.getPrice();
    }
    return  double.parse(total.toStringAsFixed(2));
  }

  addCart(CartEntity cart) {
    carts.add(cart);
  }
isExist(ProductEntity product) {
    for (var item in carts) {
      if (item.product.id == product.id) {
        return true;
      }
    }
    return false;

}
  getallCartItems(ProductEntity product) {
    for (var item in carts) {
      if (item.product == product) {
        return item;
      }
    }
    return CartEntity(product: product, quantity: 1);
  }

  deleteCartItems(CartEntity cart) {
    carts.remove(cart);
  }
  deleteAllCartItems() {
    carts.clear();
  }
}
