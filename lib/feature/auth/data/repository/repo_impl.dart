import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shop_app/core/services/Shared_preferences.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/feature/auth/data/auth_local_data_source.dart';
import 'package:shop_app/feature/auth/data/auth_remote_data_source.dart';
import 'package:shop_app/feature/auth/data/mapping/mapper.dart';
import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';
import 'package:shop_app/feature/auth/domain/repository/repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RepoImpl extends Repo {
  @override
  Future<userentity> Signup({
    required String email,
    required String password,
    required String name,
    required String phone,
required String image  }) async {
    final model = await AuthRemoteDataSource().Signup(
      email: email,
      password: password,
      name: name,
      phone: phone,
      image: image
      

    );
    AuthLocalDataSource().saveUser(model);
    return Mapper.toentity(model);
  }

  @override
  Future<userentity> Signin({
    required String email,
    required String password,
  }) async {
    final model = await AuthRemoteDataSource().Signin(
      email: email,
      password: password,
    );
    AuthLocalDataSource().saveUser(model);
    return Mapper.toentity(model);
  }

  Future<userentity> signinWithGoogle() async {
    final model = await AuthRemoteDataSource().signinWithGoogle();
    AuthLocalDataSource().saveUser(model);
    return Mapper.toentity(model);
  }

  final SupabaseClient _supabase = Supabase.instance.client;
  final GoogleSignIn googleSignIn = GoogleSignIn(
    serverClientId:
        '1038966682534-8f6kpcl2hfkp9o0p3lkb7v86deblaaj8.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );
  StreamSubscription<List<Map<String, dynamic>>>? _usersSubscription;
  Future<void> signout() async {
    await Future.wait([googleSignIn.signOut(), _supabase.auth.signOut()]);
    await _usersSubscription?.cancel();
    _usersSubscription = null;

    await Prefs.setString("id", "");
    await Prefs.setString("name", "");
    log('User signed out and preferences cleared');
    uid = null;
    await Supabase.instance.client.auth.signOut();
  }
  Future<userentity> signinWithFacebook() async {
    final model = await AuthRemoteDataSource().signinWithFacebook();
    AuthLocalDataSource().saveUser(model);
    return Mapper.toentity(model);
  }
  Future<userentity?> getCurrentUserFromPrefs() async {
  final localId = Prefs.getString('id');
  if (localId.isEmpty) return null;

  final userRow = await Supabase.instance.client
      .from('users')
      .select()
      .eq('uid', localId)
      .maybeSingle();

  if (userRow == null) return null;

  return userentity(
    id: userRow['uid'],
    image: userRow['image'],
    email: userRow['email'],
    name: userRow['name'],
    phone: userRow['phone'],
  );
}
  @override
  Future<String?> uploadImageToSupabase(File file) async {
  ;
  final fileName = await AuthRemoteDataSource().uploadImageToSupabase(file);

    final String publicUrl =
        'https://kbshmetpchppzivoynly.supabase.co/storage/v1/object/public/user_images/uploads/$fileName';

    return publicUrl;
  }
}
