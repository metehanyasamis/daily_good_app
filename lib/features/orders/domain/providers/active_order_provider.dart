import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order_details_response.dart';
import '../../data/repository/order_repository.dart';

final activeOrderProvider =
FutureProvider.family<OrderDetailResponse, String>((ref, orderId) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getOrderDetail(orderId);
});
