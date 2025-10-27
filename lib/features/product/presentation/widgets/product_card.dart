
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
// BusinessModel ve findBusinessById fonksiyonunu kullanmak için import
import '../../../businessShop/data/mock/mock_businessShop_model.dart';
import '../../../businessShop/data/model/businessShop_model.dart';
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

    // businessId ile BusinessModel'i bul
    final BusinessModel? business = findBusinessById(p.businessId);

    // İşletme bulunamazsa kartı göstermemek en güvenlisidir.
    if (business == null) {
      return const SizedBox.shrink();
    }

    // BusinessModel'den çekilecek veriler
    final String logoPath = business.businessShopLogoImage;
    final String brandName = business.name;
    final double rating = business.rating;
    final double distanceKm = business.distance;


    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Dış kenar boşluğu
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // Taşan Column
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          // Buradaki Column'un içerikleri
          children: [
            // Üst Kısım: Banner Resmi ve Stok Etiketi
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Image.asset(
                    p.bannerImage,
                    height: 145,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  // 🟢 Stok Etiketi
                  Positioned(
                    top: 10,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        p.stockLabel,
                        style: const TextStyle(
                          color: AppColors.primaryDarkGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  // 🟢 Logo + Marka Adı (sol alt)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child: Image.asset(
                              logoPath,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Gölge efektiyle okunabilir brand name
                        Text(
                          brandName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 0),
                                blurRadius: 4,
                                color: Colors.black87,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Alt Kısım: Detaylar
            // Package name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12,),
              child: Row(
                children: [
                  Text(
                    product.packageName,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const Spacer(),

                  // Prices

                  Text(
                    '${product.oldPrice.toStringAsFixed(2)} ₺',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      //fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${product.newPrice.toStringAsFixed(2)} ₺',
                    style: TextStyle(
                      fontSize: 17,
                      color: AppColors.primaryDarkGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                ],
              ),
            ),

            // Pickup time, rating & distance
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                product.pickupTimeText,
                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
              ),
            ),
            // Alt Bilgi: Puan ve Mesafe
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
              child: Row(
                children: [
                  // Puan
                  Icon(Icons.star, size: 14, color: AppColors.primaryDarkGreen),
                  const SizedBox(width: 8),
                  // rating BusinessModel'den çekildi
                  Text(
                    rating.toStringAsFixed(1),
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '|',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Mesafe
                  Icon(Icons.place, size: 14, color: AppColors.primaryDarkGreen),
                  const SizedBox(width: 4),
                  // distanceKm BusinessModel'den çekildi
                  Text(
                    '${distanceKm.toStringAsFixed(1)} km',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ],
              ),
            ),
            // 🟢 ÇÖZÜM: Column'un sonunda bir miktar boşluk bırakarak taşmayı engelledik.
          ],
        ),
      ),
    );
  }
}

