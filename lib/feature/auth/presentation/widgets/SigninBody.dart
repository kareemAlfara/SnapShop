import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shop_app/core/utils/SignigContainer.dart';
import 'package:shop_app/core/utils/app_colors.dart';
import 'package:shop_app/core/utils/app_images.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/core/utils/custom_button.dart';
import 'package:shop_app/feature/auth/presentation/cubit/signin_cubit/signin_cubit.dart';
import 'package:shop_app/feature/auth/presentation/pages/SignupView.dart';
import 'package:shop_app/feature/mainview/presentation/pages/adminScreen.dart';
import 'package:shop_app/feature/mainview/presentation/pages/layoutScreen.dart';
class SigninBodyWidget extends StatelessWidget {
  const SigninBodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SigninCubit, SigninState>(
      listener: (context, state) {
        if (state is signinSuccessState ||
            state is googleSuccessState ||
            state is facebookSuccessState) {
          Fluttertoast.showToast(
            msg: " Sign in Success",
            backgroundColor: Colors.green,
          );
            const String adminId = '0feb0b5f-1380-4574-8e81-7cdd8e13d147';

            if (state is signinSuccessState && state.user.id == adminId) {

           Navigator.pushReplacement(
                    context,
              MaterialPageRoute(builder: (context) =>  Adminscreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>  Layoutscreen()),
            );
          }
      
          // navigat(context, widget: HomeView());
        } else if (state is SigninerrorState) {
          Fluttertoast.showToast(
            msg: " ${state.message}",
            backgroundColor: Colors.red,
          );
        }
        // TODO: implement listener
      },
      builder: (context, state) {
        var cubit = SigninCubit.get(context);
        return SingleChildScrollView(
          child: Form(
            key: cubit.formkey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(height: 44),
                  defulitTextFormField(
                    controller: cubit.emailcontroller,
                    context: context,
                    hintText: "Email",
                  ),
                  SizedBox(height: 15),

                  defulitTextFormField(
                    controller: cubit.passwordcontroller,
                    context: context,
                    hintText: "Password",
                    suffixIcon: Icon(Icons.visibility),
                  ),
                  SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {},
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
                  SizedBox(height: 22),

                  CustomButton(
                    text: "Sign In",
                    onPressed: () async {
                      if (cubit.formkey.currentState!.validate()) {
                        await cubit.signin(
                          email: cubit.emailcontroller.text,
                          password: cubit.passwordcontroller.text,
                        );
                      }
                  
                        cubit.emailcontroller.clear();
                        cubit.passwordcontroller.clear();
                    
                    },
                  ),
                  SizedBox(height: 22),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      defulttext(
                        context: context,
                        data: "Don't have an account?",
                      ),
                      TextButton(
                        onPressed: () {
                          navigat(context, widget: Signupview());
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
                  SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        height: 1,
                        width: screensize(context).width * 0.4,
                        color: Colors.black,
                      ),
                      defulttext(context: context, data: "OR"),
                      Container(
                        height: 1,
                        width: screensize(context).width * 0.4,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  SizedBox(height: 22),
                  GestureDetector(
                    onTap: () async {
                      cubit.signinWithGoogle();
                    },
                    child: sgininContainer(
                      icon: Assets.assetsImagesGoogleIconSvg,
                      text: "Sign in with Google",
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      cubit.signinWithFacebook();
                    },
                    child: sgininContainer(
                      icon: Assets.assetsImagesFacebookIconSvg,
                      text: "Sign in with facebook",
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
