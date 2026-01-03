import 'dart:io';

import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';

abstract class ProfileRepo {
  Future<String?> uploadImage(File imageFile);
  
  Future<UserEntity> updateProfile({
    required String userId,
    required String name,
    required String email,
    String? phone,
    String? imageUrl,
  });
  
  Future<UserEntity> getUserData(String userId);
}