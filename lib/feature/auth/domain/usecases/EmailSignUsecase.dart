import 'package:dartz/dartz.dart';
import 'package:shop_app/core/utils/failures.dart';
import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';
import 'package:shop_app/feature/auth/domain/repository/repo.dart';

class Emailsigninusecase {
  final Repo repo;
  Emailsigninusecase({required this.repo});

 Future<Either<Failure, UserEntity>> call({required String email, required String password}) =>
      repo.signin(email: email, password: password);
}

class Emailsignupusecase {
  final Repo repo;
  Emailsignupusecase({required this.repo});

   Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String image,
    required String name,
    required String phone,
  }) => repo.signup(
    email: email,
    password: password,
    name: name,
    phone: phone,

    image: image,
  );
}
