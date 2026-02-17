// lib/features/product/presentation/widgets/product_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/platform/platform_widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/fav_button.dart';
import '../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final oldPrice = product.listPrice;
    final newPrice = product.salePrice;

    final discount = oldPrice > 0
        ? ((oldPrice - newPrice) / oldPrice * 100).round()
        : 0;


    final stockLabel = _stockLabel(product.stock);

    // Store logo: backend varsa buradan çek
    // StoreSummary içinde brand.logoUrl vb yoksa fallback olur.
    final storeLogoUrl = _tryGetStoreLogoUrl(product);

    return GestureDetector(
      onTap: onTap ?? () => context.push('/product-detail/${product.id}'),
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ------------------------------------------------------------
            // BANNER
            // ------------------------------------------------------------
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  NetworkImageOrPlaceholder(
                    url: product.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),

                  // SOLD / STOCK LABEL (sold out vs son x)
                  Positioned(
                    top: 10,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        stockLabel,
                        style: const TextStyle(
                          color: AppColors.primaryDarkGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  // DISCOUNT BADGE (eski kartta yoktu ama istersen kalsın)
                  if (discount > 0)
                    Positioned(
                      top: 10,
                      right: 54, // fav ile çakışmasın
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDarkGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "-$discount%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                  // FAVORITE
                  Positioned(
                    top: 8,
                    right: 8,
                    child: FavButton(
                      id: product.id,
                      isStore: false, // 👈 Mutlaka ekle: Bu bir üründür
                    ),
                  ),

                  // STORE LOGO + STORE NAME (banner üstüne binen kısım)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child: NetworkImageOrPlaceholder(
                              url: storeLogoUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              fallbackIcon: Icons.store,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            product.store.name,
                            maxLines: 1, // Tek satırda tut
                            overflow: TextOverflow.ellipsis, // Sığmazsa ... yap
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ------------------------------------------------------------
            // CONTENT: name + pickup + price
            // ------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // LEFT
                  Expanded(
                    child: // lib/features/product/presentation/widgets/product_card.dart içinde ilgili bölüm:

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4), // Boşluğu biraz artırdık
                        Row(
                          children: [
                            const Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: Colors.grey
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                product.deliveryTimeLabel,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ),
                  const SizedBox(width: 10),

                  // RIGHT (prices)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${oldPrice.toStringAsFixed(2)} ₺',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${newPrice.toStringAsFixed(2)} ₺',
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

            const SizedBox(height: 2),

            // ------------------------------------------------------------
            // BOTTOM LINE: distance + rating
            // ------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8), // Alt boşluğu biraz artırdık
              child: Row(
                children: [
                  // MESAFE
                  const Icon(Icons.place, size: 14, color: AppColors.primaryDarkGreen),
                  const SizedBox(width: 4),
                  Text(
                    product.store.distanceKm != null
                        ? '${product.store.distanceKm!.toStringAsFixed(1)} km'
                        : '-',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),

                  // AYIRAÇ NOKTASI
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text("|", style: TextStyle(color: Colors.grey.shade400)),
                  ),

                  // PUAN (RATING)
                  const Icon(Icons.star, size: 14, color: Colors.amber), // Figma'daki sarı yıldız
                  const SizedBox(width: 4),
                  Text(
                    product.store.overallRating != null
                        ? product.store.overallRating!.toStringAsFixed(1)
                        : '0.0',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  String _stockLabel(int stock) {
    if (stock <= 0) return 'Tükendi';
    if (stock <= 3) return 'Son $stock';
    return '$stock adet';
  }

  String _tryGetStoreLogoUrl(ProductModel p) {
    // StoreSummary modelinde brand/logo alanı varsa burayı ona göre güncellersin.
    // Şimdilik: store.imageUrl varsa onu kullanıyoruz.
    final url = p.store.imageUrl;
    return url;
  }
}

class NetworkImageOrPlaceholder extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData fallbackIcon;

  const NetworkImageOrPlaceholder({
    super.key,
    required this.url,
    this.width,
    this.height,
    required this.fit,
    this.fallbackIcon = Icons.image_not_supported,
  });

  @override
  Widget build(BuildContext context) {
    final u = (url ?? '').trim();

    if (u.isEmpty) {
      return _buildFallback();
    }

    return CachedNetworkImage(
      imageUrl: u,
      width: width,
      height: height,
      fit: fit,
      // 🚀 RESİM YÜKLENİRKEN GÖSTERİLECEK (Saniyeler süren o boşluğu bu kapatır)
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey.shade100,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: PlatformWidgets.loader(
              strokeWidth: 2,
              color: AppColors.primaryLightGreen,
              radius: 10, // iOS için uygun boyut
            ),
          ),
        ),
      ),
      // ❌ HATA OLURSA GÖSTERİLECEK
      errorWidget: (context, url, error) => _buildFallback(),
      // 💾 ÖNBELLEK AYARI
      memCacheHeight: 400, // RAM kullanımını optimize etmek için resmi küçülterek sakla
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(fallbackIcon, color: Colors.grey),
    );
  }
}