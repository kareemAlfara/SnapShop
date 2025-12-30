import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shop_app/core/utils/app_colors.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/feature/auth/data/repository/repo_impl.dart';
import 'package:shop_app/feature/auth/domain/usecases/EmailSignUsecase.dart';
import 'package:shop_app/feature/auth/domain/usecases/uploadImageusecase.dart';
import 'package:shop_app/feature/auth/presentation/cubit/signup_cubit/signup_cubit.dart';
import 'package:shop_app/feature/auth/presentation/widgets/registerImage.dart';
import 'package:shop_app/feature/mainview/presentation/pages/layoutScreen.dart';
import '../../../../core/utils/custom_button.dart';

class SignupbodyWidget extends StatelessWidget {
  const SignupbodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignupCubit(
        Emailsignupusecase(repo: RepoImpl()),
        Uploaduserimageusecase(RepoImpl()),
      ),
      child: BlocConsumer<SignupCubit, SignupState>(
        listener: (context, state) {
          if (state is SignupSuccessState) {
            Fluttertoast.showToast(
              msg: " Sign Up Success",
              backgroundColor: Colors.green,
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Layoutscreen()),
            );
          } else if (state is SignupErrorState) {
            Fluttertoast.showToast(
              msg: " ${state.message}",
              backgroundColor: Colors.red,
            );
          }
          // TODO: implement listener
        },
        builder: (context, state) {
          var cubit = SignupCubit.get(context);
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Form(
                key: cubit.formKey,
                child: Column(
                  children: [
                    SizedBox(height: 29),
                    registerImage(cubit: cubit),
                    SizedBox(height: 10),
                    defulitTextFormField(
                      controller: cubit.namecontroller,
                      context: context,
                      hintText: "Name",
                    ),
                    SizedBox(height: 10),
                    defulitTextFormField(
                      controller: cubit.emailcontroller,
                      context: context,
                      hintText: "Email",
                    ),
                    SizedBox(height: 10),
                    defulitTextFormField(
                      keyboardType: TextInputType.phone,
                      controller: cubit.phonecontroller,
                      context: context,
                      hintText: "phone",
                    ),

                    SizedBox(height: 10),
                    defulitTextFormField(
                      controller: cubit.passwordcontroller,
                      context: context,
                      hintText: "Password",
                      suffixIcon: Icon(Icons.visibility),
                    ),
                    SizedBox(height: 10),

                    SizedBox(height: 22),

                    CustomButton(
                      text: "Sign Up",
                      onPressed: () {
                        if (cubit.formKey.currentState!.validate()) {
                          cubit.signup(
                            email: cubit.emailcontroller.text,
                            password: cubit.passwordcontroller.text,
                            name: cubit.namecontroller.text,
                            phone: cubit.phonecontroller.text,
                          );
                          cubit.emailcontroller.clear();
                          cubit.passwordcontroller.clear();
                          cubit.namecontroller.clear();
                        }
                      },
                    ),
                    SizedBox(height: 22),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("I have an account"),
                        TextButton(
                          onPressed: () {},
                          child: defulttext(
                            context: context,
                            data: "Sign in",
                            color: AppColors.lightPrimaryColor,
                            fSize: 16,
                            fw: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 22),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
