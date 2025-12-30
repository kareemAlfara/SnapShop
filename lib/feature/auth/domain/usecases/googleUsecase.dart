import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';
import 'package:shop_app/feature/auth/domain/repository/repo.dart';

class Googleusecase {
  final Repo repo;

  Googleusecase(this.repo);

  Future<userentity> call() => repo.signinWithGoogle();
}