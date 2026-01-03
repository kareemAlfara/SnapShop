part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthImageUploading extends AuthState {}

class AuthImageUploaded extends AuthState {
  final String imageUrl;

  const AuthImageUploaded(this.imageUrl);

  @override
  List<Object?> get props => [imageUrl];
}

class AuthPasswordVisibilityChanged extends AuthState {
  final bool isVisible;

  const AuthPasswordVisibilityChanged(this.isVisible);

  @override
  List<Object?> get props => [isVisible];
}