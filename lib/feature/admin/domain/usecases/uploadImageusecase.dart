import 'dart:io';
import 'package:shop_app/feature/admin/domain/repo/productsRepo.dart';

class Uploadimageusecase {
    final Productsrepo repository;

  Uploadimageusecase( this.repository);
  Future<String?> call({required File file}) async {
    return await repository.uploadImageToSupabase(file: file);
  }
}