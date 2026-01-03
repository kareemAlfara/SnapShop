import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shop_app/core/di/injection.dart';
import 'package:shop_app/feature/auth/data/auth_local_data_source.dart';
import 'package:shop_app/feature/auth/data/auth_remote_data_source.dart';
import 'package:shop_app/feature/auth/data/repository/repo_impl.dart';
import 'package:shop_app/feature/auth/domain/repository/repo.dart';
import 'package:shop_app/feature/auth/domain/usecases/EmailSignUsecase.dart';
import 'package:shop_app/feature/auth/domain/usecases/getCurrentUserFromPrefs.dart';
import 'package:shop_app/feature/auth/domain/usecases/googleUsecase.dart';
import 'package:shop_app/feature/auth/domain/usecases/signoutEntity.dart';
import 'package:shop_app/feature/auth/domain/usecases/uploadImageusecase.dart';
import 'package:shop_app/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// final getIt = GetIt.instance;

Future<void> setupAuthDependencies() async {
  // ========================================
  // External Dependencies
  // ========================================
  final supabase = Supabase.instance.client;
  getIt.registerLazySingleton<SupabaseClient>(() => supabase);

  final googleSignIn = GoogleSignIn(
    serverClientId:
        '1038966682534-8f6kpcl2hfkp9o0p3lkb7v86deblaaj8.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );
  getIt.registerLazySingleton<GoogleSignIn>(() => googleSignIn);

  // ========================================
  // Data Sources
  // ========================================
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(),
  );

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(
      supabase: getIt<SupabaseClient>(),
      googleSignIn: getIt<GoogleSignIn>(),
    ),
  );

  // ========================================
  // Repository
  // ========================================
  getIt.registerLazySingleton<Repo>(
    () => RepoImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  // ========================================
  // Use Cases
  // ========================================
  getIt.registerLazySingleton(
    () => Emailsigninusecase(repo:  getIt<Repo>()),
  );

  getIt.registerLazySingleton(
    () => Emailsignupusecase(repo:  getIt<Repo>()),
  );

  getIt.registerLazySingleton(
    () => Googleusecase(getIt<Repo>()),
  );

  getIt.registerLazySingleton(
    () => Signoutusecase(getIt<Repo>()),
  );

  getIt.registerLazySingleton(
    () => Getcurrentuserfromprefs( repo: getIt<Repo>(),),
  );

  getIt.registerLazySingleton(
    () => Uploaduserimageusecase(getIt<Repo>()),
  );

  // ========================================
  // Cubit
  // ========================================
  getIt.registerFactory(
    () => AuthCubit(
      signInUseCase: getIt<Emailsigninusecase>(),
      signUpUseCase: getIt<Emailsignupusecase>(),
      signInWithGoogleUseCase: getIt<Googleusecase>(),
      signOutUseCase: getIt<Signoutusecase>(),
      getCurrentUserUseCase: getIt<Getcurrentuserfromprefs>(),
      uploadImageUseCase: getIt<Uploaduserimageusecase>(),
    ),
  );

  print('✅ Auth dependencies initialized successfully');
}