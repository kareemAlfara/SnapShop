import 'dart:io';
import 'package:shop_app/feature/auth/data/models/userModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRemoteDataSource {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Upload profile image to Supabase Storage
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final fileName = 'profile_$userId${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage
          .from('user_images')
          .upload(fileName, imageFile);

      final publicUrl = supabase.storage
          .from('user_images')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Update user profile in database
  Future<UserModel> updateUserProfile({
    required String userId,
    required String name,
    required String email,
    String? phone,
    String? imageUrl,
  }) async {
    try {
      final updateData = {
        'name': name,
        'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (imageUrl != null) 'image': imageUrl,
      };

      await supabase
          .from('users')
          .update(updateData)
          .eq('uid', userId);

      // Fetch updated user data
      final userRow = await supabase
          .from('users')
          .select()
          .eq('uid', userId)
          .single();

      return UserModel.fromJson(userRow);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Get user data from database
  Future<UserModel> getUserData(String userId) async {
    try {
      final userRow = await supabase
          .from('users')
          .select()
          .eq('uid', userId)
          .single();

      return UserModel.fromJson(userRow);
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }
}

