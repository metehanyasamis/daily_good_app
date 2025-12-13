import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../features/cart/domain/providers/cart_provider.dart';
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
                  IconButton(
                    onPressed: onNotificationsTap,
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.primaryDarkGreen,
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
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
}
