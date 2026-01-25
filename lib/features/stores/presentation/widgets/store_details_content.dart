import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/widgets/navigation_link.dart';
import '../../../product/data/models/product_model.dart';
import '../../../review/presentation/widgets/store_rating_bars.dart';
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
    final products = storeDetail.products;
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
          _combinedInfoAndRatingCard(context, ratings),
        ],
      ),
    );
  }

  // --- HEADER & PRODUCT LIST (Değişmedi, sadece context eklendi) ---

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(storeDetail.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primaryDarkGreen),
                    const SizedBox(width: 4),
                    Expanded(child: Text(storeDetail.address, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))),
                  ],
                ),
                NavigationLink(
                  address: storeDetail.address,
                  latitude: storeDetail.latitude,
                  longitude: storeDetail.longitude,
                  label: storeDetail.name,
                  textStyle: const TextStyle(color: AppColors.primaryDarkGreen, decoration: TextDecoration.underline, fontSize: 13),
                ),
              ],
            ),
          ),
          _ratingBadge(),
        ],
      ),
    );
  }

  Widget _ratingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.primaryDarkGreen, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(storeDetail.overallRating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(" (${storeDetail.totalReviews})", style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _productList(List<ProductModel> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Seni bekleyen lezzetler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...products.map((product) => _productCard(product)),
      ],
    );
  }

  Widget _productCard(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => onProductTap?.call(product),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              sanitizeImageUrl(product.imageUrl) ?? '',
              width: 60, height: 60, fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Image.asset('assets/images/sample_food3.jpg'),
            ),
          ),
          title: Text(product.name , style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("Teslimat: ${product.startHour} - ${product.endHour}", style: const TextStyle(fontSize: 12)),
          trailing: _priceRow(product),
        ),
      ),
    );
  }

  Widget _priceRow(ProductModel product) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (product.listPrice > 0 && product.listPrice > product.salePrice)
              Text(
                "${product.listPrice} TL",
                style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    fontSize: 11,
                    color: Colors.grey
                ),
              ),
            Text(
              "${product.salePrice} TL",
              style: const TextStyle(
                  color: AppColors.primaryDarkGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      ],
    );
  }

  // --- REFACTORED RATING CARD ---

  Widget _combinedInfoAndRatingCard(BuildContext context, AverageRatingsModel? ratings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Satır: Kuruluş tarihinden gelen yıl hesabı
          _infoRow(
            Icons.timer_outlined,
            "${storeDetail.struggleYears} yıldır israfla mücadelede",
          ),

          const SizedBox(height: 16),

          // 2. Satır: total_order parametresinden gelen yemek sayısı
          _infoRow(
            Icons.shopping_basket_outlined,
            "${storeDetail.totalOrder} yemek kurtarıldı",
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1, color: Color(0xFFF1F1F1)),
          ),

          // Alt Kısım: Rating Bar'lar (Yorum sayısını burada kendi yerinde kullanıyoruz)
          if (ratings != null)
            StoreRatingBars(
              storeId: storeDetail.id,
              overallRating: storeDetail.overallRating,
              totalReviews: storeDetail.totalReviews, // Değerlendirme sayısı burada kalmalı
              ratings: ratings,
              onTap: () {
                context.pushNamed(
                  AppRoutes.storeReviews,
                  pathParameters: {'id': storeDetail.id},
                );
              },
            )
        ],
      ),
    );
  }


  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryDarkGreen, size: 24),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      ],
    );
  }
}