import 'dart:io';
import 'package:shop_app/feature/auth/data/mapping/mapper.dart';
import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';
import 'package:shop_app/feature/profile/data/datasources/profile_remote_data_source.dart';
import 'package:shop_app/feature/profile/domain/repository/profile_repo.dart';

class ProfileRepoImpl implements ProfileRepo {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepoImpl({required this.remoteDataSource});

  @override
  Future<String?> uploadImage(File imageFile) async {
    try {
      final imageUrl = await remoteDataSource.uploadProfileImage(imageFile);
      return imageUrl;
    } catch (e) {
      print('Error in uploadImage: $e');
      return null;
    }
  }

  @override
  Future<UserEntity> updateProfile({
    required String userId,
    required String name,
    required String email,
    String? phone,
    String? imageUrl,
  }) async {
    final model = await remoteDataSource.updateUserProfile(
      userId: userId,
      name: name,
      email: email,
      phone: phone,
      imageUrl: imageUrl,
    );
    
    return Mapper.toEntity(model);
  }

  @override
  Future<UserEntity> getUserData(String userId) async {
    final model = await remoteDataSource.getUserData(userId);
    return Mapper.toEntity(model);
  }
}
