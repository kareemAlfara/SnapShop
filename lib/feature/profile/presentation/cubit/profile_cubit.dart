import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';
import 'package:shop_app/feature/profile/domain/usecases/get_user_data_usecase.dart';
import 'package:shop_app/feature/profile/domain/usecases/update_profile_usecase.dart';
import 'package:shop_app/feature/profile/domain/usecases/upload_image_usecase.dart';
import 'package:shop_app/feature/profile/presentation/cubit/profile_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UploadImageUsecase uploadImageUsecase;
  final UpdateProfileUsecase updateProfileUsecase;
  final GetUserDataUsecase getUserDataUsecase;

  ProfileCubit({
    required this.uploadImageUsecase,
    required this.updateProfileUsecase,
    required this.getUserDataUsecase,
  }) : super(ProfileInitial());

  static ProfileCubit get(BuildContext context) => BlocProvider.of(context);

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  String? currentImageUrl;
  File? imageFile;
  String? currentUserId;

  /// Load user data
  Future<void> loadUserData({required userentity user}) async {
    emit(ProfileLoading());

    try {
      currentUserId = user.id;
      
      // Initialize controllers with passed user data
      nameController.text = user.name ?? '';
      emailController.text = user.email ?? '';
      phoneController.text = user.phone ?? '';
      currentImageUrl = user.image;

      // Try to fetch latest data from Supabase
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final latestUser = await getUserDataUsecase.execute(userId);
        
        nameController.text = latestUser.name ?? user.name ?? '';
        emailController.text = latestUser.email ?? user.email ?? '';
        phoneController.text = latestUser.phone ?? user.phone ?? '';
        currentImageUrl = latestUser.image ?? user.image;
        currentUserId = latestUser.id;
      }

      emit(ProfileLoaded());
    } catch (e) {
      print('Error loading user data: $e');
      // Even if Supabase fails, we still have the initial user data
      emit(ProfileError(error: 'Failed to load user data'));
    }
  }

  /// Pick image from camera or gallery
  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
        emit(ImagePicked());
      }
    } catch (e) {
      print('Error picking image: $e');
      emit(ProfileError(error: 'Failed to pick image'));
    }
  }

  /// Upload image to storage
  Future<String?> uploadImage() async {
    if (imageFile == null) return currentImageUrl;

    emit(ImageUploading());

    try {
      final publicUrl = await uploadImageUsecase.execute(imageFile!);
      emit(ImageUploaded());
      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      emit(ProfileError(error: 'Failed to upload image'));
      return null;
    }
  }

  /// Update user profile
  Future<void> updateProfile() async {
    emit(ProfileUpdating());

    try {
      final userId = currentUserId ?? Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        emit(ProfileError(error: 'User not logged in'));
        return;
      }

      // Upload image if changed
      String? imageUrl = await uploadImage();

      // Update profile
      final updatedUser = await updateProfileUsecase.execute(
        userId: userId,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        imageUrl: imageUrl,
      );

      currentImageUrl = updatedUser.image;
      emit(ProfileUpdateSuccess(user: updatedUser));
    } catch (e) {
      print('Error updating profile: $e');
      emit(ProfileError(error: 'Failed to update profile'));
    }
  }

  /// Reset selected image
  void resetImage() {
    imageFile = null;
    emit(ProfileLoaded());
  }

  @override
  Future<void> close() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    return super.close();
  }
}