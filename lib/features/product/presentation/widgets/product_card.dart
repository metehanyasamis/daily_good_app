// lib/features/product/presentation/widgets/product_card.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/fav_button.dart';
import '../../../../core/widgets/circular_shop_image.dart'; // CircularShopImage

import '../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = product;
    final store = p.store; // 🔥 API'den gelen gömülü Store bilgisi

    // 💡 Artık BusinessModel'i mock'tan çekmiyoruz.
    // BusinessModel yerine ProductStoreModel kullanacağız.

    // final String logoPath = store.brand.logoUrl ?? 'assets/images/placeholder_logo.png'; // Eğer asset değil URL ise
    final String logoPath = store.brand.logoUrl ?? 'assets/logos/default_brand.png'; // Geçici olarak bir asset varsayalım
    final String brandName = store.brand.name;
    // ⭐ Rating (puan) ve karbon tasarrufu bilgisi API yanıtında yok. 
    // Eğer bunlar kritikse, backend ile konuşulup eklenmelidir.
    // Şimdilik rating için sabit bir değer kullanalım veya kaldırın.
    const double mockRating = 4.5; // API'den gelmeyene kadar

    final double distanceKm = p.distance; // ProductModel içindeki getter

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
            ),
          ],
        ),
        // 🔹 Fix: Kartın içi artık Scroll değil, shrink-wrap yüksekliğiyle sınırlı
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🖼️ Banner kısmı
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    // 🔥 Resim URL'ini kullanmak için NetworkImage/CachedNetworkImage gerekli
                    Image.network(
                      p.imageUrl,
                      height: 125,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      // Hata durumunda placeholder göstermek faydalıdır
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 125,
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                    // 🏷️ stok etiketi
                    Positioned(
                      top: 10,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          p.stockLabel, // 🔥 Getter'dan geldi
                          style: const TextStyle(
                            color: AppColors.primaryDarkGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    // ❤️ favori butonu
                    Positioned(
                      top: 8,
                      right: 8,
                      child: FavButton(
                        item: product,
                        size: 34,
                      ),
                    ),
                    // 🧁 marka alanı
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Row(
                        children: [
                          // 🔥 Logo için URL kullanıyoruz
                          BusinessLogo(
                            imagePath: logoPath,
                            isAsset: false, // NetworkImage kullan
                            size: 46,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            brandName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black87,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // 🧾 Paket + Fiyat
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name, // 🔥 API'den gelen "name"
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p.pickupTimeText, // 🔥 Getter'dan geldi
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${p.listPrice.toStringAsFixed(2)} ₺',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${p.salePrice.toStringAsFixed(2)} ₺',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDarkGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),


              // ⭐ puan ve mesafe
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: Row(
                  children: [
                    Icon(Icons.star, size: 14, color: AppColors.primaryDarkGreen),
                    const SizedBox(width: 8),
                    // 🔥 Mock rating yerine sabit değer
                    Text(
                      mockRating.toStringAsFixed(1),
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    ),
                    const SizedBox(width: 6),
                    const Text('|', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Icon(Icons.place, size: 14, color: AppColors.primaryDarkGreen),
                    const SizedBox(width: 4),
                    Text(
                      '${distanceKm.toStringAsFixed(1)} km', // 🔥 Getter'dan geldi
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}