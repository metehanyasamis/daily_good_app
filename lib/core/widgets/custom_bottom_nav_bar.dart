// lib/core/widgets/custom_bottom_nav_bar.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material( // beyaz oval bar
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white, // bar’ın beyaz zemini
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
            bottomLeft: Radius.circular(36),
            bottomRight: Radius.circular(36),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
             // spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _item(0, Icons.home_outlined,   'ANASAYFA'),
            _item(1, Icons.search,          'KEŞFET'),
            _item(2, Icons.favorite_border, 'FAVORİ'),
            _item(3, Icons.person_outline,  'HESAP'),
          ],
        ),
      ),
    );
  }

  Widget _item(int index, IconData icon, String label) {
    final bool selected = currentIndex == index;

    // genişliği biraz azalttık, overflow çözülür
    // 👇 her item’a özel genişlik (en uzun yazı ANASAYFA)
    final double width = selected
        ? (index == 0
        ? 130 // ANASAYFA için
        : index == 3
        ? 120 // HESAP için
        : 115) // diğerleri
        : 60;

    // 👇 offset’i de sağa sola göre ayarla
    final double leftOffset = (index == 0)
        ? 28 // home biraz içerde olsun
        : (index == 3)
        ? 24 // hesap sağda, daha az taşsın
        : 30;

    return SizedBox(
      width: width,
      height: 48,
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            // kapsül (arkada)
            if (selected)
              Positioned(
                left: 33, // 👈 yazı biraz sağa kayar, ikonun altına girmez
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightGreen,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      //color: Colors.black87,
                    ),
                  ),
                ),
              ),

            // ikon (önde)
            Positioned(
              left: 0,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: selected
                      ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2A8A49), Color(0xFF4CB06A)],
                  )
                      : null,
                  color: selected ? null : Colors.black.withValues(alpha: 0.06),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                    if (selected)
                      BoxShadow(
                        color: AppColors.primaryDarkGreen.withValues(alpha: 0.20),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 25,
                  color: selected ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
