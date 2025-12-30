import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/feature/admin/data/repository/repo_impl/repo_impl.dart';

import 'package:shop_app/feature/admin/domain/usecases/addproductuseCase.dart';
import 'package:shop_app/feature/admin/domain/usecases/uploadAssetsImageUsecase.dart';

import 'package:shop_app/feature/admin/domain/usecases/uploadImageusecase.dart';
import 'package:shop_app/feature/admin/presentation/cubit/dashboard_cubit/dashboard_cubit.dart';
import 'package:shop_app/feature/admin/presentation/view/notificationView.dart';
import 'package:shop_app/feature/admin/presentation/view/widget/ProductimageWidget.dart';
import 'package:shop_app/feature/auth/presentation/cubit/signin_cubit/signin_cubit.dart';
import 'package:shop_app/feature/auth/presentation/pages/SigninView.dart';
import 'package:shop_app/feature/mainview/presentation/cubit/Cartcubit/cart_cubit.dart';

import '../../../../../core/services/Shared_preferences.dart';

class DashboardItem extends StatelessWidget {
  const DashboardItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit(
        Addproductusecase(RepoImpl()),
        Uploadimageusecase(RepoImpl()),
        Uploadassetsimageusecase(RepoImpl()),
      ),
      child: BlocConsumer<DashboardCubit, DashboardState>(
        builder: (context, state) {
          var cubit = context.read<DashboardCubit>;
          final List<List<Color>> bgColors = [
            [Colors.pink.shade500, Colors.orange.shade300],
          ];

          return Container(
            child: Scaffold(
              appBar: AppBar(
                actions: [
                  IconButton(
                    onPressed: () {
                      navigat(context, widget: NotificationView());
                    },
                    icon: Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 33,
                    ),
                  ),
                ],
                backgroundColor: Colors.pink.shade500,
                centerTitle: true,
                leading: IconButton(
                  onPressed: () async {
                    SigninCubit.get(context).signOut();

                    final cartCubit = context.read<CartCubit>();

                    // 🧹 1. Sign out from Supabase
                    await SigninCubit.get(context).signOut();

                    // 🧹 2. Clear local data
                    await Prefs.clear(); // or Prefs.remove('recent_products');

                    // 🧹 3. Clear Cubit states
                    cartCubit.allCartEntity.deleteAllCartItems();

                    // 🧹 4. Navigate to Login (and remove all previous routes)
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const SigninView()),
                      (route) => false,
                    );
                  },
                  icon: Icon(Icons.logout),
                ),
                title: defulttext(data: "Add product", context: context),
              ),
              body: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: bgColors[0],
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Form(
                      key: cubit().formkey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SizedBox(height: 12),
                          defulitTextFormField(
                            context: context,
                            controller: cubit().productnamecontroller,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "please inter ther product name";
                              }
                              return null;
                            },
                            title: "product name",
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: 18),
                          defulitTextFormField(
                            context: context,
                            controller: cubit().productpricecontroller,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "please inter the product price";
                              }
                              return null;
                            },

                            title: "product price",
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 18),
                          defulitTextFormField(
                            context: context,
                            controller: cubit().productquantitycontroller,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "please inter ther product quantity";
                              }
                              return null;
                            },
                            title: "product quantity",
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: 18),
                          defulitTextFormField(
                            context: context,
                            maxline: 3,
                            controller: cubit().productdescriptioncontroller,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "please inter ther Description";
                              }
                              return null;
                            },
                            title: "Description",
                            textInputAction: TextInputAction.done,
                          ),
                          SizedBox(height: 28),
                          ProductimageWidget(cubit: cubit()),
                          SizedBox(height: 28),

                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: () async {
                                if (cubit().formkey.currentState!.validate()) {
                                  cubit().createProduct(
                                    quantity: int.parse(
                                      cubit().productquantitycontroller.text,
                                    ),
                                    productname:
                                        cubit().productnamecontroller.text,
                                    // productimage: cubit().Assetsimage!,
                                    productprice:
                                        num.tryParse(
                                          cubit().productpricecontroller.text,
                                        ) ??
                                        0,
                                    productcode:
                                        cubit().productquantitycontroller.text,
                                    productimage: cubit().imageUrl!,
                                    description: cubit()
                                        .productdescriptioncontroller
                                        .text,
                                  );
                                  //                                 String assetPath = "assets/images/avocatoo.png";
                                  //       ByteData byteData = await rootBundle.load(assetPath);
                                  // Uint18List fileBytes = byteData.buffer.asUint18List();
                                  // log(  fileBytes.toString());
                                }
                              },
                              child: state is createuserloading
                                  ? Center(child: CircularProgressIndicator())
                                  : Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: defulttext(
                                        context: context,
                                        data: "  Add product  ",
                                        fSize: 18,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        listener: (context, state) async {
          if (state is createproductuccess) {
            DashboardCubit.get(context).productdescriptioncontroller.clear();
            DashboardCubit.get(context).productnamecontroller.clear();
            DashboardCubit.get(context).productpricecontroller.clear();
            DashboardCubit.get(context).productquantitycontroller.clear();

            DashboardCubit.get(context).imageUrl = null;

            Fluttertoast.showToast(
              msg: 'Add product successful!',
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
          } else if (state is createuserfailier) {
            Fluttertoast.showToast(
              msg: 'Error: ${state.error}',
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
        },
      ),
    );
  }
}
