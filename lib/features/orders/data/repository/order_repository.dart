import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dio_provider.dart';
import '../models/create_order_request.dart';
import '../models/order_details_response.dart';
import '../models/order_summary_response.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final dio = ref.watch(dioProvider); // kendi dio provider’ını kullan
  return OrderRepository(dio);
});

class OrderRepository {
  final Dio _dio;

  OrderRepository(this._dio);

  /// POST /customer/orders
  Future<OrderDetailResponse> createOrder(
      CreateOrderRequest request,
      ) async {
    try {
      final res = await _dio.post(
        '/customer/orders',
        data: request.toJson(),
      );

      if (res.data['success'] != true) {
        throw Exception(res.data['message'] ?? 'Sipariş oluşturulamadı');
      }

      final data = res.data['data'] as Map<String, dynamic>;
      return OrderDetailResponse.fromJson(data);
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] ?? 'Sipariş sırasında hata oluştu';
      throw Exception(msg);
    }
  }

  /// GET /customer/orders
  Future<OrderSummaryResponse> getOrdersSummary({
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

    if (res.data['success'] != true) {
      throw Exception('Siparişler alınamadı');
    }

    return OrderSummaryResponse.fromJson(res.data['data']);
  }


  /// GET /customer/orders/{id}
  Future<OrderDetailResponse> getOrderDetail(String id) async {
    try {
      final res = await _dio.get('/customer/orders/$id');

      if (res.data['success'] != true) {
        throw Exception('Sipariş bulunamadı');
      }

      final data = res.data['data'] as Map<String, dynamic>;
      return OrderDetailResponse.fromJson(data);
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] ?? 'Sipariş detayı alınamadı';
      throw Exception(msg);
    }
  }
}
