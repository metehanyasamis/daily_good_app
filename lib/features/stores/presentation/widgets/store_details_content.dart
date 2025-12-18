import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
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
          _ratingCard(ratings),
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

  Widget _productList(List<ProductModel> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Seni bekleyen lezzetler",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),

        ...products.map((product) {
          return GestureDetector(
            onTap: () => onProductTap?.call(product),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(product.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${product.listPrice} ₺",
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough),
                      ),
                      Text(
                        "${product.salePrice} ₺",
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDarkGreen),
                      ),
                    ],
                  )
                ],
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

  Widget _ratingCard(AverageRatingsModel? ratings) {
    if (ratings == null) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("İşletme Değerlendirme",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _ratingRow("Servis", ratings.service),
          _ratingRow("Ürün Miktarı", ratings.productQuantity),
          _ratingRow("Ürün Lezzeti", ratings.productTaste),
          _ratingRow("Ürün Çeşitliliği", ratings.productVariety),
        ],
      ),
    );
  }

  Widget _ratingRow(String label, double rating) {
    final r = rating.clamp(0, 5);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 130, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: r / 5,
              backgroundColor: Colors.grey.shade200,
              color: AppColors.primaryDarkGreen,
            ),
          ),
          const SizedBox(width: 8),
          Text(r.toStringAsFixed(1)),
        ],
      ),
    );
  }
}
