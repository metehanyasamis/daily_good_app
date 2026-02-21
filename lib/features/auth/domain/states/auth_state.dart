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
  final Map<String, dynamic>? socialUserData; // verify-token'dan gelen data

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.socialUserData,
  });

  // ---------------------- copyWith (EN KRİTİK METOD) ----------------------
  // Mevcut verileri koruyarak sadece istediğimiz alanları günceller.
  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    Map<String, dynamic>? socialUserData,
    bool clearErrorMessage = false,
    bool clearSocialUserData = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      socialUserData: clearSocialUserData ? null : (socialUserData ?? this.socialUserData),
    );
  }

  // ---------------------- Constructors ----------------------
  // Not: Bunlar nesneyi SIFIRDAN yaratır. Sosyal veri varken copyWith tercih edilmelidir.

  const AuthState.initial()
      : status = AuthStatus.initial,
        user = null,
        errorMessage = null,
        socialUserData = null;

  const AuthState.loading()
      : status = AuthStatus.loading,
        user = null,
        errorMessage = null,
        socialUserData = null;

  const AuthState.otpSent()
      : status = AuthStatus.otpSent,
        user = null,
        errorMessage = null,
        socialUserData = null;

  const AuthState.authenticated([UserModel? u])
      : status = AuthStatus.authenticated,
        user = u,
        errorMessage = null,
        socialUserData = null;

  const AuthState.invalidOtp()
      : status = AuthStatus.invalidOtp,
        user = null,
        errorMessage = "Geçersiz OTP",
        socialUserData = null;

  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        user = null,
        errorMessage = null,
        socialUserData = null;

  const AuthState.error(String msg)
      : status = AuthStatus.error,
        user = null,
        errorMessage = msg,
        socialUserData = null;

  // ---------------------- UI Helper Getters ----------------------

  bool get isLoading => status == AuthStatus.loading;
  bool get isOtpSent => status == AuthStatus.otpSent;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get hasError => status == AuthStatus.error;
}