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

  /*
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartCountProvider);
    final notificationCount = ref.watch(notificationBadgeProvider);

    final double topPadding = MediaQuery.of(context).padding.top;
    final shortAddress = formatShortAddress(address);

    return Container(
      padding: EdgeInsets.only(
        top: topPadding + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// =========================
            /// 🟡 ORTA — ADRES (GERÇEK ORTA)
            /// =========================
            GestureDetector(
              onTap: onLocationTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.primaryDarkGreen,
                  ),
                  const SizedBox(width: 4),

                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.40,
                    ),
                    child: Text(
                      shortAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primaryDarkGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 14, // 🔒 SABİT
                      ),
                    ),
                  ),

                  const SizedBox(width: 2),

                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppColors.primaryDarkGreen,
                  ),
                ],
              ),
            ),


            /// =========================
            /// 🟢 SOL — LOGO
            /// =========================
            Positioned(
              left: 0,
              child: leadingOverride ??
                  Image.asset(
                    'assets/logos/dailyGood_tekSaatLogo.png',
                    height: 42,
                  ),
            ),

            /// =========================
            /// 🔴 SAĞ — BİLDİRİM + SEPET
            /// =========================

            Positioned(
              right: 0,
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: onNotificationsTap,
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.primaryDarkGreen,
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 36,
                        ),
                      ),
                      // 🔴 Kırmızı Nokta / Sayı
                      if (notificationCount > 0)
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$notificationCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () => context.push('/cart'),
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          color: AppColors.primaryDarkGreen,
                          size: 22,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                      if (cartCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$cartCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),



          ],
        ),
      ),
    );
  }

   */

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartCountProvider);
    final notificationCount = ref.watch(notificationBadgeProvider);
    final double topPadding = MediaQuery.of(context).padding.top;
    final shortAddress = formatShortAddress(address);

    return Container(
      padding: EdgeInsets.only(top: topPadding + 8, left: 16, right: 16, bottom: 8),
      child: SizedBox(
        height: 48,
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, size: 16, color: AppColors.primaryDarkGreen),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.35),
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

            /// 🔴 SAĞ — BİLDİRİM + SEPET (Kendi yerinde ve yapışık)
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔔 BİLDİRİM (Sepete yaklaştırmak için sağdan padding'i azalttık)
                  _buildIconWithBadge(
                    icon: Icons.notifications_none_rounded,
                    count: notificationCount,
                    onTap: onNotificationsTap,
                    rightPadding: 0, // Sepete yapışması için 0
                  ),

                  // 🛒 SEPET
                  _buildIconWithBadge(
                    icon: Icons.shopping_cart_outlined,
                    count: cartCount,
                    onTap: () => context.push('/cart'),
                    rightPadding: 0,
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
            padding: const EdgeInsets.symmetric(horizontal: 4), // İkonlar arası mesafe burası
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
