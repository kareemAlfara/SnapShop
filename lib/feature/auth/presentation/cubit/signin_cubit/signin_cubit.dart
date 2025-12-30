import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/feature/auth/domain/entities/userEntity.dart';
import 'package:shop_app/feature/auth/domain/usecases/EmailSignUsecase.dart';
import 'package:shop_app/feature/auth/domain/usecases/facebookUsecase.dart';
import 'package:shop_app/feature/auth/domain/usecases/getCurrentUserFromPrefs.dart';
import 'package:shop_app/feature/auth/domain/usecases/googleUsecase.dart';
import 'package:shop_app/feature/auth/domain/usecases/signoutEntity.dart';
part 'signin_state.dart';
class SigninCubit extends Cubit<SigninState> {
  final Emailsigninusecase emailsigninusecase;
  final Signoutusecase signoutusecase;
  final Facebookusecase facebookusecase;
  final Googleusecase googleusecase;
  final Getcurrentuserfromprefs getcurrentuserfromprefs;

  SigninCubit(
    this.emailsigninusecase,
    this.signoutusecase,
    this.facebookusecase,
    this.googleusecase,
    this.getcurrentuserfromprefs,
  ) : super(SigninInitial());
  static SigninCubit get(context) => BlocProvider.of(context);
  var isObscure = true;
  var emailcontroller = TextEditingController();
  var passwordcontroller = TextEditingController();
  var formkey = GlobalKey<FormState>();
  Future<void> signin({required String email, required String password}) async {
    try {
      emit(SigninLoadingState());
      final result = await emailsigninusecase.call(
        email: email,
        password: password,
      );
      emit(signinSuccessState(result));
    } on Exception catch (e) {
      emit(SigninerrorState(e.toString()));
      // TODO
    }
  }

  void changeObscure() {
    isObscure = !isObscure;
    emit(changeObscurestate());
  }

  Future<void> signOut() async {
    try {
      await signoutusecase.call();
    } catch (e) {
      debugPrint('Sign-out error: $e');
    }
  }

  signinWithGoogle() async {
    try {
      emit(SigninLoadingState());
      final result = await googleusecase.call();
      emit(googleSuccessState(result));
    } on Exception catch (e) {
      emit(googleerrorState(e.toString()));
    }
  }

  signinWithFacebook() async {
    try {
      emit(facebookLoadingState());
      final result = await facebookusecase.call();
      emit(facebookSuccessState(result));
    } on Exception catch (e) {
      emit(facebookerrorState(e.toString()));
    }
  }

Future<userentity?>   getCurrentUserFromPrefs() async {
    var resuit = getcurrentuserfromprefs.call();
    emit(getCurrentUserFromPrefsState());
    return resuit;
  }
void refreshUser() {
  emit(SigninUserUpdated());
}
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
  }
}
