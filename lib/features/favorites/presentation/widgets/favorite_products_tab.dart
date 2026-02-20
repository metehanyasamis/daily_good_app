import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/favorites_notifier.dart';
import '../../../product/presentation/widgets/product_card.dart';

class FavoriteProductsTab extends ConsumerWidget {
  const FavoriteProductsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Tüm modelleri ve sadece ürün ID setini izle
    final allProducts = ref.watch(favoritesProvider.select((s) => s.products));
    final favoriteIds = ref.watch(favoritesProvider.select((s) => s.productIds));

    // 2. Filtreleme: Sadece ID'si hala favori setinde olan modelleri göster
    // Notifier'daki toggleProduct sonrası set güncellendiği an burası tetiklenir
    final activeProducts = allProducts.where((p) => favoriteIds.contains(p.id)).toList();

    // 3. Boş durum kontrolünü filtreli listeye göre yap
    if (activeProducts.isEmpty) return const _EmptyProductsState();

    return RefreshIndicator(
      onRefresh: () => ref.read(favoritesProvider.notifier).loadAll(),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          12,
          12,
          12,
          MediaQuery.of(context).padding.bottom + 80,
        ),
        // 🔥 ÖNEMLİ: Filtrelenmiş listenin uzunluğunu veriyoruz
        itemCount: activeProducts.length,
        itemBuilder: (_, i) {
          // 🔥 ÖNEMLİ: Filtrelenmiş listeden ürünü çekiyoruz
          return ProductCard(product: activeProducts[i]);
        },
      ),
    );
  }
}

class _EmptyProductsState extends StatelessWidget {
  const _EmptyProductsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40), // Kenarlardan biraz daha pay verdik
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 170),

            // İkon boyutu küçültüldü ve opacity eklendi (daha soft bir görünüm için)
            Icon(
              Icons.favorite_outline_rounded,
              size: 48,
              color: AppColors.primaryDarkGreen.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz Favori Ürünün Yok 💚',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith( // titleLarge -> titleMedium
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDarkGreen,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Favorilediğin tüm ürünleri burada görebilirsin.\n'
                  'Ana sayfadan beğendiğin paketleri kalple işaretle.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith( // bodyLarge -> bodyMedium
                height: 1.4,
                color: Colors.black54, // Daha soft bir siyah/gri
              ),
            ),
          ],
        ),
      ),
    );
  }
}