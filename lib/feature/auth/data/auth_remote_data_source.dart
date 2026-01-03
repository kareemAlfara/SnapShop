import 'dart:convert';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:shop_app/core/enums/user_type.dart';
import 'package:shop_app/core/services/Supabase_auth_service.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/feature/auth/data/models/userModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AuthRemoteDataSource {
  final SupabaseClient supabase;
  final GoogleSignIn googleSignIn;
  final SupabaseAuthService _authService;

  AuthRemoteDataSource({
    required this.supabase,
    required this.googleSignIn,
  }) : _authService = SupabaseAuthService();

  // ========================================
  // ✅ SIGNUP
  // ========================================
  Future<UserModel> Signup({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String image,
  }) async {
    User? user = await _authService.Signup(
      email: email,
      password: password,
    );

    if (user == null) {
      throw Exception('Signup failed: No user returned');
    }

    uid = user.id;

    await supabase.from('users').insert({
      'uid': uid,
      'email': email,
      'name': name,
      'image': image,
      'phone': phone,
      'user_type': 'customer', // Default to customer
    });

    // Send welcome notification
    await notifyUser(
      user.id,
      "مرحباً بك! 🎉",
      "تم إنشاء حسابك بنجاح",
    );

    return UserModel(
      id: uid!,
      email: email,
      name: name,
      image: image,
      phone: phone,
      userType: UserType.customer,
    );
  }

  // ========================================
  // ✅ SIGNIN
  // ========================================
  Future<UserModel> Signin({
    required String email,
    required String password,
  }) async {
    final user = await _authService.Signin(
      email: email,
      password: password,
    );

    if (user == null) {
      throw Exception('Sign in failed: No user returned');
    }

    uid = user.id;

    final userRow = await supabase
        .from('users')
        .select('uid, email, name, image, phone, user_type')
        .eq('uid', uid!)
        .maybeSingle();

    if (userRow == null) {
      throw Exception("User data not found in 'users' table.");
    }

    // Send welcome back notification
    await notifyUser(
      user.id,
      "مرحباً بعودتك! 👋",
      "${userRow['name']} سجلت دخول بنجاح",
    );

    return UserModel.fromJson(userRow);
  }

  // ========================================
  // ✅ GOOGLE SIGN IN
  // ========================================
  Future<UserModel> signinWithGoogle() async {
    try {
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign-in cancelled');
      }

      final user = await _authService.googleSigninuser();

      final existingUser = await supabase
          .from('users')
          .select('uid, email, name, image, phone, user_type')
          .eq('uid', user.id)
          .maybeSingle();

      if (existingUser == null) {
        // New user - create entry
        await supabase.from('users').insert({
          'uid': user.id,
          'name': user.userMetadata?['full_name'] ?? googleUser.displayName ?? '',
          'email': user.email,
          'image': '',
          'phone': user.userMetadata?['phone'] ?? '',
          'user_type': 'customer',
        });

        await notifyUser(
          user.id,
          "مرحباً بك! 🎉",
          "تم إنشاء حسابك بنجاح عبر Google",
        );

        return UserModel(
          id: user.id,
          email: user.email!,
          name: user.userMetadata?['full_name'] ?? googleUser.displayName ?? '',
          image: '',
          phone: user.userMetadata?['phone'] ?? '',
          userType: UserType.customer,
        );
      } else {
        // Existing user
        await notifyUser(
          user.id,
          "تسجيل دخول بنجاح ✅",
          "${user.email} سجل دخول عبر Google",
        );

        return UserModel.fromJson(existingUser);
      }
    } catch (e, stack) {
      print('❌ Google Sign-In Error: $e');
      print(stack);
      rethrow;
    }
  }

  // ========================================
  // ✅ FACEBOOK SIGN IN
  // ========================================
  Future<UserModel> signinWithFacebook() async {
    try {
      final user = await _authService.facebookuser();

      final existingUser = await supabase
          .from('users')
          .select('uid, email, name, image, phone, user_type')
          .eq('uid', user.id)
          .maybeSingle();

      if (existingUser == null) {
        await supabase.from('users').insert({
          'uid': user.id,
          'name': user.userMetadata?['full_name'] ?? 
                  user.userMetadata?['name'] ?? 
                  user.email?.split('@')[0] ?? 
                  'Facebook User',
          'email': user.email ?? '',
          'image': '',
          'phone': user.userMetadata?['phone'] ?? '',
          'user_type': 'customer',
        });

        await notifyUser(
          user.id,
          "مرحباً بك! 🎉",
          "تم إنشاء حسابك بنجاح عبر Facebook",
        );

        return UserModel(
          id: user.id,
          email: user.email ?? '',
          name: user.userMetadata?['full_name'] ?? 
                user.userMetadata?['name'] ?? 
                user.email?.split('@')[0] ?? 
                'Facebook User',
          image: '',
          phone: user.userMetadata?['phone'] ?? '',
          userType: UserType.customer,
        );
      } else {
        await notifyUser(
          user.id,
          "تسجيل دخول بنجاح ✅",
          "${user.email} سجل دخول عبر Facebook",
        );

        return UserModel.fromJson(existingUser);
      }
    } catch (e, stack) {
      print('❌ Facebook Sign-In Error: $e');
      print(stack);
      rethrow;
    }
  }

  // ========================================
  // ✅ SIGN OUT
  // ========================================
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      await googleSignIn.signOut();
    } catch (e) {
      print('❌ Sign out error: $e');
      rethrow;
    }
  }

  // ========================================
  // 🔔 ONESIGNAL NOTIFICATIONS
  // ========================================
  Future<void> notifyUser(String receiverId, String title, String body) async {
    try {
      await _sendOneSignalNotification(
        title: title,
        body: body,
        uid: receiverId,
      );

      await _saveNotificationToDatabase(
        userId: receiverId,
        title: title,
        body: body,
      );

      print("✅ Notification sent and saved successfully");
    } catch (e) {
      print("❌ Error in notifyUser: $e");
    }
  }

  Future<void> notifyAllUsers(String title, String body) async {
    try {
      await _sendOneSignalNotification(
        title: title,
        body: body,
        uid: null,
      );

      final users = await supabase
          .from('users')
          .select('uid')
          .limit(1000);

      for (var user in users) {
        await _saveNotificationToDatabase(
          userId: user['uid'],
          title: title,
          body: body,
        );
      }

      print("✅ Broadcast notification sent to all users");
    } catch (e) {
      print("❌ Error in notifyAllUsers: $e");
    }
  }

  Future<void> _sendOneSignalNotification({
    required String title,
    required String body,
    String? uid,
  }) async {
    try {
      final requestBody = {
        'title': title,
        'body': body,
        if (uid != null) 'uid': uid,
      };

      print("📤 Sending notification request: $requestBody");

      final res = await http.post(
        Uri.parse(
          'https://kbshmetpchppzivoynly.supabase.co/functions/v1/send-notification',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtic2htZXRwY2hwcHppdm95bmx5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk2OTk1MTQsImV4cCI6MjA3NTI3NTUxNH0.5b2c_RkGwGDs1Zw0IU2qrm8NDy_LsXSb1oJFerZH2Ls',
          'apikey':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtic2htZXRwY2hwcHppdm95bmx5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk2OTk1MTQsImV4cCI6MjA3NTI3NTUxNH0.5b2c_RkGwGDs1Zw0IU2qrm8NDy_LsXSb1oJFerZH2Ls',
        },
        body: jsonEncode(requestBody),
      );

      print("📨 Edge Function Response Status: ${res.statusCode}");
      print("📨 Edge Function Response Body: ${res.body}");

      if (res.statusCode == 200) {
        print("✅ OneSignal notification sent successfully");
      } else {
        print("❌ Error sending notification: ${res.body}");
      }
    } catch (e) {
      print("❌ Exception in _sendOneSignalNotification: $e");
      rethrow;
    }
  }

  Future<void> _saveNotificationToDatabase({
    required String userId,
    required String title,
    required String body,
  }) async {
    try {
      await supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'read': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      print("✅ Notification saved to database for user: $userId");
    } catch (e) {
      print("❌ Error saving notification to database: $e");
      rethrow;
    }
  }

  // ========================================
  // 📁 IMAGE UPLOAD
  // ========================================
  Future<String?> uploadImageToSupabase(File file) async {
    try {
      final fileExtension = path.extension(file.path);
      final uniqueId = const Uuid().v4();
      final fileName = '$uniqueId$fileExtension';
      final fileBytes = await file.readAsBytes();

      await supabase.storage
          .from('user_images')
          .uploadBinary('uploads/$fileName', fileBytes);

      return fileName;
    } catch (e) {
      print('❌ Error uploading image: $e');
      rethrow;
    }
  }
}