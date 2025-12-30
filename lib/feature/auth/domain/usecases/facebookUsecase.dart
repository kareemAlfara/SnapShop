import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';
import 'package:shop_app/feature/auth/domain/repository/repo.dart';

class Facebookusecase {
  final Repo repo;
  Facebookusecase(this.repo);
  Future<userentity> call() => repo.signinWithFacebook();
}