// ========================================
// 📁 lib/feature/auth/presentation/cubit/auth_cubit.dart
// ========================================
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';
import 'package:shop_app/feature/auth/domain/usecases/EmailSignUsecase.dart';
import 'package:shop_app/feature/auth/domain/usecases/getCurrentUserFromPrefs.dart';
import 'package:shop_app/feature/auth/domain/usecases/googleUsecase.dart';
import 'package:shop_app/feature/auth/domain/usecases/signoutEntity.dart';
import '../../domain/usecases/uploadImageusecase.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final Emailsigninusecase signInUseCase;
  final Emailsignupusecase signUpUseCase;
  final Googleusecase signInWithGoogleUseCase;
  final Signoutusecase signOutUseCase;
  final Getcurrentuserfromprefs getCurrentUserUseCase;
  final Uploaduserimageusecase uploadImageUseCase;

  AuthCubit({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signInWithGoogleUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
    required this.uploadImageUseCase,
  }) : super(AuthInitial());
static AuthCubit get(context) => BlocProvider.of(context);
  // Form keys and controllers
  final signInFormKey = GlobalKey<FormState>();
  final signUpFormKey = GlobalKey<FormState>();

  // Sign In Controllers
  final signInEmailController = TextEditingController();
  final signInPasswordController = TextEditingController();

  // Sign Up Controllers
  final signUpEmailController = TextEditingController();
  final signUpPasswordController = TextEditingController();
  final signUpNameController = TextEditingController();
  final signUpPhoneController = TextEditingController();

  String? uploadedImageUrl;
  bool isPasswordVisible = false;

  // ========================================
  // SIGN IN
  // ========================================
  Future<void> signIn() async {
    if (!signInFormKey.currentState!.validate()) return;

    emit(AuthLoading());

    final result = await signInUseCase.call(
      email: signInEmailController.text.trim(),
      password: signInPasswordController.text,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  // ========================================
  // SIGN UP
  // ========================================
  Future<void> signUp() async {
    if (!signUpFormKey.currentState!.validate()) return;

    emit(AuthLoading());

    final result = await signUpUseCase(
      email: signUpEmailController.text.trim(),
      password: signUpPasswordController.text,
      name: signUpNameController.text.trim(),
      phone: signUpPhoneController.text.trim(),
      image: uploadedImageUrl ?? '',
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  // ========================================
  // GOOGLE SIGN IN
  // ========================================
  Future<void> signInWithGoogle() async {
    emit(AuthLoading());

    final result = await signInWithGoogleUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  // ========================================
  // SIGN OUT
  // ========================================
  Future<void> signOut() async {
    emit(AuthLoading());

    final result = await signOutUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  // ========================================
  // GET CURRENT USER
  // ========================================
Future<UserEntity?> getCurrentUser() async {
  emit(AuthLoading());

  final result = await getCurrentUserUseCase();

  return result.fold(
    (failure) {
      emit(AuthError(failure.message));
      return null; // ✅ Return null on error
    },
    (user) {
      if (user == null) {
        emit(AuthUnauthenticated());
        return null; // ✅ Return null if no user
      } else {
        emit(AuthAuthenticated(user));
        return user; // ✅ Return the actual user
      }
    },
  );
}

  // ========================================
  // IMAGE UPLOAD
  // ========================================
  Future<void> pickAndUploadImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile == null) return;

      emit(AuthImageUploading());

      final result = await uploadImageUseCase(File(pickedFile.path));

      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (imageUrl) {
          uploadedImageUrl = imageUrl;
          emit(AuthImageUploaded(imageUrl!));
        },
      );
    } catch (e) {
      emit(AuthError('Failed to pick image: $e'));
    }
  }

  // ========================================
  // TOGGLE PASSWORD VISIBILITY
  // ========================================
  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    emit(AuthPasswordVisibilityChanged(isPasswordVisible));
  }

  // ========================================
  // CLEAR FORMS
  // ========================================
  void clearSignInForm() {
    signInEmailController.clear();
    signInPasswordController.clear();
  }

  void clearSignUpForm() {
    signUpEmailController.clear();
    signUpPasswordController.clear();
    signUpNameController.clear();
    signUpPhoneController.clear();
    uploadedImageUrl = null;
  }

  @override
  Future<void> close() {
    signInEmailController.dispose();
    signInPasswordController.dispose();
    signUpEmailController.dispose();
    signUpPasswordController.dispose();
    signUpNameController.dispose();
    signUpPhoneController.dispose();
    return super.close();
  }
}