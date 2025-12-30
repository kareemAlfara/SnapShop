part of 'product_cubit.dart';

sealed class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

final class ProductInitial extends ProductState {}

final class getProductLoading extends ProductState {}

final class getProductSuccess extends ProductState {
  final List<ProductEntity> products;

  getProductSuccess({required this.products});
}

final class getProductError extends ProductState {}
final class searchProductLoading extends ProductState {}

final class searchProductSuccess extends ProductState {
  final List<ProductEntity> products;

  searchProductSuccess({required this.products});
}

final class searchProductError extends ProductState {
  final String message;
  searchProductError({required this.message});
}

final class latestArrrivalloading extends ProductState {}

final class latestArrrivalSuccess extends ProductState {
  final List<ProductEntity> products;
  latestArrrivalSuccess({required this.products});
}

final class latestArrrivalError extends ProductState {}
final class GetFavoritesSuccessState extends ProductState {
  final List<ProductEntity> favorites;
  GetFavoritesSuccessState({required this.favorites});
}

final class   GetFavoritesFailureState extends ProductState {
  final String error;

  GetFavoritesFailureState({required this.error});
}
final class   GetFavoritesLoadingState extends ProductState {}
final class isfavoritechangestate extends ProductState {}class AddFavoriteSuccess extends ProductState {
  final String productId;
  AddFavoriteSuccess(this.productId);
}
class AddFavoriteFailure extends ProductState {
  final String error;
  AddFavoriteFailure(this.error);
}

class DeleteFavoriteSuccess extends ProductState {
  final String productId;
  DeleteFavoriteSuccess(this.productId);
}
class DeleteFavoriteFailure extends ProductState {
  final String error;
  DeleteFavoriteFailure(this.error);
}