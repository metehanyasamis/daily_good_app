import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../features/cart/domain/providers/cart_provider.dart';
import '../../features/notification/domain/providers/notification_provider.dart';
import '../utils/address_formatter.dart';

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
    final notificationCount = ref.watch(notificationBadgeProvider);
    final double topPadding = MediaQuery.of(context).padding.top;
    final shortAddress = formatShortAddress(address);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white),

      padding: EdgeInsets.only(top: topPadding + 8, left: 16, right: 8, bottom: 8),

      child: SizedBox(
        height: 45,
        child: Stack(
          children: [
            /// 🟢 SOL — LOGO (Kendi yerinde)
            Align(
              alignment: Alignment.centerLeft,
              child: leadingOverride ??
                  Image.asset('assets/logos/dailyGood_tekSaatLogo.png', height: 42),
            ),

            /// 🟡 ORTA — ADRES (EKRANIN TAM MATEMATİKSEL ORTASINDA)
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: onLocationTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.background, // 👈 istediğin arka plan
                    borderRadius: BorderRadius.circular(20), // opsiyonel
                    border: Border.all(color: AppColors.primaryDarkGreen, width: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppColors.primaryDarkGreen),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.32),
                        child: Text(
                          shortAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.primaryDarkGreen, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.primaryDarkGreen),
                    ],
                  ),
                ),
              ),
            ),

            /// 🔴 SAĞ — BİLDİRİM + SEPET (Kendi yerinde ve yapışık)
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIconWithBadge(
                    icon: Icons.notifications_none_rounded,
                    count: notificationCount,
                    onTap: onNotificationsTap,
                    rightPadding: 12,
                  ),

                  const SizedBox(width: 8),

                  _buildIconWithBadge(
                    icon: Icons.shopping_cart_outlined,
                    count: cartCount,
                    onTap: () => context.push('/cart'),
                    rightPadding: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }

  /// 🛠️ ELİPSLEŞMEYEN BADGE VE İKON YAPISI
  Widget _buildIconWithBadge({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
    required double rightPadding,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: rightPadding),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: AppColors.primaryDarkGreen, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            visualDensity: VisualDensity.comfortable
          ),
          if (count > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                // 🚀 Tam yuvarlak (elips değil)
                height: 16,
                width: 16,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
