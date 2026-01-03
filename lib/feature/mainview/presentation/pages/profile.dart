import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/core/services/Shared_preferences.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';
import 'package:shop_app/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:shop_app/feature/auth/presentation/pages/SigninView.dart';
import 'package:shop_app/feature/checkout/presentation/cubit/order_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/Cartcubit/cart_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/pages/RecentlyViewed.dart';
import 'package:shop_app/feature/mainview/presentation/pages/Wishlist.dart';
import 'package:shop_app/feature/mainview/presentation/pages/allOrders.dart';
import 'package:shop_app/feature/mainview/presentation/pages/privacyPage.dart';
import 'package:shop_app/feature/profile/presentation/pages/updateprofile.dart';
import 'package:shop_app/main.dart';

class profile extends StatelessWidget {
  const profile({super.key});

  // bool get wantKeepAlive => false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context: context, title: "Smart Shop", isShowActions: false),

      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          var cubit = AuthCubit.get(context);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  FutureBuilder<UserEntity?>(
                    future: cubit.getCurrentUser(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Text(
                          "Login to save your details, and access your info",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      } else {
                        final user = snapshot.data!;
                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 37,
                              backgroundImage: NetworkImage(
                                user.image ??
                                    "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  user.email,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: CircleAvatar(
                                radius: 20,
                                child: IconButton(
                                  onPressed: () async {
                                    await navigat(
                                      context,
                                      widget: UpdateProfile(user: user),
                                    );

                                  // ✅ بعد الرجوع
                                  },
                                  icon: Icon(Icons.edit),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 23),
                  const Text(
                    "General",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 22),
                GestureDetector(
  onTap: () {
    // التحقق من تسجيل الدخول
    final userId = Prefs.getString("id");
    
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to view your orders'),
          backgroundColor: Colors.red,
        ),
      );
      
      // اختياري: الانتقال لصفحة تسجيل الدخول
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SigninView(isHuawei: false),
        ),
      );
      return;
    }

    // الانتقال لصفحة جميع الطلبات
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<OrderCubit>(),
          child: const AllOrdersScreen(),
        ),
      ),
    );
  },
  child: generalData(
    text: "All Orders",
    assetName: "assets/images/bag/order.png",
  ),
),

                  const SizedBox(height: 22),
                  GestureDetector(
                    onTap: () {
                      navigat(context, widget: WishlistView());
                    },
                    child: generalData(
                      text: "Wishlist",
                      assetName: "assets/images/bag/wishlist_svg.png",
                    ),
                  ),
                  const SizedBox(height: 22),
                  GestureDetector(
                    onTap: () {
                      navigat(context, widget: RecentlyViewedView());
                    },
                    child: generalData(
                      text: "Viewed Recently",
                      assetName: "assets/images/profile/recent.png",
                    ),
                  ),
                  const SizedBox(height: 22),
                  GestureDetector(
                    onTap: () {
                      // navigat(context, widget: OrderTrackingScreen(order: ));
                    },
                    child: generalData(
                      text: "Address",
                      assetName: "assets/images/profile/address.png",
                    ),
                  ),
                  const SizedBox(height: 33),
                  Container(
                    height: 1,
                    color: Colors.grey,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Setting",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeNotifier,
                    builder: (context, themeMode, _) {
                      final isDark = themeMode == ThemeMode.dark;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Image.asset(
                          "assets/images/profile/theme.png",
                          width: 33,
                        ),
                        title: Text(
                          isDark ? "Dark Theme" : "Light Theme",
                          style: const TextStyle(fontSize: 16),
                        ),
                        trailing: Switch(
                          value: isDark,
                          onChanged: (value) {
                            themeNotifier.toggleTheme();
                          },
                          activeThumbColor: Colors.blue,
                        ),
                      );
                    },
                  ),
                  Container(
                    height: 1,
                    color: Colors.grey,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    "others",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Image.asset(
                        "assets/images/profile/privacy.png",
                        width: 33,
                      ),
                      const SizedBox(width: 22),
                      GestureDetector(
                        onTap: () {
                          navigat(context, widget: PrivacyPolicyPage());
                        },
                        child: const Text(
                          "Privacy & Policy",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: SizedBox(
                      width: 130,
                      child: Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(33),
                            ),
                          ),
                          onPressed: () async {
                            cubit.signOut();

                            final cartCubit = context.read<CartCubit>();

                            // 🧹 1. Sign out from Supabase
                            await AuthCubit.get(context).signOut();

                            // 🧹 2. Clear local data
                            await Prefs.clear(); // or Prefs.remove('recent_products');

                            // 🧹 3. Clear Cubit states
                            cartCubit.allCartEntity.deleteAllCartItems();

                            // 🧹 4. Navigate to Login (and remove all previous routes)
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const SigninView(
                                      isHuawei: false,  
                                ),
                              ),
                              (route) => false,
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.logout),
                              SizedBox(width: 12),
                              Text("logout"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget generalData({required String assetName, required String text}) => Row(
    children: [
      CircleAvatar(backgroundImage: AssetImage(assetName)),
      const SizedBox(width: 22),
      Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    ],
  );
}
