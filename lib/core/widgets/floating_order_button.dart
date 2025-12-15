import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/orders/domain/providers/order_provider.dart';
import '../theme/app_theme.dart';

class FloatingOrderButton extends ConsumerWidget {
  const FloatingOrderButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasActiveOrder = ref.watch(orderHistoryProvider).maybeWhen(
      data: (summary) =>
          summary.orders.any((o) => o.status == 'pending'),
      orElse: () => false,
    );




    if (!hasActiveOrder) return const SizedBox.shrink();

    return Positioned(
      right: 0,
      bottom: MediaQuery.of(context).padding.bottom + 90,
      child: ElevatedButton.icon(
        onPressed: () => context.push('/order-tracking'),
        icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
        label: const Text(
          'Siparişimi Takip Et',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDarkGreen,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              bottomLeft: Radius.circular(30),
            ),
          ),
        ),
      ),
    );
  }
}
