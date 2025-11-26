import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../features/cart/domain/providers/cart_provider.dart';

class CustomHomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String address;
  final VoidCallback onLocationTap;
  final VoidCallback onNotificationsTap;

  /// Eğer verilirse logo yerine bunu koyacağız
  final Widget? leadingOverride;

  const CustomHomeAppBar({
    super.key,
    required this.address,
    required this.onLocationTap,
    required this.onNotificationsTap,
    this.leadingOverride,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartCountProvider);
    final double topPadding = MediaQuery.of(context).padding.top;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
        top: topPadding + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// ---------------------------------------------
          /// 🟢 Sol taraf → Logo veya Override
          /// ---------------------------------------------
          leadingOverride ??
              Image.asset(
                'assets/logos/dailyGood_tekSaatLogo.png',
                height: 45,
              ),

          const SizedBox(width: 6),

          /// ------------------------- Orta: Adres kapsülü
          GestureDetector(
            onTap: onLocationTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAF7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryDarkGreen, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on,
                      size: 18, color: AppColors.primaryDarkGreen),
                  const SizedBox(width: 6),
                  Text(
                    address,
                    style: const TextStyle(
                      color: AppColors.primaryDarkGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down,
                      color: AppColors.primaryDarkGreen, size: 20),
                ],
              ),
            ),
          ),

          /// ------------------------- Sağ taraf: Notification + Cart
          Row(
            children: [
              IconButton(
                onPressed: onNotificationsTap,
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.primaryDarkGreen,
                ),
              ),

              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () => context.push('/cart'),
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: AppColors.primaryDarkGreen,
                    ),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
