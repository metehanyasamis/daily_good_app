import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/models/cart_response_model.dart';

class CartRepository {
  final Dio _dio;

  CartRepository(this._dio);

  // GET /customer/cart
  Future<List<CartItem>> getCart() async {
    try {
      final res = await _dio.get('/customer/cart');

      final list = (res.data['data'] as List)
          .map((e) => CartResponseModel.fromJson(e).toDomain())
          .toList();

      return list;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        debugPrint("⚠ Token geçersiz");
        return [];
      }
      return [];
    }
  }

  // POST /customer/cart/add
  Future<bool> addOrUpdate({
    required String productId,
    required int quantity,
    String? notes,
  }) async {
    final payload = {
      "product_id": productId,
      "quantity": quantity,
      "notes": notes,
    };

    final res = await _dio.post('/customer/cart/add', data: payload);
    return res.data['success'] == true;
  }
}
