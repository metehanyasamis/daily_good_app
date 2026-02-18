import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/platform/platform_widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/providers/order_provider.dart';
import '../../data/models/order_list_item.dart';
import '../widgets/montly_order_group.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormatter = DateFormat('dd MMMM yyyy', 'tr_TR');
    final summaryAsync = ref.watch(orderHistoryProvider);

    return summaryAsync.when(
        loading: () => Scaffold(
          appBar: _buildAppBar(),
          body: Center(child: PlatformWidgets.loader()),
        ),
        error: (err, _) => Scaffold(
          appBar: _buildAppBar(),
          body: Center(child: Text('Siparişler yüklenirken bir hata oluştu:\n$err')),
        ),
        data: (summary) {
          final orders = summary.orders;
          if (orders.isEmpty) {
            return Scaffold(
              appBar: _buildAppBar(),
              body: const Center(child: Text('Henüz geçmiş siparişiniz bulunmamaktadır.')),
            );
          }

          final Map<String, List<OrderListItem>> grouped = {};
          for (final order in orders) {
            final key = DateFormat('MMMM yyyy', 'tr_TR').format(order.createdAt);
            grouped.putIfAbsent(key, () => []).add(order);
          }

          return Scaffold(
            appBar: _buildAppBar(),
            backgroundColor: Colors.grey.shade100,
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _metric("Toplam Tasarruf", "${summary.totalSavings.toStringAsFixed(0)} ₺"),
                      _metric("Karbon Kazancı", "${summary.carbonFootprintSaved.toStringAsFixed(1)} kg"),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    children: grouped.entries.map((entry) {
                      return MonthlyOrderGroup(
                        monthTitle: entry.key[0].toUpperCase() + entry.key.substring(1),
                        orders: entry.value,
                        dateFormatter: dateFormatter,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.greenAppBarTheme.backgroundColor,
      foregroundColor: AppTheme.greenAppBarTheme.foregroundColor,
      systemOverlayStyle: AppTheme.greenAppBarTheme.systemOverlayStyle,
      iconTheme: AppTheme.greenAppBarTheme.iconTheme,
      titleTextStyle: AppTheme.greenAppBarTheme.titleTextStyle,
      centerTitle: AppTheme.greenAppBarTheme.centerTitle,
      title: const Text('Geçmiş Siparişlerim'),
    );
  }
}

// -----------------------------------------------------------------------------
// 🚀 DİKKAT: BU FONKSİYONLAR CLASS DIŞINDA (TOP-LEVEL) OLMALI
// -----------------------------------------------------------------------------

Widget buildOrderCard({
  required BuildContext context,
  required OrderListItem order,
  required DateFormat dateFormatter,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: AppColors.primaryDarkGreen.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.storefront_rounded, color: AppColors.primaryDarkGreen),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.storeName, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 16)),
              const SizedBox(height: 4),
              Text('${dateFormatter.format(order.createdAt)} • ${order.itemsCount} Paket', // "Adet" yerine "Paket" daha net
                  style: const TextStyle(color: Colors.black54, fontSize: 13)),
              const SizedBox(height: 2),
              Text("No: ${order.orderNumber}",
                  style: const TextStyle(color: AppColors.primaryDarkGreen, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Row(
          children: [
            metricColumn(icon: Icons.shopping_bag_outlined, value: '${order.itemsCount}', label: 'Ürün'),
            const SizedBox(width: 8),
            metricColumn(icon: Icons.payments_outlined, value: '${order.totalAmount.toStringAsFixed(0)} ₺', label: 'Tutar'),
            const Icon(Icons.chevron_right, color: AppColors.primaryDarkGreen),
          ],
        ),
      ],
    ),
  );
}

Widget metricColumn({required IconData icon, required String value, required String label}) {
  return Column(
    children: [
      Icon(icon, size: 24, color: AppColors.primaryDarkGreen),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryDarkGreen, fontSize: 12)),
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
    ],
  );
}