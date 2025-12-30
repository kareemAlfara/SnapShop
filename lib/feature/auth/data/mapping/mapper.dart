import 'package:shop_app/feature/auth/data/models/userModel.dart';
import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';

class Mapper {
  static Usermodel fromentity(userentity entity) =>
      Usermodel(name: entity.name, email: entity.email, id: entity.id, image: '', phone: entity.phone);
  static userentity toentity(Usermodel model) =>
      userentity(name: model.name, email: model.email, id: model.id, image: '', phone: model.phone);
}
