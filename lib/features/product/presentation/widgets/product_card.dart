import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/fav_button.dart';
import '../../../../core/widgets/animated_toast.dart';
import '../../../businessShop/data/mock/mock_businessShop_model.dart';
import '../../../businessShop/data/model/businessShop_model.dart';
import '../../data/models/product_model.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFav = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    final BusinessModel? business = findBusinessById(p.businessId);
    if (business == null) return const SizedBox.shrink();

    final String logoPath = business.businessShopLogoImage;
    final String brandName = business.name;
    final double rating = p.rating;
    final double distanceKm = p.distance;


    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🟢 Üst Kısım (Banner + Logo + Favori Butonu)
            ClipRRect(
              borderRadius: const BorderRadius.only(
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

                  // 🟢 Stok etiketi
                  Positioned(
                    top: 10,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
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

                  // 🩶 Favori Butonu (sağ üst)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: FavButton(
                      isFav: isFav,
                      context: context,
                      onToggle: () {
                        setState(() => isFav = !isFav);
                        widget.product.isFav = isFav; // 🔹 modele de yaz
                        showAnimatedToast(
                          context,
                          isFav ? 'Favorilere eklendi 💚' : 'Favorilerden kaldırıldı ❌',
                        );
                      },
                      size: 34,
                    ),
                  ),

                  // 🟢 Logo + Marka
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

            // 🧾 Paket Adı + Fiyat
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text(
                    p.packageName,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const Spacer(),
                  Text(
                    '${p.oldPrice.toStringAsFixed(2)} ₺',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${p.newPrice.toStringAsFixed(2)} ₺',
                    style: const TextStyle(
                      fontSize: 17,
                      color: AppColors.primaryDarkGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ⏰ Teslimat Zamanı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                p.pickupTimeText,
                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
              ),
            ),

            // ⭐ Puan ve Mesafe
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
              child: Row(
                children: [
                  Icon(Icons.star,
                      size: 14, color: AppColors.primaryDarkGreen),
                  const SizedBox(width: 8),
                  Text(
                    rating.toStringAsFixed(1),
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                  const SizedBox(width: 6),
                  const Text('|', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Icon(Icons.place,
                      size: 14, color: AppColors.primaryDarkGreen),
                  const SizedBox(width: 4),
                  Text(
                    '${distanceKm.toStringAsFixed(1)} km',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
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
