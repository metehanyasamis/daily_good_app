import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dio_provider.dart';

/// PayTR mobil ödeme: POST /customer/mobile/checkout
final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  return CheckoutRepository(ref.watch(dioProvider));
});

class CheckoutRepository {
  final Dio _dio;

  CheckoutRepository(this._dio);

  static const String _pathMobileCheckout = '/customer/mobile/checkout';

  /// POST /customer/mobile/checkout
  /// Body: store_id, total_amount, payment_method, payment_data, items
  /// Response: { success: true, checkout_url: "..." }
  Future<String> createMobileCheckout(Map<String, dynamic> body) async {
    final res = await _dio.post(_pathMobileCheckout, data: body);
    if (res.data['success'] != true) {
      throw Exception(res.data['message'] ?? 'Checkout başarısız');
    }
    final url = res.data['checkout_url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('Checkout URL alınamadı');
    }
    return url;
  }
}
