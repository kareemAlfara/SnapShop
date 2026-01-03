// ========================================
// 📁 lib/feature/auth/data/repository/repo_impl.dart
// ========================================
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:shop_app/core/utils/failures.dart';
import 'package:shop_app/feature/auth/data/auth_remote_data_source.dart';
import 'package:shop_app/feature/auth/data/auth_local_data_source.dart';
import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';
import 'package:shop_app/feature/auth/domain/repository/repo.dart';

class RepoImpl implements Repo {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  RepoImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ========================================
  // ✅ SIGNUP (lowercase - matches interface)
  // ========================================
  @override
  Future<Either<Failure, UserEntity>> signup({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String image,
  }) async {
    try {
      final model = await remoteDataSource.Signup(
        email: email,
        password: password,
        name: name,
        phone: phone,
        image: image,
      );
 await localDataSource.saveUser(model);
      // Convert UserModel to UserEntity
      final entity = UserEntity(
        id: model.id,
        email: model.email,
        name: model.name,
        image: model.image,
        phone: model.phone,
        userType: model.userType,
      );

      // Save to local storage
      await localDataSource.saveUser(model);

      return Right(entity);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ========================================
  // ✅ SIGNIN (lowercase - matches interface)
  // ========================================
  @override
  Future<Either<Failure, UserEntity>> signin({
    required String email,
    required String password,
  }) async {
    try {
      final model = await remoteDataSource.Signin(
        email: email,
        password: password,
      );
 await localDataSource.saveUser(model);

      // Convert UserModel to UserEntity
      final entity = UserEntity(
        id: model.id,
        email: model.email,
        name: model.name,
        image: model.image,
        phone: model.phone,
        userType: model.userType,
      );

      // Save to local storage
      await localDataSource.saveUser(model);

      return Right(entity);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ========================================
  // ✅ GOOGLE SIGN IN
  // ========================================
  @override
  Future<Either<Failure, UserEntity>> signinWithGoogle() async {
    try {
      final model = await remoteDataSource.signinWithGoogle();
 await localDataSource.saveUser(model);

      // Convert UserModel to UserEntity
      final entity = UserEntity(
        id: model.id,
        email: model.email,
        name: model.name,
        image: model.image,
        phone: model.phone,
        userType: model.userType,
      );

      // Save to local storage
      await localDataSource.saveUser(model);

      return Right(entity);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ========================================
  // ✅ FACEBOOK SIGN IN
  // ========================================
  @override
  Future<Either<Failure, UserEntity>> signinWithFacebook() async {
    try {
      final model = await remoteDataSource.signinWithFacebook();
 await localDataSource.saveUser(model);

      // Convert UserModel to UserEntity
      final entity = UserEntity(
        id: model.id,
        email: model.email,
        name: model.name,
        image: model.image,
        phone: model.phone,
        userType: model.userType,
      );

      // Save to local storage
      await localDataSource.saveUser(model);

      return Right(entity);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ========================================
  // ✅ IMAGE UPLOAD
  // ========================================
  @override
  Future<Either<Failure, String>> uploadImageToSupabase(File file) async {
    try {
      final fileName = await remoteDataSource.uploadImageToSupabase(file);
      if (fileName == null) {
        return Left(ServerFailure(message: 'Failed to upload image'));
      }
      
      // Return the full URL
      final fullUrl = 'https://kbshmetpchppzivoynly.supabase.co/storage/v1/object/public/user_images/uploads/$fileName';
      return Right(fullUrl);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ========================================
  // ✅ SIGN OUT
  // ========================================
  @override
  Future<Either<Failure, void>> signout() async {
    try {
      await remoteDataSource.signOut();
      await localDataSource.clearUser();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ========================================
  // ✅ GET CURRENT USER FROM PREFS
  // ========================================
  @override
  Future<Either<Failure, UserEntity?>> getCurrentUserFromPrefs() async {
    try {
      final model = await localDataSource.getUser();
      if (model == null) return const Right(null);

      // Convert UserModel to UserEntity
      final entity = UserEntity(
        id: model.id,
        email: model.email,
        name: model.name,
        image: model.image,
        phone: model.phone,
        userType: model.userType,
      );

      return Right(entity);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}