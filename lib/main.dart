import 'package:shop_app/core/di/auth_injection.dart';
import 'package:shop_app/core/di/order_injection.dart';
import 'package:shop_app/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shop_app/core/services/device_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shop_app/core/di/injection.dart' hide getIt;
import 'package:shop_app/core/services/Shared_preferences.dart';
import 'package:shop_app/core/services/theme_notifier.dart';
import 'package:shop_app/core/utils/apiScret.dart';
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
import 'package:shop_app/feature/admin/presentation/view/adminScreen.dart';
import 'package:shop_app/feature/mainview/presentation/pages/layoutScreen.dart';
import 'package:shop_app/feature/Delivery/presentation/pages/deliveryDashboard.dart';
import 'package:shop_app/core/routing/appRoutHelper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'feature/checkout/data/repos/order_repository_impl.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late final ThemeNotifier themeNotifier;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isHuawei = await DeviceService.isHuaweiDevice();
  debugPrint("📱 Is Huawei Device: $isHuawei");

  // ✅ 1. Initialize Prefs
  await Prefs.init();

  // ✅ 2. Initialize Supabase
  await Supabase.initialize(
    url: 'https://kbshmetpchppzivoynly.supabase.co',
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtic2htZXRwY2hwcHppdm95bmx5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk2OTk1MTQsImV4cCI6MjA3NTI3NTUxNH0.5b2c_RkGwGDs1Zw0IU2qrm8NDy_LsXSb1oJFerZH2Ls",
  );

  print("✅ Supabase initialized successfully");

  // ✅ 3. Initialize Stripe
  Stripe.publishableKey = Apiscret().stripePublishableKey;

  // ✅ 4. Initialize ThemeNotifier
  themeNotifier = ThemeNotifier();

  // ✅ 5. Initialize OneSignal
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("3ea76b38-000f-4a3a-bacd-a9ea34feb520");

  // Request permission
  await OneSignal.Notifications.requestPermission(true);

  // ✅ 6. Setup OneSignal Listeners
  _setupOneSignalListeners();

  // ✅ 7. Save OneSignal Token to Supabase
  await _saveOneSignalTokenToSupabase();

  // ✅ 8. Initialize Dependency Injection
  await setupDependencies();
  await setupAuthDependencies();
  await setupOrderDependencies(); 

  // ✅ 9. Check Login Status and User Type
  final userId = Prefs.getString("id");
  final userType = Prefs.getString("user_type"); // ✅ Get user type
  
  final bool isLoggedin = userId != null && userId.isNotEmpty;

  // ✅ Debug logs
  print('👤 User ID: $userId');
  print('👤 User Type: $userType');
  print('🔐 Is Logged In: $isLoggedin');

  timeago.setLocaleMessages('ar', timeago.ArMessages());
  
  runApp(MyApp(
    isLoggedin: isLoggedin,
    userType: userType ?? 'customer', // ✅ Pass user type
    isHuawei: isHuawei,
  ));
}

// ✅ Setup OneSignal Listeners
void _setupOneSignalListeners() {
  OneSignal.User.pushSubscription.addObserver((state) {
    final newSubId = state.current.id;
    print("📌 OneSignal Subscription Changed: $newSubId");

    if (newSubId != null) {
      _saveOneSignalTokenToSupabase();
    }
  });

  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    print("📩 Foreground notification: ${event.notification.title}");
    event.notification.display();
  });

  OneSignal.Notifications.addClickListener((event) {
    print("👉 Notification clicked: ${event.notification.title}");
    final data = event.notification.additionalData;

    if (data != null) {
      print("📦 Data: $data");
    }
  });
}

// ✅ Save OneSignal Token to Supabase
Future<void> _saveOneSignalTokenToSupabase() async {
  final userId = Prefs.getString("id");

  if (userId == null || userId.isEmpty) {
    print("❌ No user ID found");
    return;
  }

  await Future.delayed(Duration(seconds: 2));

  final subscriptionId = OneSignal.User.pushSubscription.id;

  if (subscriptionId == null) {
    print("❌ No OneSignal subscription ID found");
    return;
  }

  try {
    await Supabase.instance.client.from("device_tokens").upsert({
      "user_id": userId,
      "subscription_id": subscriptionId,
    }, onConflict: 'user_id');

    print("✅ OneSignal token saved: $subscriptionId");
  } catch (e) {
    print("❌ Failed to save token: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.isLoggedin,
    required this.userType,
    required this.isHuawei,
  });

  final bool isLoggedin;
  final String userType;
  final bool isHuawei;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<AuthCubit>()),
            BlocProvider(create: (context) => LayoutCubit()),
            BlocProvider(create: (context) => CartCubit()),
            BlocProvider(
              create: (context) => ProductCubit(
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
             // ✅ Updated: Use dependency injection for OrderCubit
    BlocProvider(
      create: (context) => getIt<OrderCubit>(),
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
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeMode,
            navigatorKey: navigatorKey,
            home: _getHomeScreen(),
          ),
        );
      },
    );
  }

  // ✅ Determine which screen to show based on login status and user type
  Widget _getHomeScreen() {
    if (!isLoggedin) {
      return SigninView(isHuawei: isHuawei);
    }

    // ✅ Navigate based on user type
    print('🏠 Navigating for user type: $userType');
    
    switch (userType.toLowerCase()) {
      case 'admin':
        print('➡️ Opening Admin Screen');
        return const Adminscreen();
      case 'delivery':
        print('➡️ Opening Delivery Dashboard');
        return const DeliveryDashboard();
      case 'customer':
      default:
        print('➡️ Opening Customer Layout');
        return const Layoutscreen();
    }
  }
}