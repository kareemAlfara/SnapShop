import 'package:supabase_flutter/supabase_flutter.dart';

String handleAuthError(AuthException e) {
  switch (e.message) {
    case 'Invalid login credentials':
      return 'Incorrect email or password.';
    case 'User already registered':
      return 'This email is already registered.';
    case 'Email not confirmed':
      return 'Please verify your email first.';
    default:
      return 'Something went wrong. Please try again.';
  }
}