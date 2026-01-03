import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';
import 'package:shop_app/feature/mainview/domain/usecases/addfavoriteusecase.dart';
import 'package:shop_app/feature/mainview/domain/usecases/getproductsusecase.dart';
import 'package:shop_app/feature/mainview/domain/usecases/latestusecase.dart';
import 'package:shop_app/feature/mainview/domain/usecases/searchProductUsecase.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final Getproductsusecase getproductsusecase;
  final Latestusecase latestArrivalusecase;
  final AddFavoriteUsecase addFavoriteUsecase;

  final DeleteFavoriteUsecase deleteFavoriteUsecase;

  final GetFavoriteProductsUsecase getFavoriteProductsUsecase;

  final Searchproductusecase searchproductusecase;

  ProductCubit(
    this.getproductsusecase,
    this.searchproductusecase,
    this.latestArrivalusecase,
    this.addFavoriteUsecase,
    this.deleteFavoriteUsecase,
    this.getFavoriteProductsUsecase,
  ) : super(ProductInitial());
  static ProductCubit get(context) => BlocProvider.of(context);
  List<ProductEntity> products = [];
  var searchController = TextEditingController();
  var category;
  getproducts() async {
    try {
      emit(getProductLoading());
      products = await getproductsusecase.call();
      emit(getProductSuccess(products: products));
    } on Exception catch (e) {
      log(e.toString());
      emit(getProductError());
      // TODO
    }
  }

  Timer? _debounce;
  List<ProductEntity> searchlist = [];

  searchProducts(String query) async {
    // إلغاء أي مؤقت شغال
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        emit(searchProductLoading());
        searchlist = await searchproductusecase.call(query);
        emit(searchProductSuccess(products: searchlist));
      } on Exception catch (e) {
        log(e.toString());
        emit(searchProductError(message: e.toString()));
        // TODO
      }
    });
  }

  List<ProductEntity> latestproducts = [];
  latestarrval() async {
    try {
      emit(latestArrrivalloading());
      latestproducts = await latestArrivalusecase.call();
      emit(latestArrrivalSuccess(products: latestproducts));
    } on Exception catch (e) {
      log(e.toString());
      emit(latestArrrivalError());
      // TODO
    }
  }

  final Map<String, bool> _favorites = {};
  bool isFavorite(String productId) => _favorites[productId] ?? false;

  Future<void> addFavorite({
    required String productId,
    required String userId,
  }) async {
    try {
      await addFavoriteUsecase(productId: productId, userId: userId);
      _favorites[productId] = true;
      emit(AddFavoriteSuccess(productId));
    } catch (e) {
      emit(AddFavoriteFailure(e.toString()));
    }
  }

  Future<void> deleteFavorite({
    required String productId,
    required String userId,
  }) async {
    try {
      await deleteFavoriteUsecase(productId: productId, userId: userId);
      _favorites[productId] = false;
      emit(DeleteFavoriteSuccess(productId));
    } catch (e) {
      emit(DeleteFavoriteFailure(e.toString()));
    }
  }
  List<ProductEntity> favorites = [];
  Future<void> GetFavorites(String userId) async {
    try {
      emit(GetFavoritesLoadingState());
      favorites = await getFavoriteProductsUsecase.call(userId);
      emit(GetFavoritesSuccessState(favorites: favorites));
    } catch (e) {
      emit(GetFavoritesFailureState(error: e.toString()));
    }
  }

  Future<void> loadFavorites(String userId) async {
    emit(GetFavoritesLoadingState());
    try {
    
      final favorites = await getFavoriteProductsUsecase(userId);
      _favorites.clear();
      for (final p in favorites) {
        _favorites[p.id] = true;
      }
      emit(GetFavoritesSuccessState(favorites: favorites));
    } catch (e) {
      emit(GetFavoritesFailureState(error: e.toString()));
    }
  }

  Future<void> toggleFavorite({
    required String productId,
    required String userId,
  }) async {
    // If already favorite → remove it, otherwise → add it
    isFavorite(productId)
        ? await deleteFavorite(productId: productId, userId: userId)
        : await addFavorite(productId: productId, userId: userId);
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
