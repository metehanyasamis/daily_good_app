import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/fav_button.dart';
import '../../../favorites/providers/favorites_provider.dart';

class FavoriteShopsTab extends ConsumerWidget {
  const FavoriteShopsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final favoriteShops = favorites.favoriteShops;

    if (favoriteShops.isEmpty) return _buildEmptyState(context);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Row(
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(shop.address,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.star,
                                    size: 14,
                                    color: AppColors.primaryDarkGreen),
                                const SizedBox(width: 4),
                                Text(shop.rating.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 13)),
                                const SizedBox(width: 10),
                                Icon(Icons.place,
                                    size: 14,
                                    color: AppColors.primaryDarkGreen),
                                const SizedBox(width: 4),
                                Text('${shop.distance.toStringAsFixed(1)} km',
                                    style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ❤️ Favori butonu sağ üst
                Positioned(
                  top: 6,
                  right: 6,
                  child: FavButton(
                    item: shop,
                    size: 34,
                  ),
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
