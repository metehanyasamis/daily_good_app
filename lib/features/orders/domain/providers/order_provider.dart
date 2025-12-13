import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order_summary_response.dart';
import '../../data/models/order_details_response.dart';
import '../../data/repository/order_repository.dart';

final orderHistoryProvider =
FutureProvider<OrderSummaryResponse>((ref) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getOrdersSummary();
});

final orderDetailProvider =
FutureProvider.family<OrderDetailResponse, String>((ref, id) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getOrderDetail(id);
});
