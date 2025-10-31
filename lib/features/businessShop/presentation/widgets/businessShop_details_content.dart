// 🔹 Detay içeriği (figma uyumlu, ürünlerle tam)
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../product/data/models/product_model.dart';
import '../../data/model/businessShop_model.dart';

class BusinessShopDetailsContent extends StatelessWidget {
  final BusinessModel businessShop;
  final void Function(ProductModel product)? onProductTap;

  const BusinessShopDetailsContent({
    super.key,
    required this.businessShop,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🟢 Ana kart: işletme + “seni bekleyen lezzetler”
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🏪 Üst Bilgi
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage:
                      AssetImage(businessShop.businessShopLogoImage),
                    ),
                    const SizedBox(width: 12),

                    // 🔹 Orta alan
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  businessShop.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${businessShop.distance.toStringAsFixed(1)} km",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  color: AppColors.primaryDarkGreen, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  businessShop.address,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time_outlined,
                                  color: AppColors.primaryDarkGreen, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                "Çalışma Saatleri: ${businessShop.workingHours}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // ⭐ Rating alanı (figma'ya göre)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDarkGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            businessShop.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            " (70+)",
                            style: TextStyle(
                                fontSize: 11, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade300, height: 1),
                const SizedBox(height: 12),

                // 🍽️ Başlık
                const Text(
                  "Seni bekleyen lezzetler",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                // 🍔 Ürün listesi
                ...businessShop.products.map((product) {
                  return GestureDetector(
                    onTap: () => onProductTap?.call(product),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              product.bannerImage,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.packageName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  product.pickupTimeText,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${product.oldPrice.toStringAsFixed(0)} ₺",
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                "${product.newPrice.toStringAsFixed(0)} ₺",
                                style: const TextStyle(
                                  color: AppColors.primaryDarkGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right,
                              color: Colors.black54, size: 22),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          const SizedBox(height: 20),

           // 🌱 Bilgi alanı
             _infoCard(),

          const SizedBox(height: 20),

          // ⭐ Değerlendirme Kartı
          _ratingCard(context),
        ],
      ),
    );
  }

  // 🧩 Yardımcı widgetlar
  Widget _infoCard() {
    return // 🌱 Bilgi kartı (tek container içinde iki satır)
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.recycling_rounded,
                    color: AppColors.primaryDarkGreen, size: 28),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    '1+ yıldır israfla mücadelede',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.eco_rounded,
                    color: AppColors.primaryDarkGreen, size: 28),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    '250+ yemek kurtarıldı',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
  }

  Widget _ratingCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "İşletme Değerlendirme",
                style:
                TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.info_outline,
                  size: 16, color: Colors.grey),
              const Spacer(),
              const Icon(Icons.star,
                  color: Colors.amber, size: 18),
              const SizedBox(width: 2),
              Text(
                businessShop.rating.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(" (70+)",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          _ratingRow("Servis", 4.5),
          _ratingRow("Ürün Miktarı", 5.0),
          _ratingRow("Ürün Lezzeti", 5.0),
          _ratingRow("Ürün Çeşitliliği", 4.0),
        ],
      ),
    );
  }

  Widget _ratingRow(String label, double rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 130, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: rating / 5,
              backgroundColor: Colors.grey[200],
              color: AppColors.primaryDarkGreen,
              minHeight: 6,
            ),
          ),
          const SizedBox(width: 8),
          Text(rating.toStringAsFixed(1)),
        ],
      ),
    );
  }
}
