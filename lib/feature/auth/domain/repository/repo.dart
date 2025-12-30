import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';

abstract class Repo {
  Future<userentity> Signup({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String image
  });
  Future<userentity> Signin({required String email, required String password});
  Future<userentity> signinWithGoogle();
  Future<userentity> signinWithFacebook();

  Future<void> signout();
  Future<userentity?> getCurrentUserFromPrefs();
    Future<String?> uploadImageToSupabase(File file);

  
}
