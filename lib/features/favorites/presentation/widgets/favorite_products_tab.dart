import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class FavoriteProductsTab extends StatelessWidget {
  const FavoriteProductsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> products = [
      {
        'title': 'Sandviç Kutusu',
        'shop': 'Bite and Go',
        'image': 'assets/images/sample_food.jpg',
        'price': '40',
        'distance': '0.9 km',
      },
      {
        'title': 'Vegan Kek',
        'shop': 'Green Café',
        'image': 'assets/images/sample_food2.jpg',
        'price': '25',
        'distance': '1.3 km',
      },
    ];

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (ctx, i) {
        final item = products[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(item['image']!, width: 60, height: 60, fit: BoxFit.cover),
          ),
          title: Text(item['title']!),
          subtitle: Text('${item['shop']} • ${item['distance']}'),
          trailing: IconButton(
            icon: const Icon(Icons.favorite, color: AppColors.primaryDarkGreen),
            onPressed: () {
              // favoriden çıkar
            },
          ),
          onTap: () {
            // ürün detayına git
          },
        );
      },
    );
  }
}
