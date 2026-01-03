import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';
import 'package:shop_app/feature/profile/domain/repository/profile_repo.dart';

class UpdateProfileUsecase {
  final ProfileRepo repository;

  UpdateProfileUsecase({required this.repository});

  Future<UserEntity> execute({
    required String userId,
    required String name,
    required String email,
    String? phone,
    String? imageUrl,
  }) async {
    return await repository.updateProfile(
      userId: userId,
      name: name,
      email: email,
      phone: phone,
      imageUrl: imageUrl,
    );
  }
}