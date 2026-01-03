// ========================================
// 📁 lib/core/services/Supabase_auth_service.dart
// ========================================
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shop_app/core/errors/authFaulier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final supabase = Supabase.instance.client;

  // ========================================
  // ✅ SIGNUP
  // ========================================
  Future<User?> Signup({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('Signup failed: No user returned');
      }

      return response.user;
    } on AuthException catch (e) {
      final message = handleAuthError(e);
      Fluttertoast.showToast(msg: message, backgroundColor: Colors.red);
      throw e;
    } catch (e) {
      log("Exception in Signup: ${e.toString()}");
      throw Exception('Signup failed: $e');
    }
  }

  // ========================================
  // ✅ SIGNIN
  // ========================================
  Future<User?> Signin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('Sign in failed: No user returned');
      }

      return response.user;
    } on AuthException catch (e) {
      final message = handleAuthError(e);
      Fluttertoast.showToast(msg: message, backgroundColor: Colors.red);
      throw e;
    } catch (e) {
      log("Exception in Signin: ${e.toString()}");
      throw Exception('Sign in failed: $e');
    }
  }

  // ========================================
  // ✅ GOOGLE SIGN IN
  // ========================================
  final GoogleSignIn googleSignIn = GoogleSignIn(
    serverClientId:
        '1038966682534-8f6kpcl2hfkp9o0p3lkb7v86deblaaj8.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  Future<User> googleSigninuser() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign-in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      
      if (googleAuth.idToken == null) {
        throw Exception('No ID Token from Google');
      }

      final AuthResponse response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (response.user == null) {
        throw Exception('Google sign-in failed: No user returned');
      }

      return response.user!;
    } catch (e, stack) {
      log('❌ Google Sign-In Error: $e');
      log(stack.toString());
      rethrow;
    }
  }

  // ========================================
  // ✅ FACEBOOK SIGN IN
  // ========================================
  Future<User> facebookuser() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'https://kbshmetpchppzivoynly.supabase.co/auth/v1/callback',
      );

      User? user;

      // Wait and check for session multiple times
      for (int i = 0; i < 30; i++) {
        await Future.delayed(const Duration(milliseconds: 500));

        final session = supabase.auth.currentSession;
        if (session != null) {
          user = session.user;
          break;
        }
      }

      if (user == null) {
        throw Exception('Facebook sign-in failed: No user session found');
      }

      return user;
    } catch (e, stack) {
      log('❌ Facebook Sign-In Error: $e');
      log(stack.toString());
      rethrow;
    }
  }

  // ========================================
  // ✅ SIGN OUT
  // ========================================
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      log('❌ Sign out error: $e');
      rethrow;
    }
  }

  // ========================================
  // ✅ GET CURRENT USER
  // ========================================
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }
}