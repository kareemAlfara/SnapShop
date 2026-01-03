// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shop_app/core/utils/SignigContainer.dart';
// import 'package:shop_app/core/utils/app_colors.dart';
// import 'package:shop_app/core/utils/app_images.dart';
// import 'package:shop_app/core/utils/components.dart';
// import 'package:shop_app/core/utils/custom_button.dart';
// import 'package:shop_app/feature/auth/presentation/cubit/signin_cubit/signin_cubit.dart';
// import 'package:shop_app/feature/auth/presentation/pages/SignupView.dart';
// import 'package:shop_app/feature/mainview/presentation/pages/adminScreen.dart';
// import 'package:shop_app/feature/mainview/presentation/pages/layoutScreen.dart';

// class SigninBodyWidget extends StatelessWidget {
//   const SigninBodyWidget({super.key, required this.isHuawei});
//   final bool isHuawei;
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<SigninCubit, SigninState>(
//       listener: (context, state) {
//         if (state is signinSuccessState ||
//             state is googleSuccessState ||
//             state is facebookSuccessState) {
//           Fluttertoast.showToast(
//             msg: " Sign in Success",
//             backgroundColor: Colors.green,
//           );
//           const String adminId = '0feb0b5f-1380-4574-8e81-7cdd8e13d147';

//           if (state is signinSuccessState && state.user.id == adminId) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => Adminscreen()),
//             );
//           } else {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => Layoutscreen()),
//             );
//           }

//           // navigat(context, widget: HomeView());
//         } else if (state is SigninerrorState) {
//           Fluttertoast.showToast(
//             msg: " ${state.message}",
//             backgroundColor: Colors.red,
//           );
//         }
//         // TODO: implement listener
//       },
//       builder: (context, state) {
//         var cubit = SigninCubit.get(context);
//         return SingleChildScrollView(
//           child: Form(
//             key: cubit.formkey,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   SizedBox(height: 44),
//                   defulitTextFormField(
//                     controller: cubit.emailcontroller,
//                     context: context,
//                     hintText: "Email",
//                   ),
//                   SizedBox(height: 15),

//                   defulitTextFormField(
//                     controller: cubit.passwordcontroller,
//                     context: context,
//                     hintText: "Password",
//                     suffixIcon: Icon(Icons.visibility),
//                   ),
//                   SizedBox(height: 15),

//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       TextButton(
//                         onPressed: () {},
//                         child: defulttext(
//                           context: context,
//                           data: "Forget Password?",
//                           color: AppColors.lightPrimaryColor,
//                           fSize: 16,
//                           fw: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 22),

//                   CustomButton(
//                     text: "Sign In",
//                     onPressed: () async {
//                       if (cubit.formkey.currentState!.validate()) {
//                         await cubit.signin(
//                           email: cubit.emailcontroller.text,
//                           password: cubit.passwordcontroller.text,
//                         );
//                       }

//                       cubit.emailcontroller.clear();
//                       cubit.passwordcontroller.clear();
//                     },
//                   ),
//                   SizedBox(height: 22),

//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       defulttext(
//                         context: context,
//                         data: "Don't have an account?",
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           navigat(context, widget: Signupview());
//                         },
//                         child: defulttext(
//                           context: context,
//                           data: "Sign Up",
//                           color: AppColors.lightPrimaryColor,
//                           fSize: 16,
//                           fw: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 22),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       Container(
//                         height: 1,
//                         width: screensize(context).width * 0.4,
//                         color: Colors.black,
//                       ),
//                       defulttext(context: context, data: "OR"),
//                       Container(
//                         height: 1,
//                         width: screensize(context).width * 0.4,
//                         color: Colors.black,
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 22),
//                   if (!isHuawei)
//                     GestureDetector(
//                       onTap: () async {
//                         cubit.signinWithGoogle();
//                       },
//                       child: sgininContainer(
//                         icon: Assets.assetsImagesGoogleIconSvg,
//                         text: "Sign in with Google",
//                       ),
//                     ),
//                   GestureDetector(
//                     onTap: () {
//                       cubit.signinWithFacebook();
//                     },
//                     child: sgininContainer(
//                       icon: Assets.assetsImagesFacebookIconSvg,
//                       text: "Sign in with facebook",
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
// ========================================
// 📁 lib/feature/auth/presentation/pages/sign_in_page.dart
// ========================================
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shop_app/core/di/injection.dart';
import 'package:shop_app/core/routing/appRoutHelper.dart';
import 'package:shop_app/core/utils/SignigContainer.dart';
import 'package:shop_app/core/utils/app_colors.dart';
import 'package:shop_app/core/utils/app_images.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/core/utils/custom_button.dart';
import 'package:shop_app/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:shop_app/feature/auth/presentation/widgets/signUpBody.dart';
import 'package:shop_app/feature/admin/presentation/view/adminScreen.dart';
import 'package:shop_app/feature/mainview/presentation/pages/layoutScreen.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key, required this.isHuawei});

  final bool isHuawei;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: Scaffold(
      
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
        
  if (state is AuthAuthenticated) {
    Fluttertoast.showToast(
      msg: "Sign in Success - ${AppRouter.getUserRoleName(state.user)}",
      backgroundColor: Colors.green,
    );

    // Navigate based on user type
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AppRouter.getHomeScreenForUser(state.user),
      ),
    );
  } else if (state is AuthError) {
    Fluttertoast.showToast(
      msg: state.message,
      backgroundColor: Colors.red,
    );
  }
},        
          builder: (context, state) {
            final cubit = context.read<AuthCubit>();

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: cubit.signInFormKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 44),

                      // Email Field
                      defulitTextFormField(
                        controller: cubit.signInEmailController,
                        context: context,
                        hintText: "Email",
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // Password Field
                      defulitTextFormField(
                        controller: cubit.signInPasswordController,
                        context: context,
                        hintText: "Password",
                        isobscure: !cubit.isPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            cubit.isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: cubit.togglePasswordVisibility,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // Forget Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              // TODO: Implement forgot password
                            },
                            child: defulttext(
                              context: context,
                              data: "Forget Password?",
                              color: AppColors.lightPrimaryColor,
                              fSize: 16,
                              fw: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Sign In Button
                      if (state is AuthLoading)
                        const CircularProgressIndicator()
                      else
                        CustomButton(
                          text: "Sign In",
                          onPressed: cubit.signIn,
                        ),

                      const SizedBox(height: 22),

                      // Navigate to Sign Up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          defulttext(
                            context: context,
                            data: "Don't have an account?",
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignUpPage(),
                                ),
                              );
                            },
                            child: defulttext(
                              context: context,
                              data: "Sign Up",
                              color: AppColors.lightPrimaryColor,
                              fSize: 16,
                              fw: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // OR Divider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            height: 1,
                            width: screensize(context).width * 0.4,
                            color: Colors.grey,
                          ),
                          defulttext(context: context, data: "OR"),
                          Container(
                            height: 1,
                            width: screensize(context).width * 0.4,
                            color: Colors.grey,
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Google Sign In
                      if (!isHuawei)
                        GestureDetector(
                          onTap: cubit.signInWithGoogle,
                          child: sgininContainer(
                            icon: Assets.assetsImagesGoogleIconSvg,
                            text: "Sign in with Google",
                          ),
                        ),

                      // Facebook Sign In
                      GestureDetector(
                        onTap: () {
                          // TODO: Implement Facebook sign in
                        },
                        child: sgininContainer(
                          icon: Assets.assetsImagesFacebookIconSvg,
                          text: "Sign in with Facebook",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}