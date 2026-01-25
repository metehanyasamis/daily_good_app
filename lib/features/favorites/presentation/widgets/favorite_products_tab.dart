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
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_outline_rounded,
              size: 72,
              color: AppColors.primaryDarkGreen,
            ),
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
