import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/payment_service.dart';

final paymentProvider =
StateNotifierProvider<PaymentNotifier, AsyncValue<bool>>((ref) {
  return PaymentNotifier(ref);
});

class PaymentNotifier extends StateNotifier<AsyncValue<bool>> {
  final Ref ref;
  PaymentNotifier(this.ref) : super(const AsyncData(false));

  Future<void> makePayment({
    required String holder,
    required String number,
    required String expiry,
    required String cvv,
    required double amount,
  }) async {
    state = const AsyncLoading();

    try {
      final success = await ref.read(paymentServiceProvider).processPayment(
        cardNumber: number,
        holderName: holder,
        expiry: expiry,
        cvv: cvv,
        amount: amount,
      );

      if (success) {
        // 🔹 önce success state gönder
        state = const AsyncData(true);


        // 🔹 burada kontrol et
        print("🟢 STATE: ${state.runtimeType} | value: ${(state is AsyncData) ? (state as AsyncData).value : null}");

        // 🔹 küçük bir gecikmeden sonra idle duruma dön
        await Future.delayed(const Duration(milliseconds: 500));
        state = const AsyncData(false);
      } else {
        state = AsyncError('payment_failed', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void reset() => state = const AsyncData(false);
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});
