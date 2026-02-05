import 'package:dio/dio.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/models/cart_response_model.dart';

class CartRepository {
  final Dio _dio;
  CartRepository(this._dio);

  // GET
  Future<List<CartItem>> getCart() async {
    final res = await _dio.get('/customer/cart');
    final data = res.data['data'];
    if (data == null) return [];
    final list = data is List ? data : [data];
    final items = <CartItem>[];
    for (final e in list) {
      if (e == null || e is! Map<String, dynamic>) continue;
      try {
        items.add(CartResponseModel.fromJson(Map<String, dynamic>.from(e)).toDomain());
      } catch (_) {
        // Tek bozuk item tüm listeyi düşürmesin
        continue;
      }
    }
    return items;
  }

  // ADD
  Future<bool> add({
    required String productId,
    required int quantity,
    String? notes,
  }) async {
    final res = await _dio.post(
      '/customer/cart/add',
      data: {
        "product_id": productId,
        "quantity": quantity,
        if (notes != null) "notes": notes,
      },
    );

    return res.data['success'] == true;
  }

  // UPDATE QTY
  Future<bool> updateQuantity({
    required String cartItemId,
    required String productId,
    required int quantity,
  }) async {
    final res = await _dio.patch(
      '/customer/cart/update-quantity/$cartItemId',
      data: {
        "product_id": productId,
        "quantity": quantity,
      },
    );

    return res.data['success'] == true;
  }

  // REMOVE
  Future<bool> remove(String cartItemId) async {
    final res = await _dio.delete(
      '/customer/cart/remove/$cartItemId',
    );

    return res.data['success'] == true;
  }
}
