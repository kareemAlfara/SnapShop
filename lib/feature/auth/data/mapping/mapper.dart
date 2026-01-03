import 'package:shop_app/feature/auth/data/models/userModel.dart';
import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';

class Mapper {
  static UserEntity toEntity(UserModel model) {
    return UserEntity(
      id: model.id,
      email: model.email,
      name: model.name,
      image: model.image,
      phone: model.phone,
      userType: model.userType,
    );
  }
}
