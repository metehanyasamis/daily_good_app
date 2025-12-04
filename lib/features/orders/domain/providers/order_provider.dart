import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/order_details_response.dart';
import '../../data/models/order_list_item.dart';
import '../../data/repository/order_repository.dart';

/// Geçmiş siparişler listesi (GET /customer/orders)
final orderHistoryProvider =
FutureProvider<List<OrderListItem>>((ref) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getOrders();
});

/// Tek sipariş detayı (GET /customer/orders/{id})
final orderDetailProvider =
FutureProvider.family<OrderDetailResponse, String>((ref, id) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getOrderDetail(id);
});
