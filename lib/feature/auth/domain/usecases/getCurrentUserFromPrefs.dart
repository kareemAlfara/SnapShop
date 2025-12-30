import 'package:shop_app/feature/auth/domain/repository/repo.dart';

class Getcurrentuserfromprefs {
  final Repo repo;

  Getcurrentuserfromprefs({required this.repo});
  call() {
    return repo.getCurrentUserFromPrefs();
  }
}
