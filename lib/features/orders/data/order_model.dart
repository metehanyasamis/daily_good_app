import 'package:flutter/material.dart';

class OrderItem {
  final String id;
  final String productName;
  final double oldPrice;
  final double newPrice;
  final DateTime orderTime;
  final DateTime pickupStart;
  final DateTime pickupEnd;
  final String pickupCode;
  final String businessName;
  final String businessAddress;
  final String businessLogo;
  bool isDelivered;

  OrderItem({
    required this.id,
    required this.productName,
    required this.oldPrice,
    required this.newPrice,
    required this.orderTime,
    required this.pickupStart,
    required this.pickupEnd,
    required this.pickupCode,
    required this.businessName,
    required this.businessAddress,
    required this.businessLogo,
    this.isDelivered = false,
  });

  Duration get remainingTime =>
      pickupEnd.difference(DateTime.now());

  double get progress {
    final total = pickupEnd.difference(orderTime).inSeconds;
    final left = pickupEnd.difference(DateTime.now()).inSeconds;
    if (total <= 0) return 0;
    return (left / total).clamp(0, 1);
  }
}

String generatePickupCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  return List.generate(5,
          (i) => chars[(DateTime.now().millisecondsSinceEpoch + i) % chars.length])
      .join();
}

String generateOrderNumber() =>
    "XAT${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
