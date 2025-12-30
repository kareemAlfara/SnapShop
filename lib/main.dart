import 'package:shop_app/feature/checkout/data/datasource/order_remote_datasource.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shop_app/core/di/injection.dart';
import 'package:shop_app/core/services/Shared_preferences.dart';
import 'package:shop_app/core/services/theme_notifier.dart';
import 'package:shop_app/core/utils/apiScret.dart';
import 'package:shop_app/feature/auth/data/repository/repo_impl.dart';
import 'package:shop_app/feature/auth/domain/usecases/EmailSignUsecase.dart';
import 'package:shop_app/feature/auth/domain/usecases/facebookUsecase.dart';
import 'package:shop_app/feature/auth/domain/usecases/getCurrentUserFromPrefs.dart';
import 'package:shop_app/feature/auth/domain/usecases/googleUsecase.dart';
import 'package:shop_app/feature/auth/domain/usecases/signoutEntity.dart';
import 'package:shop_app/feature/auth/presentation/cubit/signin_cubit/signin_cubit.dart';
import 'package:shop_app/feature/auth/presentation/pages/SigninView.dart';
import 'package:shop_app/feature/checkout/domain/usecases/create_order_usecase.dart';
import 'package:shop_app/feature/checkout/domain/usecases/get_user_orders_usecase.dart';
import 'package:shop_app/feature/checkout/presentation/cubit/order_cubit.dart';
import 'package:shop_app/feature/mainview/data/repository/repoImlp.dart';
import 'package:shop_app/feature/mainview/domain/usecases/addfavoriteusecase.dart';
import 'package:shop_app/feature/mainview/domain/usecases/getproductsusecase.dart';
import 'package:shop_app/feature/mainview/domain/usecases/latestusecase.dart';
import 'package:shop_app/feature/mainview/domain/usecases/reviewusecases/add_review_usecase.dart';
import 'package:shop_app/feature/mainview/domain/usecases/reviewusecases/check_user_reviewed_usecase.dart';
import 'package:shop_app/feature/mainview/domain/usecases/reviewusecases/delete_review_usecase.dart';
import 'package:shop_app/feature/mainview/domain/usecases/reviewusecases/get_product_reviews_usecase.dart';
import 'package:shop_app/feature/mainview/domain/usecases/reviewusecases/get_user_review_usecase.dart';
import 'package:shop_app/feature/mainview/domain/usecases/reviewusecases/update_review_usecase.dart';
import 'package:shop_app/feature/mainview/domain/usecases/searchProductUsecase.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/Cartcubit/cart_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/layout_cubit/layout_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/product_cubit/product_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/reviewcubit/review_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/pages/adminScreen.dart';
import 'package:shop_app/feature/mainview/presentation/pages/layoutScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'feature/checkout/data/repos/order_repository_impl.dart';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('📩 Background message: ${message.notification?.title}');
// }
// // ✅ CREATE NOTIFICATION CHANNEL
// Future<void> _createNotificationChannel() async {
//   const channel = MethodChannel('com.example.shop_app/notification');
//   try {
//     await channel.invokeMethod('createNotificationChannel', {
//       'id': 'high_importance_channel',
//       'name': 'High Importance Notifications',
//       'description': 'This channel is used for important notifications',
//       'importance': 4, // IMPORTANCE_HIGH
//     });
//     print('✅ Notification channel created');
//   } catch (e) {
//     print('❌ Failed to create notification channel: $e');
//   }
// }

// void main(List<String> args) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   // Initialize OneSignal
//   OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
//   OneSignal.initialize("af8c697d-8229-447d-b10c-110692fd4c26");
// final subscriptionId = OneSignal.User.pushSubscription.id;
//   final OneSignaluserId = OneSignal.User.pushSubscription.token;
//   print("🔔 OneSignal Subscription ID: $subscriptionId");
//   print("🔔 Device Token: $OneSignaluserId");

