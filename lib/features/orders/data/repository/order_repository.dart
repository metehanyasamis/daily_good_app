import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dio_provider.dart';
import '../models/create_order_request.dart';
import '../models/order_details_response.dart';
import '../models/order_list_item.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final dio = ref.watch(dioProvider); // kendi dio provider’ını kullan
  return OrderRepository(dio);
});

class OrderRepository {
  final Dio _dio;

  OrderRepository(this._dio);

  /// POST /customer/orders
  Future<OrderDetailResponse> createOrder(CreateOrderRequest request) async {
    final res = await _dio.post(
      '/customer/orders',
      data: request.toJson(),
    );

    final data = res.data['data'] as Map<String, dynamic>;
    return OrderDetailResponse.fromJson(data);
  }

  /// GET /customer/orders
  Future<List<OrderListItem>> getOrders({
    int page = 1,
    int perPage = 15,
  }) async {
    final res = await _dio.get(
      '/customer/orders',
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );

    final data = res.data['data'] ?? {};
    final list = data['orders'] as List? ?? [];

    return list.map((e) => OrderListItem.fromJson(e)).toList();
  }

  /// GET /customer/orders/{id}
  Future<OrderDetailResponse> getOrderDetail(String id) async {
    final res = await _dio.get('/customer/orders/$id');
    final data = res.data['data'] as Map<String, dynamic>;
    return OrderDetailResponse.fromJson(data);
  }
}
