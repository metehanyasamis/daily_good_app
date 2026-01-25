/*import 'package:flutter_riverpod/flutter_riverpod.dart';
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

 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order_summary_response.dart';
import '../../data/models/order_details_response.dart';
import '../../data/repository/order_repository.dart';

// Tüm geçmişi getiren mevcut provider
final orderHistoryProvider = FutureProvider<OrderSummaryResponse>((ref) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getOrdersSummary();
});

// Tekil detay getiren mevcut provider
final orderDetailProvider = FutureProvider.family<OrderDetailResponse, String>((ref, id) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getOrderDetail(id);
});

/// 🔥 YENİ: Aktif (teslim edilmemiş) tüm siparişleri detaylarıyla getiren liste
final activeOrdersProvider = FutureProvider<List<OrderDetailResponse>>((ref) async {
  final repo = ref.watch(orderRepositoryProvider);

  // 1. Özet listeyi çek
  final summary = await repo.getOrdersSummary();

  // 2. Sadece aktif olanların (delivered olmayanların) ID'lerini al
  final activeIds = summary.orders
      .where((o) => o.status != 'delivered' && o.status != 'cancelled')
      .map((o) => o.id.toString())
      .toList();

  if (activeIds.isEmpty) return [];

  // 3. Her bir aktif ID için detay servisine git (paralel istek)
  final detailList = await Future.wait(
    activeIds.map((id) => repo.getOrderDetail(id)),
  );

  ref.keepAlive();

  return detailList;
});