//   // ✅ Listen to subscription changes
//   OneSignal.User.pushSubscription.addObserver((state) {
//     print("🔔 Push subscription state changed: ${state.current.jsonRepresentation()}");
//   });

//   // ✅ Handle foreground notifications
//   OneSignal.Notifications.addForegroundWillDisplayListener((event) {
//     print("🔔 Foreground notification received: ${event.notification.title}");
//     event.notification.display(); // Show notification even in foreground
//   });

//   // ✅ Handle notification clicks
//   OneSignal.Notifications.addClickListener((event) {
//     print("📬 Notification clicked: ${event.notification.title}");
//     print("📬 Additional Data: ${event.notification.additionalData}");
//   });
//   // Request notification permission
//   await OneSignal.Notifications.requestPermission(true);
//   // ✅ Create notification channel
//   await _createNotificationChannel();

//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

// FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//   print('📬 Foreground notification: ${message.notification?.title}');

//   // ✅ Display the notification manually when app is foreground
//   if (message.notification != null) {
//     final notification = message.notification!;
//     final android = message.notification?.android;

//     if (android != null) {
//       final channel =  AndroidNotificationChannel(
//         'high_importance_channel', // same as in manifest
//         'High Importance Notifications',
//         description: 'Used for important messages.',
//         importance: Importance.max,
//       );

//       final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//       await flutterLocalNotificationsPlugin.initialize(
//         const InitializationSettings(
//           android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//         ),
//       );

//       flutterLocalNotificationsPlugin.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             channel.id,
//             channel.name,
//             channelDescription: channel.description,
//             icon: android.smallIcon ?? '@mipmap/ic_launcher',
//           ),
//         ),
//       );
//     }
//   }
// });

//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     print('🔔 Notification tapped: ${message.notification?.title}');
//   });

//   await Supabase.initialize(
//     url: 'https://kbshmetpchppzivoynly.supabase.co',
//     anonKey:
//         "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtic2htZXRwY2hwcHppdm95bmx5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk2OTk1MTQsImV4cCI6MjA3NTI3NTUxNH0.5b2c_RkGwGDs1Zw0IU2qrm8NDy_LsXSb1oJFerZH2Ls",
//   );
//   await Prefs.init();

//   const String adminId = '0feb0b5f-1380-4574-8e81-7cdd8e13d147';
//   final userId = Prefs.getString("id");

//   // ✅ Check if logged in
//   final bool isLoggedin = userId != null && userId.isNotEmpty;

//   // ✅ Check if admin
//   final bool isAdmin = userId == adminId;
//   runApp(MyApp(isLoggedin: isLoggedin, isAdmin: isAdmin));
// }

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ----------------------------------------------------
// 🔔 Create Notification Channel (required for Android)
// ----------------------------------------------------
Future<void> _createNotificationChannel() async {
  const channel = MethodChannel('com.example.shop_app/notification');
  try {
    await channel.invokeMethod('createNotificationChannel', {
      'id': 'high_importance_channel',
      'name': 'High Importance Notifications',
      'description': 'This channel is used for important notifications',
      'importance': 4,
    });

    print('✅ Notification channel created');
  } catch (e) {
    print('❌ Failed to create notification channel: $e');
  }
}

// ----------------------------------------------------
// 🔥 MAIN
// ----------------------------------------------------
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   await Prefs.init();

//   // ----------------------------------------------------
//   // 🚀 Initialize OneSignal
//   // ----------------------------------------------------
//   OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
//   OneSignal.initialize("af8c697d-8229-447d-b10c-110692fd4c26");

//   // Request permission
//   await OneSignal.Notifications.requestPermission(true);

//   // Log tokens
//   final subscriptionId = OneSignal.User.pushSubscription.id;
//   final deviceToken = OneSignal.User.pushSubscription.token;

//   print("🔔 OneSignal Subscription ID: $subscriptionId");
//   print("🔔 OneSignal Device Token: $deviceToken");

