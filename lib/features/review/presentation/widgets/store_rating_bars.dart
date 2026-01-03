import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/show_rating_info_dialog.dart';
import '../../../stores/data/model/store_detail_model.dart';

class StoreRatingBars extends StatelessWidget {
  final String storeId;
  final double overallRating;
  final int totalReviews;
  final AverageRatingsModel ratings;
  final VoidCallback? onTap;
  final bool showHeader;

  const StoreRatingBars({
    super.key,
    required this.storeId,
    required this.overallRating,
    required this.totalReviews,
    required this.ratings,
    this.onTap,
    this.showHeader = true,
  });


  @override
  Widget build(BuildContext context) {
    final ratingMap = {
      "Servis": ratings.service,
      "Ürün Miktarı": ratings.productQuantity,
      "Ürün Lezzeti": ratings.productTaste,
      "Ürün Çeşitliliği": ratings.productVariety,
    };

    // 🔥 TÜM KOLONU INKWELL İLE SARMALIYORUZ
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      highlightColor: Colors.transparent, // İstersen tıklama efektini özelleştirebilirsin
      splashColor: AppColors.primaryDarkGreen.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 🏷️ SOL TARAF: Başlık ve İkon
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "İşletme Değerlendirme",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      // ℹ️ Bilgi diyaloğu hala çalışır, InkWell ile çakışmaz
                      onTap: () => showRatingInfoDialog(context),
                      child: const Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Colors.grey
                      ),
                    ),
                  ],
                ),

                // ⭐ SAĞ TARAF: Puan ve Ok
                // Buradaki InkWell'i sildik çünkü dışarıya aldık
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.primaryDarkGreen, size: 18),
                    const SizedBox(width: 2),
                    Text(
                      " ${overallRating.toStringAsFixed(1)} ($totalReviews+)",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (onTap != null)
                      const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          // 📊 Barlar
          ...ratingMap.entries.map((entry) => _buildProgressBar(entry.key, entry.value)),
        ],
      ),
    );
  }


  Widget _buildProgressBar(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14))),
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value / 5,
                backgroundColor: Colors.grey.shade100,
                color: AppColors.primaryDarkGreen,
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(value.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}