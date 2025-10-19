import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CustomHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String address;
  final VoidCallback onLocationTap;
  final VoidCallback onNotificationsTap;

  const CustomHomeAppBar({
    super.key,
    required this.address,
    required this.onLocationTap,
    required this.onNotificationsTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return Container(
      // 👇 Arka plan tamamen şeffaf
      color: Colors.transparent,
        padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // 🔹 tam ortalama
        children: [
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Image.asset(
                  'assets/logos/dailyGood_tekSaatLogo.png',
                  height: 55,
                ),
              ),
            ),
          ),

          // 📍 Ortadaki adres kutusu
          Expanded(
            flex: 2,
            child: Center(
              child: GestureDetector(
                onTap: onLocationTap,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAF7), // çok açık yeşilimsi beyaz, Figma’daki gibi
                    //color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.primaryDarkGreen, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                      /*BoxShadow(
                        color: Colors.white.withValues(alpha: 0.8),
                        blurRadius: 2,
                        offset: const Offset(0, -1),
                      ),

                       */
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on,
                          size: 18, color: AppColors.primaryDarkGreen),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          address,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.primaryDarkGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.primaryDarkGreen, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 🔔 Sağ bildirim ikonu
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: onNotificationsTap,
                icon: const Icon(Icons.notifications_outlined, color: AppColors.primaryDarkGreen,),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
