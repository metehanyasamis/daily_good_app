import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../model/business_model.dart';

class BusinessDetailContent extends StatelessWidget {
  final BusinessModel business;

  const BusinessDetailContent({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 📸 Kapak görseli
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: Image.asset(
            business.image,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(business.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('${business.distance.toStringAsFixed(1)} km • ${business.address}',
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 6),
              Text('Çalışma Saatleri: ${business.workingHours}',
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber[600], size: 20),
                  const SizedBox(width: 4),
                  Text('${business.rating.toStringAsFixed(1)} (70+)'),
                ],
              ),
              const SizedBox(height: 16),

              const Text("Seni bekleyen lezzetler",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),

              const SizedBox(height: 12),

              ...business.products.map((product) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          product.logoImage,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.packageName,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(product.pickupTimeText,
                                style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${product.oldPrice.toStringAsFixed(0)} ₺',
                              style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 12,
                                  color: Colors.grey)),
                          Text('${product.newPrice.toStringAsFixed(0)} ₺',
                              style: TextStyle(
                                  color: AppColors.primaryDarkGreen,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}
