import 'package:shop_app/feature/auth/domain/repository/repo.dart';

class Signoutusecase {
  final Repo repository;

  Signoutusecase(this.repository);

  Future<void> call() async {
    return await repository.signout();
  } 
}