// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shop_app/core/utils/app_colors.dart';
// import 'package:shop_app/core/utils/components.dart';
// import 'package:shop_app/feature/auth/data/repository/repo_impl.dart';
// import 'package:shop_app/feature/auth/domain/usecases/EmailSignUsecase.dart';
// import 'package:shop_app/feature/auth/domain/usecases/uploadImageusecase.dart';
// import 'package:shop_app/feature/auth/presentation/cubit/signup_cubit/signup_cubit.dart';
// import 'package:shop_app/feature/auth/presentation/widgets/registerImage.dart';
// import 'package:shop_app/feature/mainview/presentation/pages/layoutScreen.dart';
// import '../../../../core/utils/custom_button.dart';

// class SignupbodyWidget extends StatelessWidget {
//   const SignupbodyWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => SignupCubit(
//         Emailsignupusecase(repo: RepoImpl()),
//         Uploaduserimageusecase(RepoImpl()),
//       ),
//       child: BlocConsumer<SignupCubit, SignupState>(
//         listener: (context, state) {
//           if (state is SignupSuccessState) {
//             Fluttertoast.showToast(
//               msg: " Sign Up Success",
//               backgroundColor: Colors.green,
//             );
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => Layoutscreen()),
//             );
//           } else if (state is SignupErrorState) {
//             Fluttertoast.showToast(
//               msg: " ${state.message}",
//               backgroundColor: Colors.red,
//             );
//           }
//           // TODO: implement listener
//         },
//         builder: (context, state) {
//           var cubit = SignupCubit.get(context);
//           return Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: SingleChildScrollView(
//               child: Form(
//                 key: cubit.formKey,
//                 child: Column(
//                   children: [
//                     SizedBox(height: 29),
//                     registerImage(cubit: cubit),
//                     SizedBox(height: 10),
//                     defulitTextFormField(
//                       controller: cubit.namecontroller,
//                       context: context,
//                       hintText: "Name",
//                     ),
//                     SizedBox(height: 10),
//                     defulitTextFormField(
//                       controller: cubit.emailcontroller,
//                       context: context,
//                       hintText: "Email",
//                     ),
//                     SizedBox(height: 10),
//                     defulitTextFormField(
//                       keyboardType: TextInputType.phone,
//                       controller: cubit.phonecontroller,
//                       context: context,
//                       hintText: "phone",
//                     ),

//                     SizedBox(height: 10),
//                     defulitTextFormField(
//                       controller: cubit.passwordcontroller,
//                       context: context,
//                       hintText: "Password",
//                       suffixIcon: Icon(Icons.visibility),
//                     ),
//                     SizedBox(height: 10),

//                     SizedBox(height: 22),

//                     CustomButton(
//                       text: "Sign Up",
//                       onPressed: () {
//                         if (cubit.formKey.currentState!.validate()) {
//                           cubit.signup(
//                             email: cubit.emailcontroller.text,
//                             password: cubit.passwordcontroller.text,
//                             name: cubit.namecontroller.text,
//                             phone: cubit.phonecontroller.text,
//                           );
//                           cubit.emailcontroller.clear();
//                           cubit.passwordcontroller.clear();
//                           cubit.namecontroller.clear();
//                         }
//                       },
//                     ),
//                     SizedBox(height: 22),

//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text("I have an account"),
//                         TextButton(
//                           onPressed: () {},
//                           child: defulttext(
//                             context: context,
//                             data: "Sign in",
//                             color: AppColors.lightPrimaryColor,
//                             fSize: 16,
//                             fw: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 22),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
// ========================================
// 📁 lib/feature/auth/presentation/pages/sign_up_page.dart
// ========================================
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_app/core/di/injection.dart';
import 'package:shop_app/core/utils/app_colors.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/core/utils/custom_button.dart';
import 'package:shop_app/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:shop_app/feature/mainview/presentation/pages/layoutScreen.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sign Up'),
          centerTitle: true,
        ),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              Fluttertoast.showToast(
                msg: "Sign Up Success",
                backgroundColor: Colors.green,
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Layoutscreen()),
              );
            } else if (state is AuthError) {
              Fluttertoast.showToast(
                msg: state.message,
                backgroundColor: Colors.red,
              );
            } else if (state is AuthImageUploaded) {
              Fluttertoast.showToast(
                msg: "Profile picture added",
                backgroundColor: Colors.green,
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<AuthCubit>();

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: cubit.signUpFormKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 29),

                      // Profile Image Picker
                      GestureDetector(
                        onTap: () => _showImageSourceDialog(context, cubit),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.lightPrimaryColor,
                          backgroundImage: cubit.uploadedImageUrl != null
                              ? NetworkImage(cubit.uploadedImageUrl!)
                              : null,
                          child: cubit.uploadedImageUrl == null
                              ? const Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),

                      if (state is AuthImageUploading)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),

                      const SizedBox(height: 20),

                      // Name Field
                      defulitTextFormField(
                        controller: cubit.signUpNameController,
                        context: context,
                        hintText: "Name",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      // Email Field
                      defulitTextFormField(
                        controller: cubit.signUpEmailController,
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

                      const SizedBox(height: 10),

                      // Phone Field
                      defulitTextFormField(
                        controller: cubit.signUpPhoneController,
                        context: context,
                        hintText: "Phone",
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      // Password Field
                      defulitTextFormField(
                        controller: cubit.signUpPasswordController,
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

                      const SizedBox(height: 22),

                      // Sign Up Button
                      if (state is AuthLoading)
                        const CircularProgressIndicator()
                      else
                        CustomButton(
                          text: "Sign Up",
                          onPressed: cubit.signUp,
                        ),

                      const SizedBox(height: 22),

                      // Navigate to Sign In
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account?"),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: defulttext(
                              context: context,
                              data: "Sign In",
                              color: AppColors.lightPrimaryColor,
                              fSize: 16,
                              fw: FontWeight.w600,
                            ),
                          ),
                        ],
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

  void _showImageSourceDialog(BuildContext context, AuthCubit cubit) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                cubit.pickAndUploadImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                cubit.pickAndUploadImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}