//   // Observe subscription changes
//   OneSignal.User.pushSubscription.addObserver((state) {
//     print("📌 Subscription changed: ${state.current.jsonRepresentation()}");
//   });

//   // Foreground notifications
//   OneSignal.Notifications.addForegroundWillDisplayListener((event) {
//     print("📩 Foreground notification: ${event.notification.title}");
//     event.notification.display(); // force show
//   });

//   // Click listener
//   OneSignal.Notifications.addClickListener((event) {
//     print("👉 Notification clicked: ${event.notification.title}");
//   });

//   // ----------------------------------------------------
//   // 📌 Save OneSignal PlayerId into Supabase
//   // ----------------------------------------------------
//   final userId = Prefs.getString("id");

//   if (subscriptionId != null && userId != null && userId.isNotEmpty) {
//     await Supabase.instance.client.from("device_tokens").upsert({
//       "user_id": userId,
//       "token": subscriptionId,
//     });

//     print("📸 Saved OneSignal token to Supabase: $subscriptionId");
//   }

//   // ----------------------------------------------------
//   // 🚀 Create Notification Channel
//   // ----------------------------------------------------
//   await _createNotificationChannel();

//   // ----------------------------------------------------
//   // 🔗 Connect Supabase client
//   // ----------------------------------------------------
//   await Supabase.initialize(
//     url: 'https://kbshmetpchppzivoynly.supabase.co',
//     anonKey:
//         "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtic2htZXRwY2hwcHppdm95bmx5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk2OTk1MTQsImV4cCI6MjA3NTI3NTUxNH0.5b2c_RkGwGDs1Zw0IU2qrm8NDy_LsXSb1oJFerZH2Ls",
//   );

//   // ----------------------------------------------------
//   // LOGIN CHECKS
//   // ----------------------------------------------------
//   const String adminId = '0feb0b5f-1380-4574-8e81-7cdd8e13d147';
//   final bool isLoggedin = userId != null && userId.isNotEmpty;
//   final bool isAdmin = userId == adminId;

//   runApp(MyApp(isLoggedin: isLoggedin, isAdmin: isAdmin));
// }
// In your main.dart, update the OneSignal initialization section:
late final ThemeNotifier themeNotifier;
void main() async {
   
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ 1. Initialize Firebase
  await Firebase.initializeApp();
  
  // ✅ 2. Initialize Prefs
  await Prefs.init();
  
  // ✅ 3. Initialize Supabase FIRST! (قبل أي حاجة)
  await Supabase.initialize(
    url: 'https://kbshmetpchppzivoynly.supabase.co',
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtic2htZXRwY2hwcHppdm95bmx5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk2OTk1MTQsImV4cCI6MjA3NTI3NTUxNH0.5b2c_RkGwGDs1Zw0IU2qrm8NDy_LsXSb1oJFerZH2Ls",
  );
  
  print("✅ supabase.supabase_flutter: INFO: ***** Supabase init completed *****");
  Stripe.publishableKey = Apiscret().stripePublishableKey;
  // ✅ 4. Initialize ThemeNotifier
  themeNotifier = ThemeNotifier();
  
  // ✅ 5. Initialize OneSignal
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("af8c697d-8229-447d-b10c-110692fd4c26");
  
  // Request permission
  await OneSignal.Notifications.requestPermission(true);
  
  // Wait for subscription
  await Future.delayed(Duration(seconds: 2));
  
  final subscriptionId = OneSignal.User.pushSubscription.id;
  final deviceToken = OneSignal.User.pushSubscription.token;
  
  print("🔔 OneSignal Subscription ID: $subscriptionId");
  print("🔔 OneSignal Device Token: $deviceToken");
  
  // Observe subscription changes
  OneSignal.User.pushSubscription.addObserver((state) {
    print("📌 Subscription changed: ${state.current.jsonRepresentation()}");
    final newSubId = state.current.id;
    if (newSubId != null) {
      _saveOneSignalToken(newSubId);
    }
  });
  
  // Foreground notifications
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    print("📩 Foreground notification: ${event.notification.title}");
    event.notification.display();
  });
  
  // Click listener
  OneSignal.Notifications.addClickListener((event) {
    print("👉 Notification clicked: ${event.notification.title}");
  });
  
  // ✅ NOW save token (after Supabase is initialized)
  final userId = Prefs.getString("id");
  if (subscriptionId != null && userId != null && userId.isNotEmpty) {
    await _saveOneSignalToken(subscriptionId, userId);
  }
  
  // ✅ Create notification channel
  await _createNotificationChannel();
  
  // ✅ Check login status
  const String adminId = '0feb0b5f-1380-4574-8e81-7cdd8e13d147';
  final bool isLoggedin = userId != null && userId.isNotEmpty;
  final bool isAdmin = userId == adminId;
    // Initialize Dependency Injection
  await setupDependencies();
  
  runApp(MyApp(isLoggedin: isLoggedin, isAdmin: isAdmin));
}

