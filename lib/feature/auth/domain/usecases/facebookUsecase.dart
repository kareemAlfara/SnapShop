import 'package:dartz/dartz.dart';
import 'package:shop_app/core/utils/failures.dart';
import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';
import 'package:shop_app/feature/auth/domain/repository/repo.dart';

class Facebookusecase {
  final Repo repo;
  Facebookusecase(this.repo);
   Future<Either<Failure, UserEntity>> call() => repo.signinWithFacebook();
}