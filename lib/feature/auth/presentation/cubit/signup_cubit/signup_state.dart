part of 'signup_cubit.dart';

sealed class SignupState {}

final class SignupInitial extends SignupState {}

final class SignupLoadingState extends SignupState {}

final class SignupSuccessState extends SignupState {
  final Future<userentity> user;
  SignupSuccessState(this.user);
}

final class SignupErrorState extends SignupState {
  final String message;
  SignupErrorState(this.message);
  
}
final class PickImageSuccessState extends SignupState {}

final class PickImageFailureState extends SignupState {
  final String error;

  PickImageFailureState({required this.error});
}