// Helper function to save OneSignal token
Future<void> _saveOneSignalToken(
  String subscriptionId, [
  String? userId,
]) async {
  final uid = userId ?? Prefs.getString("id");
  
  if (uid == null || uid.isEmpty) {
    print("❌ No user ID available");
    return;
  }
  
  try {
    await Supabase.instance.client.from("device_tokens").upsert({
      "user_id": uid,
      "token": subscriptionId,
    }, onConflict: 'user_id');
    
    print("✅ Saved OneSignal subscription ID to Supabase: $subscriptionId");
  } catch (e) {
    print("❌ Failed to save token: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isLoggedin, required this.isAdmin});
  final bool isLoggedin;
  final bool isAdmin;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => SigninCubit(
                Emailsigninusecase(repo: RepoImpl()),
                Signoutusecase(RepoImpl()),
                Facebookusecase(RepoImpl()),
                Googleusecase(RepoImpl()),
                Getcurrentuserfromprefs(repo: RepoImpl()),
              ),
            ),
            BlocProvider(create: (context) => LayoutCubit()),
            BlocProvider(create: (context) => CartCubit()),
            BlocProvider(
              create: (context) =>
                  ProductCubit(
                      Getproductsusecase(RepoImlp()),
                      Searchproductusecase(RepoImlp()),
                      Latestusecase(RepoImlp()),
                      AddFavoriteUsecase(RepoImlp()),
                      DeleteFavoriteUsecase(RepoImlp()),
                      GetFavoriteProductsUsecase(RepoImlp()),
                    )
                    ..getproducts()
                    ..latestarrval(),
            ),
             BlocProvider(
      create: (context) => OrderCubit(
        createOrderUseCase: CreateOrderUseCase(
          OrderRepositoryImpl(OrderRemoteDataSource()),
        ),
        getUserOrdersUseCase: GetUserOrdersUseCase(
          OrderRepositoryImpl(OrderRemoteDataSource()),
        ),
      ),
    ),
                BlocProvider(
      create: (context) => ReviewCubit(
        getProductReviewsUseCase: GetProductReviewsUseCase(RepoImlp()),
        addReviewUseCase: AddReviewUseCase(RepoImlp()),
        updateReviewUseCase: UpdateReviewUseCase(RepoImlp()),
        deleteReviewUseCase: DeleteReviewUseCase(RepoImlp()),
        checkUserReviewedUseCase: CheckUserReviewedUseCase(RepoImlp()),
        getUserReviewUseCase: GetUserReviewUseCase(RepoImlp()),
      ),
    ),
          ],

          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            // theme: ThemeData.dark(),
              theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeMode,
            navigatorKey: navigatorKey,
            home: !isLoggedin
                ? const SigninView()
                : isAdmin
                ? const Adminscreen()
                : const Layoutscreen(),
          ),
        );
      },
    );
  }
}

