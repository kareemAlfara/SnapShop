// import 'dart:developer';
// import 'dart:io';
// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shop_app/feature/admin/domain/usecases/uploadAssetsImageUsecase.dart';
// import 'package:shop_app/feature/auth/data/repository/repo_impl.dart';
// import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';
// import 'package:shop_app/feature/auth/domain/usecases/EmailSignUsecase.dart';
// import 'package:shop_app/feature/auth/domain/usecases/uploadImageusecase.dart';

// part 'signup_state.dart';

// class SignupCubit extends Cubit<SignupState> {
//   SignupCubit(this.emailsignupusecase, this.uploadImageUsecase)
//     : super(SignupInitial());
//   final Emailsignupusecase emailsignupusecase;
//   final Uploaduserimageusecase uploadImageUsecase;
//   static SignupCubit get(context) => BlocProvider.of(context);
//   var formKey = GlobalKey<FormState>();
//   var emailcontroller = TextEditingController();
//   var passwordcontroller = TextEditingController();
//   var namecontroller = TextEditingController();
//   var phonecontroller = TextEditingController();

//   signup({
//     required String email,
//     required String password,
//     required String name,
//     required String phone,
//   }) async {
//     try {
//       emit(SignupLoadingState());
//       final result = emailsignupusecase.call(
//         email: email,
//         password: password,
//         image: imageUrl ?? '',
//         name: name,
//         phone: phone,
//       );
//       emit(SignupSuccessState(result));
//     } catch (e) {
//       // TODO
//     }
//   }

//   String? imageUrl;
//   Future<void> pickAndSendImage({required ImageSource source}) async {
//     final picker = ImagePicker();
//     final XFile? pickedFile = await picker.pickImage(source: source);

//     if (pickedFile != null) {
//       File file = File(pickedFile.path);
//       imageUrl = await uploadImageToSupabase(file);
//       if (imageUrl != null) {
//         log(imageUrl.toString());
//         Fluttertoast.showToast(
//           msg: " a profile picture Added",
//           backgroundColor: Colors.green,
//           textColor: Colors.white,
//         );
//       }
//       emit(PickImageSuccessState());
//     }
//   }

//   Future<String?> uploadImageToSupabase(File file) async {
//     try {
//       var response = await uploadImageUsecase.call(file);
//       return response;
//     } catch (e) {
//       print('Upload error: $e');
//       emit(PickImageFailureState(error: e.toString()));
//       return null;
//     }
//   }
// }
