import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';
import 'package:shop_app/feature/profile/domain/repository/profile_repo.dart';

class GetUserDataUsecase {
  final ProfileRepo repository;

  GetUserDataUsecase({required this.repository});

  Future<userentity> execute(String userId) async {
    return await repository.getUserData(userId);
  }
}

