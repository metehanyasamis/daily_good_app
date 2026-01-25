// lib/features/cart/domain/providers/checkout_contracts_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dio_provider.dart';
import '../models/checkout_contracts_model.dart';

final checkoutContractsProvider = FutureProvider.family<CheckoutContractsModel, String?>((ref, cartId) async {
  final dio = ref.watch(dioProvider);

  final Map<String, dynamic> queryParams = {};
  if (cartId != null && cartId.isNotEmpty) {
    queryParams['cart_id'] = cartId;
  }

  // 🔥 Dökümana göre endpoint: /settings/contracts
  final response = await dio.get(
    '/settings/contracts',
    queryParameters: queryParams,
  );

  return CheckoutContractsModel.fromJson(response.data);
});