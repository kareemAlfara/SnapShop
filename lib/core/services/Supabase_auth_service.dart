import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shop_app/core/errors/authFaulier.dart';
import 'package:shop_app/feature/auth/data/models/userModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  Future<User?> Signup({
    required String email,
    required String password,
  }) async {
    try {
      SupabaseClient supabase = Supabase.instance.client;
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      return response.user!;
    } on AuthException catch (e) {
      final message = handleAuthError(e);
      Fluttertoast.showToast(msg: message, backgroundColor: Colors.red);
      return null;
    } catch (e) {
      // TODO
      log(
        "Exception in FirebaseAuthService.createUserWithEmailAndPassword: ${e.toString()}",
      );
      return null;
    }
  }
Future<User?> Signin({
  required String email,
  required String password,
}) async {
  try {
    SupabaseClient supabase = Supabase.instance.client;
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    // ✅ تحقق من response
    if (response.user == null) {
      throw AuthException('Sign in failed: No user returned');
    }
    
    return response.user;
  } on AuthException catch (e) {
    final message = handleAuthError(e);
    Fluttertoast.showToast(msg: message, backgroundColor: Colors.red);
    throw e; // ✅ throw بدل return null
  } catch (e) {
    log("Exception in Signin: ${e.toString()}");
    throw Exception('Sign in failed: $e'); // ✅ throw
  }
}
  // Future<User?> Signin({
  //   required String email,
  //   required String password,
  // }) async {
  //   try {
  //     SupabaseClient supabase = Supabase.instance.client;
  //     final response = await Supabase.instance.client.auth.signInWithPassword(
  //       email: email,
  //       password: password,
  //     );

  //     return response.user!;
  //   } on AuthException catch (e) {
  //     final message = handleAuthError(e);
  //     Fluttertoast.showToast(msg: message, backgroundColor: Colors.red);
  //     return null;
  //   } catch (e) {
  //     // TODO
  //     log(
  //       "Exception in FirebaseAuthService.createUserWithEmailAndPassword: ${e.toString()}",
  //     );
  //     return null;
  //   }
  // }

  final GoogleSignIn googleSignIn = GoogleSignIn(
    serverClientId:
        '1038966682534-8f6kpcl2hfkp9o0p3lkb7v86deblaaj8.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );
  Future<User> googleSigninuser() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');

    final googleAuth = await googleUser.authentication;
    if (googleAuth.idToken == null) throw Exception('No ID Token from Google');
    final AuthResponse response = await Supabase.instance.client.auth
        .signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: googleAuth.idToken!,
          accessToken: googleAuth.accessToken,
        );
    final user = response.user!;
    return user;
  }

  Future<User> facebookuser() async {
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.facebook,
      redirectTo: 'https://kbshmetpchppzivoynly.supabase.co/auth/v1/callback',
    );
      User? user;

    // Wait and check for session multiple times
    for (int i = 0; i < 30; i++) {
      await Future.delayed(Duration(milliseconds: 500));

      final session = Supabase.instance.client.auth.currentSession;
      if (session != null && session.user != null) {
        user = session.user;
        final userEntity = Usermodel(
          id: user.id,

          email: user.email ?? '',
image: "",
          name:
              user.userMetadata?['full_name'] ??
              user.userMetadata?['name'] ??
              user.email?.split('@')[0] ??
              'Facebook User',
          phone: user.userMetadata?['phone'] ?? '',
        );
      }
    }
        return user!;

  }
}
