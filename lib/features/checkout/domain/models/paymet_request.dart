// lib/features/checkout/domain/models/payment_request.dart
class PaymentRequest {
  final String holderName;
  final String cardNumber;
  final String expiry;
  final String cvv;
  final double amount;

  const PaymentRequest({
    required this.holderName,
    required this.cardNumber,
    required this.expiry,
    required this.cvv,
    required this.amount,
  });
}
