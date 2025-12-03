import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../favorites/providers/favorites_provider.dart';
import '../../../product/presentation/widgets/product_card.dart';

class FavoriteProductsTab extends ConsumerWidget {
  const FavoriteProductsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // API'den gelen veriye bağlandı
    final favoriteProducts = ref.watch(favoritesProvider.select((s) => s.favoriteProducts));

    if (favoriteProducts.isEmpty) return _buildEmptyState(context);

    return RefreshIndicator(
      // Pull to refresh ekliyoruz
      onRefresh: ref.read(favoritesProvider.notifier).fetchFavoriteProducts,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          12,
          12,
          12,
          MediaQuery.of(context).padding.bottom + 80,
        ),
        itemCount: favoriteProducts.length,
        itemBuilder: (context, index) {
          final product = favoriteProducts[index];
          return ProductCard(
            product: product,
            onTap: () => context.push('/product-detail', extra: product),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_outline_rounded,
                size: 72, color: AppColors.primaryDarkGreen),
            const SizedBox(height: 20),
            Text(
              'Henüz Favori Ürünün Yok 💚',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDarkGreen,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Favorilediğin tüm ürünleri burada görebilirsin.\n'
                  'Ana sayfadan beğendiğin sürpriz paketleri kalple işaretle 💚',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
