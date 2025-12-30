// lib/core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:shop_app/feature/profile/data/datasources/profile_remote_data_source.dart';
import 'package:shop_app/feature/profile/data/repository/profile_repo_impl.dart';
import 'package:shop_app/feature/profile/domain/repository/profile_repo.dart';
import 'package:shop_app/feature/profile/domain/usecases/get_user_data_usecase.dart';
import 'package:shop_app/feature/profile/domain/usecases/update_profile_usecase.dart';
import 'package:shop_app/feature/profile/domain/usecases/upload_image_usecase.dart';
import 'package:shop_app/feature/profile/presentation/cubit/profile_cubit.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> setupDependencies() async {
  // Setup profile dependencies
  _setupProfileDependencies();
  
  // Add other feature dependencies here in the future
  // _setupAuthDependencies();
  // _setupProductDependencies();
}

/// Setup Profile Feature Dependencies
void _setupProfileDependencies() {
  // Data Sources
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(),
  );

  // Repositories
  getIt.registerLazySingleton<ProfileRepo>(
    () => ProfileRepoImpl(
      remoteDataSource: getIt<ProfileRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<UploadImageUsecase>(
    () => UploadImageUsecase(
      repository: getIt<ProfileRepo>(),
    ),
  );

  getIt.registerLazySingleton<UpdateProfileUsecase>(
    () => UpdateProfileUsecase(
      repository: getIt<ProfileRepo>(),
    ),
  );

  getIt.registerLazySingleton<GetUserDataUsecase>(
    () => GetUserDataUsecase(
      repository: getIt<ProfileRepo>(),
    ),
  );

  // Cubit (Factory - new instance each time)
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      uploadImageUsecase: getIt<UploadImageUsecase>(),
      updateProfileUsecase: getIt<UpdateProfileUsecase>(),
      getUserDataUsecase: getIt<GetUserDataUsecase>(),
    ),
  );
}

// Example: If you want to add Auth dependencies later
// void _setupAuthDependencies() {
//   getIt.registerLazySingleton<AuthRemoteDataSource>(
//     () => AuthRemoteDataSource(),
//   );
//   
//   getIt.registerLazySingleton<AuthRepo>(
//     () => AuthRepoImpl(
//       remoteDataSource: getIt<AuthRemoteDataSource>(),
//     ),
//   );
// }

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}