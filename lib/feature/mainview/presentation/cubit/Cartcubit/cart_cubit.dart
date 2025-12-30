import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/feature/mainview/domain/entities/allCartEntity.dart';
import 'package:shop_app/feature/mainview/domain/entities/cartEntity.dart';
import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial());

  static CartCubit get(context) => BlocProvider.of(context);
  AllCartEntity allCartEntity = AllCartEntity(carts: []);

    void addProductToCart(ProductEntity product) {
    if (allCartEntity.isExist(product)) {
      // optionally increase quantity or ignore
    } else {
      allCartEntity.addCart(CartEntity(product: product, quantity: 1));
    }
    emit(CartUpdated(List.from(allCartEntity.carts))); // new state with items
  }
  

  void removeProductFromCart(ProductEntity product) {
    allCartEntity.carts.removeWhere((item) => item.product.id == product.id);
    emit(CartUpdated(List.from(allCartEntity.carts)));
  }

  bool isInCart(ProductEntity product) {
    return allCartEntity.isExist(product);
  }

  void clearCart() {
    allCartEntity.deleteAllCartItems();
    emit(CartUpdated([]));
  }
void updateQuantity({
  required ProductEntity product,
  required int quantity,
}) {
  for (int i = 0; i < allCartEntity.carts.length; i++) {
    if (allCartEntity.carts[i].product.id == product.id) {
      allCartEntity.carts[i] =
          CartEntity(product: allCartEntity.carts[i].product, quantity: quantity);
      break;
    }
  }
  emit(CartUpdated(List.from(allCartEntity.carts)));
}
}
