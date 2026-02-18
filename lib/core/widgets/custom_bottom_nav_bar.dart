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
            Expanded(flex: currentIndex == 0 ? 2 : 1, child: _item(0, Icons.home_outlined,   'ANASAYFA')),
            Expanded(flex: currentIndex == 1 ? 2 : 1, child: _item(1, Icons.search,          'KEŞFET')),
            Expanded(flex: currentIndex == 2 ? 2 : 1, child: _item(2, Icons.favorite_border, 'FAVORİ')),
            Expanded(flex: currentIndex == 3 ? 2 : 1, child: _item(3, Icons.person_outline,  'HESAP')),
          ],
        ),
      ),
    );
  }

  Widget _item(int index, IconData icon, String label) {
    final bool selected = currentIndex == index;

    return GestureDetector( // SizedBox'ı kaldırdık, Expanded sayesinde alanı Row belirleyecek
      onTap: () => onTabSelected(index),
      child: Container(
        height: 48,
        color: Colors.transparent, // Tıklama alanını genişletmek için
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            if (selected)
              Positioned(
                left: 20, // İkonun biraz altından başlasın
                right: 0,  // Metnin sağa taşmasını engellemek için sağ sınırı belirle
                child: Container(
                  padding: const EdgeInsets.only(left: 28, right: 12, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightGreen,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // 🔥 Sığmazsa "ANAS..." yapar, taşırmaz!
                    style: const TextStyle(
                      fontSize: 12, // Yazıyı biraz küçültmek güvenli olur
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
