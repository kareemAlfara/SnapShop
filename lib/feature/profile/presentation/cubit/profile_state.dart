import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {}

class ImagePicked extends ProfileState {}

class ImageUploading extends ProfileState {}

class ImageUploaded extends ProfileState {}

class ProfileUpdating extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final userentity user;
  ProfileUpdateSuccess({required this.user});
}

class ProfileError extends ProfileState {
  final String error;
  ProfileError({required this.error});
}
