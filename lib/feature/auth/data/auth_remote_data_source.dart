import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shop_app/core/services/Supabase_auth_service.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/feature/admin/presentation/view/notif.dart';
import 'package:shop_app/feature/auth/data/models/userModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class AuthRemoteDataSource {
  Future<Usermodel> Signup({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String image,
  }) async {
    SupabaseClient supabase = Supabase.instance.client;
    User? user;
    user = await SupabaseAuthService().Signup(email: email, password: password);
    uid = user!.id;
    await supabase.from('users').insert({
      'uid': uid,
      'email': email,
      'name': name,
      "image": image,
      "phone": phone,
    });

    return Usermodel(
      id: uid!,
      email: email,
      name: name,
      image: image,
      phone: phone,
    );
  }

  Future<bool> sendPrivateNotification({
    required String title,
    required String body,
    required String receiverId,
  }) async {
    final response = await supabase.functions.invoke(
      "send-onesignal-notification",
      body: {"title": title, "body": body, "receiverId": receiverId},
    );

    return response.data["ok"] == true;
  }

  Future<bool> sendGlobalNotification({
    required String title,
    required String body,
  }) async {
    final response = await supabase.functions.invoke(
      "send-onesignal-notification",
      body: {"title": title, "body": body},
    );

    return response.data["ok"] == true;
  }

  Future<void> saveOneSignalToken(String playerId, String userId) async {
    final response = await supabase.from("device_tokens").upsert({
      "user_id": userId,
      "token": playerId,
    });

    if (response.error != null) {
      throw Exception("Failed to save token: ${response.error!.message}");
    }
  }

  Future<void> notifyAllUsers(String title, String body) async {
    await sendOneSignalNotification(title: title, body: body, receiverId: null);
  }

  Future<void> notifyUser(String receiverId, String title, String body) async {
    await sendOneSignalNotification(
      title: title,
      body: body,
      receiverId: receiverId,
    );
  }

  //   Future<void> notifyUser(String receiverId, String title, String body) async {
  //     final res = await Supabase.instance.client
  //         .from('device_tokens')
  //         .select('token')
  //         .eq('user_id', receiverId)
  //         .maybeSingle();

  //     final fcmToken = res?['token'] as String?;
  //     if (fcmToken != null) {
  //     await sendPrivateNotification(
  //   title: title,
  //   body: body,
  //   receiverId: receiverId,
  // );
  //       // await sendNotification(
  //       //   receiverId: receiverId,
  //       //   deviceToken: fcmToken,
  //       //   title: title,
  //       //   body: body,
  //       // );
  //     } else {
  //       print("No token found for user $receiverId");
  //     }
  //   }
  final supabase = Supabase.instance.client;

  /// Send notification via OneSignal Edge Function
  Future<void> sendOneSignalNotification({
    required String title,
    required String body,
    String? receiverId,
  }) async {
    final res = await http.post(
      Uri.parse(
        'https://kbshmetpchppzivoynly.supabase.co/functions/v1/sedeonesignal',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtic2htZXRwY2hwcHppdm95bmx5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk2OTk1MTQsImV4cCI6MjA3NTI3NTUxNH0.5b2c_RkGwGDs1Zw0IU2qrm8NDy_LsXSb1oJFerZH2Ls',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtic2htZXRwY2hwcHppdm95bmx5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk2OTk1MTQsImV4cCI6MjA3NTI3NTUxNH0.5b2c_RkGwGDs1Zw0IU2qrm8NDy_LsXSb1oJFerZH2Ls',
      },
      body: jsonEncode({
        'title': title,
        'body': body,
        if (receiverId != null) 'receiverId': receiverId,
      }),
    );

    if (res.statusCode == 200) {
      print("✅ Notification sent successfully");
    } else {
      print("❌ Error: ${res.body}");
    }
  }

  Future<Usermodel> Signin({
    required String email,
    required String password,
  }) async {
    final supabase = Supabase.instance.client;
    final user = await SupabaseAuthService().Signin(
      email: email,
      password: password,
    );
    // ✅ تحقق من null
    if (user == null) {
      throw Exception('Sign in failed: No user returned');
    }
    // final user = response.user!;
    uid = user.id;
    // await notifyAllUsers("New login", "${user.email} just signed in!");
    await notifyUser(user.id, "New login", "${user.email} just signed in!");
    final userRow = await supabase
        .from('users')
        .select('uid, email, name,image')
        .eq('uid', uid!)
        .maybeSingle();
    if (userRow == null) {
      throw Exception("User data not found in 'users' table.");
    }
    final fcm = FirebaseMessaging.instance;

    // ✅ Request notification permissions (CRITICAL for Android 13+)
    NotificationSettings settings = await fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    await fcm.getToken().then((token) async {
      if (token != null) {
        await Supabase.instance.client.from('device_tokens').upsert({
          'user_id': user.id,
          'token': token,
        }, onConflict: 'user_id');
        print('✅ FCM token saved: $token');
      }
    });
    final String userName = userRow['name'].toString();
    final model = Usermodel.fromJson(userRow);
    // Prefs.setString('name', userName);
    // Prefs.setString("id", uid!);
    // log(model.email.toString());
    // log(model.id.toString());
    return model;
  }

  final GoogleSignIn googleSignIn = GoogleSignIn(
    serverClientId:
        '1038966682534-8f6kpcl2hfkp9o0p3lkb7v86deblaaj8.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );
  Future<Usermodel> signinWithGoogle() async {
    try {
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final user = await SupabaseAuthService().googleSigninuser();

      final existingUser = await Supabase.instance.client
          .from('users')
          .select('uid')
          .eq('uid', user.id)
          .maybeSingle();

      if (existingUser == null) {
        await Supabase.instance.client.from('users').upsert({
          "uid": user.id,
          "name": user.userMetadata?['full_name'] ?? googleUser!.displayName,
          "email": user.email,
          "image": "",
        });
      }
      await notifyUser(user.id, "New login", "${user.email} just signed in!");
      final model = Usermodel(
        id: user.id,
        email: user.email!,
        name: user.userMetadata?['full_name'] ?? googleUser!.displayName ?? '',
        image: "",
        phone: user.userMetadata?['phone'] ?? '',
      );
      final fcm = FirebaseMessaging.instance;
      await fcm.requestPermission();
      final fcmToken = await fcm.getToken();

      if (fcmToken != null) {
        await Supabase.instance.client.from('device_tokens').upsert({
          'user_id': user.id,
          'token': fcmToken,
        }, onConflict: 'user_id');
        print('✅ FCM token saved for user ${user.id}: $fcmToken');
      }
      print('✅ SignIn Success: ${model.name}, ${model.email}');
      return model;
    } catch (e, stack) {
      print('❌ Google Sign-In Error: $e');
      print(stack);
      rethrow;
    }
  }

  Future<Usermodel> signinWithFacebook() async {
    final supa = Supabase.instance.client;

    try {
      // Sign out first to ensure clean state
      await supa.auth.signOut();

      print('🔄 Starting Facebook OAuth...');

      // Start the OAuth flow
      final result = await supa.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'io.supabase.kbshmetpchppzivoynly://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (!result) {
        throw Exception('Failed to launch Facebook OAuth');
      }

      print('⏳ Waiting for OAuth callback...');

      // Wait for session with timeout
      final completer = Completer<Session?>();
      StreamSubscription? subscription;
      Timer? timeoutTimer;

      subscription = supa.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session != null && !completer.isCompleted) {
          print('✅ Session received!');
          completer.complete(session);
        }
      });

      // Set a reasonable timeout (30 seconds)
      timeoutTimer = Timer(Duration(seconds: 30), () {
        if (!completer.isCompleted) {
          completer.completeError(
            Exception('Facebook authentication timed out'),
          );
        }
      });

      try {
        final session = await completer.future;

        if (session == null || session.user == null) {
          throw Exception('No session found after Facebook authentication');
        }

        final user = session.user;
        print('👤 User authenticated: ${user.id}');

        // Extract user information
        final userName =
            user.userMetadata?['full_name'] ??
            user.userMetadata?['name'] ??
            user.email?.split('@')[0] ??
            'Facebook User';

        final userEmail = user.email ?? '';

        uid = user.id;

        print('💾 Saved to SharedPreferences - ID: $uid, Name: $userName');

        // Check if user exists in database
        final existingUser = await supa
            .from('users')
            .select('uid')
            .eq('uid', user.id)
            .maybeSingle();

        if (existingUser == null) {
          // Insert new user
          await supa.from('users').insert({
            'uid': user.id,
            'email': userEmail,
            'name': userName,
            "image": "faceimage",
          });
          print('➕ New user added to database');
        } else {
          print('✓ Existing user found in database');
        }

        final userEntity = Usermodel(
          id: user.id,
          email: userEmail,
          name: userName,
          image: "image",
          phone: user.userMetadata?['phone'] ?? '',
        );

        print('✅ Facebook sign-in successful!');
        return userEntity;
      } finally {
        // Clean up
        await subscription.cancel();
        timeoutTimer.cancel();
      }
    } catch (e, stack) {
      print('❌ Facebook sign-in error: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  @override
  Future<String?> uploadImageToSupabase(File file) async {
    final fileExtension = path.extension(file.path); // .jpg أو .png
    final uniqueId = const Uuid().v4(); // مولد UUID فريد
    final fileName = '$uniqueId$fileExtension'; // اسم جديد وفريد
    final fileBytes = await file.readAsBytes();

    await supabase.storage
        .from('user_images')
        .uploadBinary('uploads/$fileName', fileBytes);
    return fileName;
  }
}
