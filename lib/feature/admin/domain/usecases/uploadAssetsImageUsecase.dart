
import 'package:shop_app/feature/admin/domain/repo/productsRepo.dart';

class Uploadassetsimageusecase {
    final Productsrepo repository;

  Uploadassetsimageusecase( this.repository);
  Future<String?> call({required String assetPath}) async {
    return await repository.uploadAssetsImageToSupabase(assetPath: assetPath);
  }
}