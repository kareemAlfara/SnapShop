import 'package:dartz/dartz.dart';
import 'package:shop_app/core/utils/failures.dart';
import 'package:shop_app/feature/auth/domain/repository/repo.dart';

class Signoutusecase {
  final Repo repository;

  Signoutusecase(this.repository);

   Future<Either<Failure, void>> call() async {
    return await repository.signout();
  } 
}