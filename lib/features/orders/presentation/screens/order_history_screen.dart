import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/platform/platform_widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/providers/order_provider.dart';
import '../../data/models/order_list_item.dart';
import '../widgets/montly_order_group.dart';

/*
class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormatter = DateFormat('dd MMMM yyyy', 'tr_TR');
    final summaryAsync = ref.watch(orderHistoryProvider);

    return summaryAsync.when(
      loading: () => Scaffold(
        appBar: _buildAppBar(context),
        body: Center(child: PlatformWidgets.loader()),
      ),
      error: (err, _) => Scaffold(
        appBar: _buildAppBar(context),
        body: Center(
          child: Text('Siparişler yüklenirken bir hata oluştu:\n$err'),
        ),
      ),
      data: (summary) {
        final orders = summary.orders;
        if (orders.isEmpty) {
          return Scaffold(
            appBar: _buildAppBar(context),
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
          appBar: _buildAppBar(context),
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              const SizedBox(height: 10),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  children: grouped.entries.map((entry) {
                    return MonthlyOrderGroup(
                      monthTitle:
                          entry.key[0].toUpperCase() + entry.key.substring(1),
                      orders: entry.value,
                      dateFormatter: dateFormatter,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 20,
          color: AppColors.textSecondary,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "Geçmiş Siparişlerim",
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
    );
  }
}
*/

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormatter = DateFormat('dd MMMM yyyy', 'tr_TR');
    final summaryAsync = ref.watch(orderHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      // 🚀 Yeni CustomAppBar kullanımı - Tek satırda işi bitirdik!
      appBar: const CustomAppBar(title: 'Geçmiş Siparişlerim'),

      body: summaryAsync.when(
        loading: () => Center(child: PlatformWidgets.loader()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Siparişler yüklenirken bir hata oluştu:\n$err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ),
        data: (summary) {
          final orders = summary.orders;

          if (orders.isEmpty) {
            return const Center(
              child: Text(
                'Henüz geçmiş siparişiniz bulunmamaktadır.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            );
          }

          // 🗓️ Aylara göre gruplama mantığı
          final Map<String, List<OrderListItem>> grouped = {};
          for (final order in orders) {
            final key = DateFormat('MMMM yyyy', 'tr_TR').format(order.createdAt);
            grouped.putIfAbsent(key, () => []).add(order);
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            children: grouped.entries.map((entry) {
              return MonthlyOrderGroup(
                monthTitle: entry.key[0].toUpperCase() + entry.key.substring(1),
                orders: entry.value,
                dateFormatter: dateFormatter,
              );
            }).toList(),
          );
        },
      ),
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
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 6,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primaryDarkGreen.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.storefront_rounded,
            color: AppColors.primaryDarkGreen,
          ),
        ),
        const SizedBox(width: 10),
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
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${dateFormatter.format(order.createdAt)}',
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                "No: ${order.orderNumber}",
                style: const TextStyle(
                  color: AppColors.primaryDarkGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        Row(
          children: [
            metricColumn(
              icon: Icons.shopping_bag_outlined,
              value: '${order.itemsCount}',
              label: 'Ürün',
            ),
            const SizedBox(width: 8),
            metricColumn(
              icon: Icons.payments_outlined,
              value: '${order.totalAmount.toStringAsFixed(0)} ₺',
              label: 'Tutar',
            ),
            const Icon(Icons.chevron_right, color: Colors.grey,),
          ],
        ),
      ],
    ),
  );
}

Widget metricColumn({
  required IconData icon,
  required String value,
  required String label,
}) {
  return Column(
    children: [
      Icon(icon, size: 22, color: AppColors.primaryDarkGreen),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.primaryDarkGreen,
          fontSize: 12,
        ),
      ),
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
    ],
  );
}
