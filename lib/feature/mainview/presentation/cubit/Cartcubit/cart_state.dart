part of 'cart_cubit.dart';

sealed class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

final class CartInitial extends CartState {}
final class AddtoCartSuccess extends CartState {}
final class DeleteCartSuccess extends CartState {}
final class CartUpdated extends CartState {
  final List<CartEntity> carts;
  const CartUpdated(this.carts);

  @override
  List<Object> get props => [carts];
}
