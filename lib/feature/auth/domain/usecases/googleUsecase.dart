import 'package:dartz/dartz.dart';
import 'package:shop_app/core/utils/failures.dart';
import 'package:shop_app/feature/auth/domain/repository/repo.dart';

import '../entities/userEntity.dart';

class Googleusecase {
  final Repo repo;

  Googleusecase(this.repo);

   Future<Either<Failure, UserEntity>> call() => repo.signinWithGoogle();
}