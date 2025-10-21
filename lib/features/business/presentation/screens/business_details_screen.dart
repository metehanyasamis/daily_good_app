import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../model/business_model.dart'; // ProductModel için

class BusinessDetailScreen extends StatelessWidget {
  final BusinessModel business;

  const BusinessDetailScreen({super.key, required this.business});

  @override
  Widget build(BuildContext context) {

    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(business.name),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Kapak görseli
            Image.asset(
              business.image,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),

            // 🔹 Başlık ve temel bilgiler
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          color: AppColors.primaryDarkGreen, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "${business.distance.toStringAsFixed(1)} km • ${business.address}",
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time_outlined,
                          color: AppColors.primaryDarkGreen, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        business.workingHours,
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.star,
                          color: Colors.amber[600], size: 20),
                      const SizedBox(width: 4),
                      Text('${business.rating.toStringAsFixed(1)} (70+)'),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 0),

            // 🔹 Paket Listesi
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Text(
                "Seni bekleyen lezzetler",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...business.products.map((product) {
              return GestureDetector(
                onTap: () =>
                    context.push('/product-detail', extra: product),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            product.logoImage,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.packageName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              const SizedBox(height: 2),
                              Text(product.pickupTimeText,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${product.oldPrice.toStringAsFixed(2)} ₺",
                              style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 12,
                                  color: Colors.grey),
                            ),
                            Text(
                              "${product.newPrice.toStringAsFixed(2)} ₺",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDarkGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // 🔹 İstatistik + Puan Alanı (basit versiyon)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("İşletme Değerlendirme",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildRatingRow("Servis", 4.5),
                  _buildRatingRow("Ürün Miktarı", 5.0),
                  _buildRatingRow("Ürün Lezzeti", 5.0),
                  _buildRatingRow("Ürün Çeşitliliği", 4.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow(String label, double rating) {
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
