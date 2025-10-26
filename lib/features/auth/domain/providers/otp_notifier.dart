import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../states/otp_state.dart';

class OtpNotifier extends StateNotifier<OtpState> {
  final Ref _ref; // ➡️ ref tutuldu

  OtpNotifier(this._ref) : super(OtpState());

  Future<void> verifyCode(String code) async {
    state = state.copyWith(isVerifying: true, errorMessage: null);

    // Simülasyon: 1 sn gecikme + sahte doğrulama
    await Future.delayed(const Duration(seconds: 1));

    if (code == '12345') {
      state = state.copyWith(isVerifying: false, isVerified: true);
    } else {
      state = state.copyWith(
        isVerifying: false,
        errorMessage: 'Kod hatalı, tekrar deneyin.',
      );
    }
  }

  void reset() {
    state = OtpState();
  }
}


final otpNotifierProvider = StateNotifierProvider<OtpNotifier, OtpState>((ref) => OtpNotifier(ref));
