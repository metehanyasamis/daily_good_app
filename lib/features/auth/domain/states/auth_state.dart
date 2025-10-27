// features/auth/domain/states/auth_state.dart

import '../../../account/data/models/user_model.dart';

enum AuthStatus { initial, loading, otpSent, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState._({
    required this.status,
    this.user,
    this.errorMessage,
  });

  const AuthState.initial() : this._(status: AuthStatus.initial);
  const AuthState.loading() : this._(status: AuthStatus.loading);
  const AuthState.authenticated(UserModel user)
      : this._(status: AuthStatus.authenticated, user: user);
  const AuthState.unauthenticated() : this._(status: AuthStatus.unauthenticated);
  const AuthState.error(String message)
      : this._(status: AuthStatus.error, errorMessage: message);
  const AuthState.otpSent() : this._(status: AuthStatus.otpSent);

}
