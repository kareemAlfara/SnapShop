import 'package:shop_app/feature/mainview/data/mapping/reviewMapper.dart';
import 'package:shop_app/feature/mainview/data/models/ProductModel.dart';
import 'package:shop_app/feature/mainview/data/models/favoritModel.dart';
import 'package:shop_app/feature/mainview/domain/entities/favoritEntity.dart';
import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';
import '../../domain/helper/recent_products_helper.dart';

class productmapper {
  static List<ProductEntity> toEntity(List<Productmodel> productmodel) {
    return productmodel
        .map(
          (model) => ProductEntity(
            favorites: productmapper.toListFavoritesEntity(model.favorites),
            reviews: ReviewMapper.toListEntity(model.reviews), // ⬅️ Added
            id: model.id,
            title: model.title,
            price: model.price,
            category: model.category,
            description: model.description,
            image: model.image,
            quantity: model.quantity,
            avgRating: model.avgRating, // ⬅️ Added
          ),
        )
        .toList();
  }

  static ProductEntity toSingleEntity(Productmodel model) {
    return ProductEntity(
      favorites: productmapper.toListFavoritesEntity(model.favorites),
      reviews: ReviewMapper.toListEntity(model.reviews),
      id: model.id,
      title: model.title,
      price: model.price,
      category: model.category,
      description: model.description,
      image: model.image,
      quantity: model.quantity,
      avgRating: model.avgRating,
    );
  }

  static fromEntity(ProductEntity entity) {
    return Productmodel(
      favorites: [],
      reviews: [],
      id: entity.id,
      title: entity.title,
      price: entity.price,
      category: entity.category,
      description: entity.description,
      image: entity.image,
      quantity: entity.quantity,
    
    );
  }

  static List<favoritEntity> toListFavoritesEntity(List<Favoritmodel> model) {
    return model
        .map(
          (mod) => favoritEntity(
            isfavorite: mod.isfavorite,
            product_id: mod.product_id,
            user_id: mod.user_id,
          ),
        )
        .toList();
  }

  static favoritEntity toFavoritesEntity(Favoritmodel model) {
    return favoritEntity(
      isfavorite: model.isfavorite,
      product_id: model.product_id,
      user_id: model.user_id,
    );
  }

  List<ProductEntity> getRecentEntities() {
    final models = RecentProductsHelper.getRecentProducts();
    return productmapper.toEntity(models);
  }
}