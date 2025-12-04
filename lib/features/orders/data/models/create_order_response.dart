// lib/features/orders/data/models/create_order_response.dart
import 'order_detail_model.dart';

class CreateOrderResponse {
  final OrderDetailItem detail;

  CreateOrderResponse({required this.detail});

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      detail: OrderDetailItem.fromJson(json['data']),
    );
  }
}
