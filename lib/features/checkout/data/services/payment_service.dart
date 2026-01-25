
import 'dart:math';

import 'package:flutter/material.dart';

// -----------------------------
// Mock payment service (no storage)
// -----------------------------
class PaymentService {

  Future<bool> processPayment({
    required String cardNumber,
    required String holderName,
    required String expiry,
    required String cvv,
    required double amount,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    // fake simple success rule: if last digit even -> success
    final last = cardNumber.trim().isNotEmpty ? cardNumber.trim().characters.last : '0';
    final isEven = int.tryParse(last) != null && int.parse(last) % 2 == 0;

    // Randomize a bit so you'll sometimes see failures
    final random = Random();
    final chance = random.nextDouble();

    return isEven || chance > 0.7;
  }
}
