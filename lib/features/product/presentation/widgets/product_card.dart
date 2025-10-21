import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ProductModel {
  final String bannerImage;
  final String logoImage;
  final String brandName;
  final String packageName;
  final String pickupTimeText;
  final double rating;
  final double distanceKm;
  final double oldPrice;
  final double newPrice;
  final String stockLabel;

  ProductModel({
    required this.bannerImage,
    required this.logoImage,
    required this.brandName,
    required this.packageName,
    required this.pickupTimeText,
    required this.rating,
    required this.distanceKm,
    required this.oldPrice,
    required this.newPrice,
    required this.stockLabel,
  });
}

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner image + stock label + favorite icon overlay
              Stack(
                children: [
                  Image.asset(
                    product.bannerImage,
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 12,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12))
                      ),
                      child: Text(
                        product.stockLabel,
                        style: TextStyle(
                          color: AppColors.primaryDarkGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: ClipOval(
                      child: Container(
                        alignment: Alignment.center,
                        width: 35,
                        height: 35,
                        color: Colors.white.withValues(alpha: 0.9),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.favorite_border,
                          color: AppColors.primaryDarkGreen,
                          size: 26,
                        ),
                        onPressed: onFavoriteToggle,
                      ),
                    ),
                  ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          ClipOval(
                            child: Container(
                              color: Colors.white, // Arka plan beyaz
                              child: Image.asset(
                                product.logoImage,
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain, // 🔄 Değişiklik burada
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Logo + brand name
                          Expanded(
                            child: Text(
                              product.brandName,
                              //style: AppTextStyles.productBrandName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),


              const SizedBox(height: 4),

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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                child: Row(
                  children: [

                    Icon(Icons.star, size: 14, color: AppColors.primaryDarkGreen),
                    const SizedBox(width: 2),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: TextStyle(fontSize: 12, ),
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
                    Icon(Icons.place, size: 14, color: AppColors.primaryDarkGreen),
                    const SizedBox(width: 2),
                    Text(
                      '${product.distanceKm.toStringAsFixed(1)} km',
                      style: TextStyle(fontSize: 12),
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
