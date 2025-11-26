import '../../../account/data/models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  otpSent,
  authenticated,
  invalidOtp,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  // ---------------------- Constructors ----------------------

  const AuthState.initial()
      : status = AuthStatus.initial,
        user = null,
        errorMessage = null;

  const AuthState.loading()
      : status = AuthStatus.loading,
        user = null,
        errorMessage = null;

  const AuthState.otpSent()
      : status = AuthStatus.otpSent,
        user = null,
        errorMessage = null;

  const AuthState.authenticated(UserModel u)
      : status = AuthStatus.authenticated,
        user = u,
        errorMessage = null;

  const AuthState.invalidOtp()
      : status = AuthStatus.invalidOtp,
        user = null,
        errorMessage = "Geçersiz OTP";

  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        user = null,
        errorMessage = null;

  const AuthState.error(String msg)
      : status = AuthStatus.error,
        user = null,
        errorMessage = msg;
}
