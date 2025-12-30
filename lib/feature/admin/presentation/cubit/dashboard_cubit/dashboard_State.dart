part of 'dashboard_cubit.dart';

@immutable
sealed class DashboardState {}

final class RegisterInitial extends DashboardState {}
final class PassowrdMethodstate extends DashboardState {}

final class createuserloading extends DashboardState {}
final class createproductuccess extends DashboardState {}
final class changefeaturedcheckiconstate extends DashboardState {}
final class changeorginiccheckiconstate extends DashboardState {}

final class createuserfailier extends DashboardState {
  final String error;

  createuserfailier({required this.error});
}
final class getAllproductSuccessState extends DashboardState {}

final class getAllproductFailureState extends DashboardState {
  final String error;

  getAllproductFailureState({required this.error});
}
final class PickImageSuccessState extends DashboardState {}

final class PickImageFailureState extends DashboardState {
  final String error;

  PickImageFailureState({required this.error});
}
