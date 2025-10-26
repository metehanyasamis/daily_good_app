import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../businessShop/data/mock/mock_businessShop_model.dart';
import '../../../businessShop/data/model/businessShop_model.dart';

class FavoriteShopsTab extends StatelessWidget {
  const FavoriteShopsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<BusinessModel> favoriteShops =
    mockBusinessList.where((b) => b.rating >= 4.6).toList();

    if (favoriteShops.isEmpty) return _buildEmptyState(context);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: favoriteShops.length,
      itemBuilder: (context, index) {
        final shop = favoriteShops[index];
        return GestureDetector(
          onTap: () => context.push('/business-detail', extra: shop),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Image.asset(
                    shop.businessShopLogoImage,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(shop.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(shop.address,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star,
                                size: 14, color: AppColors.primaryDarkGreen),
                            const SizedBox(width: 4),
                            Text(shop.rating.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 10),
                            Icon(Icons.place,
                                size: 14, color: AppColors.primaryDarkGreen),
                            const SizedBox(width: 4),
                            Text('${shop.distance.toStringAsFixed(1)} km',
                                style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite,
                      color: AppColors.primaryDarkGreen),
                  onPressed: () {
                    // TODO: favoriden çıkarma işlemi
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.store_mall_directory_outlined,
                size: 64, color: AppColors.primaryDarkGreen),
            const SizedBox(height: 16),
            Text(
              'Henüz favori işletmen yok 🍽️\nHemen keşfetmeye başla!',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
