import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/delivery_date_formatter.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/widgets/navigation_link.dart';
import '../../../product/data/models/product_model.dart';
import '../../data/model/store_detail_model.dart';

class StoreDetailsContent extends StatelessWidget {
  final StoreDetailModel storeDetail;
  final void Function(ProductModel product)? onProductTap;

  const StoreDetailsContent({
    super.key,
    required this.storeDetail,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final products = storeDetail.products ?? [];
    final ratings = storeDetail.averageRatings;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 20),
          _productList(products),
          const SizedBox(height: 20),
          _infoCard(),
          const SizedBox(height: 20),
          //_ratingCard(ratings),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeDetail.name,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: AppColors.primaryDarkGreen),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        storeDetail.address,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 6),

                NavigationLink(
                  address: storeDetail.address,
                  latitude: storeDetail.latitude,
                  longitude: storeDetail.longitude,
                  label: storeDetail.name,
                  textStyle: const TextStyle(
                    color: AppColors.primaryDarkGreen,
                    decoration: TextDecoration.underline,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 6),

              ],
            ),
          ),

          // RATING BADGE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryDarkGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  storeDetail.overallRating.toStringAsFixed(1),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  " (${storeDetail.totalReviews})",
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// StoreDetailsContent.dart içindeki _productList metodunu bununla değiştir:

  Widget _productList(List<ProductModel> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Seni bekleyen lezzetler",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        ...products.map((product) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onProductTap?.call(product),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // 1. Ürün Görseli
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Builder(builder: (ctx) {
                        final safeUrl = sanitizeImageUrl(product.imageUrl?.isNotEmpty == true ? product.imageUrl : null);
                        if (safeUrl == null) {
                          return Image.asset('assets/images/sample_food3.jpg', width: 48, height: 48, fit: BoxFit.cover);
                        }
                        return Image.network(
                          safeUrl,
                          width: 48, height: 48, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset('assets/images/sample_food3.jpg', width: 48, height: 48, fit: BoxFit.cover),
                        );
                      }),
                    ),
                    const SizedBox(width: 12),

                    // 2. Ürün Bilgileri (İsim + Teslimat Saati)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // 🔥 Teslimat Saati Geri Geldi
                          Text(
                            formatDeliveryDate(product.startDate, product.startHour, product.endHour),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // 3. Fiyat Bilgisi
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (product.listPrice != null && product.listPrice! > 0)
                          Text(
                            "${product.listPrice!.toStringAsFixed(2)} ₺",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          "${product.salePrice?.toStringAsFixed(2) ?? '-'} ₺",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDarkGreen,
                          ),
                        ),
                      ],
                    ),

                    // 4. Ok İkonu
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        children: [
          Text("1+ yıldır israfla mücadelede"),
          SizedBox(height: 10),
          Text("250+ yemek kurtarıldı"),
        ],
      ),
    );
  }

}


