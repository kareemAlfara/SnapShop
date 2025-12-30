
import 'dart:io';

import 'package:shop_app/feature/auth/domain/repository/repo.dart' ;

class Uploaduserimageusecase {
  final Repo repository;
  Uploaduserimageusecase(this.repository);
  Future<String?> call(File file) => repository.uploadImageToSupabase(file);
}