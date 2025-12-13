import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/providers/order_provider.dart';
import '../../data/models/order_list_item.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormatter = DateFormat('dd MMMM yyyy', 'tr_TR');
    final summaryAsync = ref.watch(orderHistoryProvider);

    return summaryAsync.when(
      // ---------------- LOADING ----------------
      loading: () => Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),

      // ---------------- ERROR ----------------
      error: (err, _) => Scaffold(
        appBar: _buildAppBar(),
        body: Center(
          child: Text(
            'Siparişler yüklenirken bir hata oluştu:\n$err',
            textAlign: TextAlign.center,
          ),
        ),
      ),

      // ---------------- DATA ----------------
        data: (summary) {
          final orders = summary.orders;

          if (orders.isEmpty) {
            return Scaffold(
              appBar: _buildAppBar(),
              body: const Center(
                child: Text('Henüz geçmiş siparişiniz bulunmamaktadır.'),
              ),
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
                // 🔥 TOPLAM TASARRUF & KARBON (backend)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _metric(
                        "Toplam Tasarruf",
                        "${summary.totalSavings.toStringAsFixed(0)} ₺",
                      ),
                      _metric(
                        "Karbon Kazancı",
                        "${summary.carbonFootprintSaved.toStringAsFixed(1)} kg",
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: grouped.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              entry.key[0].toUpperCase() + entry.key.substring(1),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...entry.value.map(
                                (order) => GestureDetector(
                              onTap: () =>
                                  context.push('/orders/${order.id}'),
                              child: _buildOrderCard(
                                context: context,
                                order: order,
                                dateFormatter: dateFormatter,
                              ),
                            ),
                          ),
                        ],
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

  // ---------------- METRICS HELPER ----------------

  Widget _metric(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }


  // ---------------- APPBAR ----------------
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      centerTitle: true,
      backgroundColor: AppColors.primaryDarkGreen,
      title: const Text(
        'Geçmiş Siparişlerim',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  // ---------------- ORDER CARD ----------------
  Widget _buildOrderCard({
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
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🟢 Logo yerine generic ikon (list endpoint’te logo yok)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryDarkGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: AppColors.primaryDarkGreen,
            ),
          ),
          const SizedBox(width: 10),

          // 🟢 İşletme + tarih
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormatter.format(order.createdAt),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Sipariş No: ${order.orderNumber}",
                  style: const TextStyle(
                    color: AppColors.primaryDarkGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Sağ blok (tasarruf yerine backend alanlarını kullanıyoruz)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _metricColumn(
                icon: Icons.shopping_bag_outlined,
                value: '${order.itemsCount}',
                label: 'Ürün',
              ),
              const SizedBox(width: 8),
              _metricColumn(
                icon: Icons.payments_outlined,
                value: '${order.totalAmount.toStringAsFixed(0)} ₺',
                label: 'Tutar',
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                color: AppColors.primaryDarkGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔸 Sağdaki küçük bilgi kolonları
  Widget _metricColumn({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 24, color: AppColors.primaryDarkGreen),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDarkGreen,
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
