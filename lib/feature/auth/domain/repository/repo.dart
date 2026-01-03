// ========================================
// 📁 lib/feature/auth/domain/repository/repo.dart
// ========================================
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:shop_app/core/utils/failures.dart';
import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';

abstract class Repo {
  Future<Either<Failure, UserEntity>> signup({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String image,
  });

  Future<Either<Failure, UserEntity>> signin({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signinWithGoogle();
  
  Future<Either<Failure, UserEntity>> signinWithFacebook();

  Future<Either<Failure, void>> signout();

  Future<Either<Failure, UserEntity?>> getCurrentUserFromPrefs();

  Future<Either<Failure, String>> uploadImageToSupabase(File file);
}