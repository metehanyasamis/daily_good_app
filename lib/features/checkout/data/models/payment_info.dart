class PaymentInfo {
  final String method;
  final String methodLabel;
  final String status;
  final String statusLabel;
  final double amount;

  PaymentInfo({
    required this.method,
    required this.methodLabel,
    required this.status,
    required this.statusLabel,
    required this.amount,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      method: json['payment_method'] ?? '',
      methodLabel: json['payment_method_label'] ?? '',
      status: json['payment_status'] ?? '',
      statusLabel: json['payment_status_label'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
