
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:shop_app/core/utils/failures.dart';
import 'package:shop_app/feature/auth/domain/repository/repo.dart' ;

class Uploaduserimageusecase {
  final Repo repository;
  Uploaduserimageusecase(this.repository);
   Future<Either<Failure, String?>> call(File file) => repository.uploadImageToSupabase(file);
}