import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class FavoriteShopsTab extends StatelessWidget {
  const FavoriteShopsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> shops = [
      {
        'name': 'Dönerix',
        'category': 'Yemek',
        'image': 'assets/images/shop1.jpg',
        'rating': '4.7',
        'distance': '1.1 km',
      },
      {
        'name': 'Manav Ali',
        'category': 'Market & Manav',
        'image': 'assets/images/shop2.jpg',
        'rating': '4.5',
        'distance': '0.6 km',
      },
    ];

    return ListView.builder(
      itemCount: shops.length,
      itemBuilder: (ctx, i) {
        final item = shops[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(item['image']!, width: 60, height: 60, fit: BoxFit.cover),
          ),
          title: Text(item['name']!),
          subtitle: Text('${item['category']} • ${item['distance']}'),
          trailing: IconButton(
            icon: const Icon(Icons.favorite, color: AppColors.primaryDarkGreen),
            onPressed: () {
              // favoriden çıkar
            },
          ),
          onTap: () {
            // işletme detayına git
          },
        );
      },
    );
  }
}
