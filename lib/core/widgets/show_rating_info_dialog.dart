import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

void showRatingInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: EdgeInsets.zero,
      title: Column(
        children: [
          const SizedBox(height: 24),
          // Üst kısma şık bir ikon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryDarkGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: AppColors.primaryDarkGreen,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Puanlama Hakkında",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Puan ortalaması, son 1 yıl içerisinde bu işletmeden sipariş vermiş kullanıcıların deneyimlerine dayanır.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // Kategorileri küçük çipler veya liste gibi göstererek görseli zenginleştirelim
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildCategoryChip("Servis"),
              _buildCategoryChip("Miktar"),
              _buildCategoryChip("Lezzet"),
              _buildCategoryChip("Çeşitlilik"),
            ],
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDarkGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
            ),
            child: const Text(
              "Anladım",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    ),
  );
}

// Dialog içinde kullanılan küçük yardımcı widget
Widget _buildCategoryChip(String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54),
    ),
  );
}

/*
void showRatingInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Puanlama Hakkında"),
      content: const Text(
        "Puan ortalaması, son 1 yıl içerisinde bu işletmeden sipariş vermiş kullanıcıların; "
            "servis hızı, ürün miktarı, lezzet ve çeşitlilik kategorilerinde verdiği puanların "
            "aritmetik ortalaması alınarak hesaplanmaktadır.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Anladım", style: TextStyle(color: AppColors.primaryDarkGreen)),
        ),
      ],
    ),
  );
}

 */