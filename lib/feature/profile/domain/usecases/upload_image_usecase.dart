import 'dart:io';
import 'package:shop_app/feature/profile/domain/repository/profile_repo.dart';

class UploadImageUsecase {
  final ProfileRepo repository;

  UploadImageUsecase({required this.repository});

  Future<String?> execute(File imageFile) async {
    return await repository.uploadImage(imageFile);
  }
}
