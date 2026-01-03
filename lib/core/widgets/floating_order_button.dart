
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/orders/domain/providers/order_provider.dart';
import '../theme/app_theme.dart';

class FloatingOrderButton extends ConsumerWidget {
  const FloatingOrderButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(orderHistoryProvider).maybeWhen(
      data: (summary) {
        // 🎯 Tam olarak istediğin kurgu:
        final hasActiveOrder = summary.orders.any((o) =>
        o.status == 'pending' ||
            o.status == 'processing' ||
            o.status == 'confirmed'
        );

        if (!hasActiveOrder) {
          return const SizedBox.shrink();
        }

        return Positioned(
          right: 0,
          bottom: MediaQuery.of(context).padding.bottom + 100,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/order-tracking'), // Parametresiz yeni rota
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
            label: const Text(
              'Siparişimi Takip Et',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDarkGreen,
              elevation: 8,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                ),
              ),
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
