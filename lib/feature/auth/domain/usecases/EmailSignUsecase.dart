import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';
import 'package:shop_app/feature/auth/domain/repository/repo.dart';

class Emailsigninusecase {
  final Repo repo;
  Emailsigninusecase({required this.repo});

  Future<userentity> call({required String email, required String password}) =>
      repo.Signin(email: email, password: password);
}

class Emailsignupusecase {
  final Repo repo;
  Emailsignupusecase({required this.repo});

  Future<userentity> call({
    required String email,
    required String password,
    required String image,
    required String name,
    required String phone,
  }) => repo.Signup(
    email: email,
    password: password,
    name: name,
    phone: phone,
    image: image,
  );
}
