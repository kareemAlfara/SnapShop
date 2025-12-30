import 'package:shop_app/feature/mainview/data/models/reviewModel.dart';
import 'package:shop_app/feature/mainview/domain/entities/review_entity.dart';

class ReviewMapper {
  // Model → Entity
  static ReviewEntity toEntity(ReviewModel model) {
    return ReviewEntity(
      id: model.id,
      productId: model.productId,
      userId: model.userId,
      name: model.name,
      descriptionMessage: model.descriptionMessage,
      ratingCount: model.ratingCount,
      createdAt: model.createdAt,
    );
  }

  // List<Model> → List<Entity>
  static List<ReviewEntity> toListEntity(List<ReviewModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  // Entity → Model
  static ReviewModel fromEntity(ReviewEntity entity) {
    return ReviewModel(
      id: entity.id,
      productId: entity.productId,
      userId: entity.userId,
      name: entity.name,
      descriptionMessage: entity.descriptionMessage,
      ratingCount: entity.ratingCount,
      createdAt: entity.createdAt,
    );
  }

  // List<Entity> → List<Model>
  static List<ReviewModel> fromListEntity(List<ReviewEntity> entities) {
    return entities.map((entity) => fromEntity(entity)).toList();
  }
}