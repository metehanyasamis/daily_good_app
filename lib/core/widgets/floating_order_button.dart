import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../../features/orders/providers/order_provider.dart';

class FloatingOrderButton extends ConsumerWidget {
  const FloatingOrderButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasActive = ref.watch(hasActiveOrderProvider);

    if (!hasActive) return const SizedBox.shrink();

    return Positioned(
      right: 0, // 🔥 Sağ duvara sıfır yasla
      bottom: MediaQuery.of(context).padding.bottom + 90,
      child: Container(
        alignment: Alignment.centerRight, // 🔥 Sağ hizalama garantisi
        child: ElevatedButton.icon(
          onPressed: () => context.push('/order-tracking'),
          icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
          label: const Text(
            'Siparişimi Takip Et',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDarkGreen,
            minimumSize: const Size(0, 48), // 🔥 genişlik esnek, taşma yok
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
            elevation: 8,
          ),
        ),
      ),
    );
  }
}
