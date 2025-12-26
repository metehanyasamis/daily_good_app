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
          _combinedInfoAndRatingCard(ratings),
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


  // StoreDetailsContent.dart içindeki ilgili kısım
  Widget _productList(List<ProductModel> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Seni bekleyen lezzetler",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...products.map((product) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell( // Kartın tamamını tıklanabilir yapar
            borderRadius: BorderRadius.circular(20),
            onTap: () => onProductTap?.call(product),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  sanitizeImageUrl(product.imageUrl) ?? '',
                  width: 60, height: 60, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset('assets/images/sample_food3.jpg'),
                ),
              ),
              title: Text(
                  product.name ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              subtitle: Text(
                "Bugün teslim al: ${product.startHour} - ${product.endHour}",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              // İkonu ve fiyatı yan yana getiren kısım burası
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (product.listPrice != null)
                        Text(
                            "${product.listPrice} TL",
                            style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                fontSize: 11,
                                color: Colors.grey
                            )
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
                  // İSTEDİĞİN İKON BURADA
                  const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 20
                  ),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }
  Widget _combinedInfoAndRatingCard(AverageRatingsModel? ratings) {
    debugPrint("🏗 [UI_BUILD] Kart çiziliyor. Mağaza: ${storeDetail.name} | Yıl: ${storeDetail.struggleYears}");

    // --- YIL HESAPLAMA MANTIĞI ---
    String struggleYears = "1"; // Varsayılan
    try {
      if (storeDetail.createdAt != null) {
        final createDate = DateTime.parse(storeDetail.createdAt!);
        final now = DateTime.now();
        int difference = now.year - createDate.year;
        // Eğer aynı yıl içindeyse veya 0 çıktıysa "1" kabul ediyoruz
        struggleYears = difference <= 0 ? "1" : difference.toString();
      }
    } catch (e) {
      debugPrint("Yıl hesaplama hatası: $e");
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // DİNAMİK YIL VERİSİ
          _infoRow(
              Icons.timer_outlined,
              "${storeDetail.struggleYears}+ yıldır israfla mücadelede"
          ),

          const SizedBox(height: 16),

          // ŞİMDİLİK STATİK (Backend ile konuşulacak)
          _infoRow(Icons.shopping_basket_outlined, "${storeDetail.totalReviews ?? 0}+ yemek kurtarıldı"),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1, color: Color(0xFFF1F1F1)),
          ),

          // RATING BÖLÜMÜ
          _ratingSection(ratings),
        ],
      ),
    );
  }


  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryDarkGreen, size: 24),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ],
    );
  }

  Widget _ratingSection(AverageRatingsModel? ratings) {
    if (ratings == null) return const SizedBox.shrink();

    final ratingMap = {
      "Servis": ratings.service,
      "Ürün Miktarı": ratings.productQuantity,
      "Ürün Lezzeti": ratings.productTaste,
      "Ürün Çeşitliliği": ratings.productVariety,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "İşletme Değerlendirme",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: AppColors.primaryDarkGreen, size: 18),
                Text(
                  " ${storeDetail.overallRating.toStringAsFixed(1)} (${storeDetail.totalReviews}+)",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...ratingMap.entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(entry.key, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              ),
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: entry.value / 5,
                    backgroundColor: Colors.grey.shade100,
                    color: AppColors.primaryDarkGreen,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                entry.value.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        )),
      ],
    );
  }

}


