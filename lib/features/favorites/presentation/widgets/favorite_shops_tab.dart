import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/fav_button.dart';
import '../../domain/favorites_notifier.dart';
import '../../../stores/data/model/store_summary.dart';

class FavoriteShopsTab extends ConsumerWidget {
  const FavoriteShopsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Tüm mağaza modellerini ve ID setini dinle
    final shops = ref.watch(favoritesProvider.select((s) => s.stores));
    final shopIds = ref.watch(favoritesProvider.select((s) => s.storeIds));

    // 2. Filtreleme: Sadece ID'si hala favori setinde olanları göster
    // Bu sayede kalbe basıldığı an kart listeden kaybolur (Anlık UX)
    final activeShops = shops.where((s) => shopIds.contains(s.id)).toList();

    // 3. Boş durum kontrolü
    if (activeShops.isEmpty) return const _EmptyShopsState();

    return RefreshIndicator(
      onRefresh: () => ref.read(favoritesProvider.notifier).loadAll(),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          12,
          12,
          12,
          MediaQuery.of(context).padding.bottom + 80,
        ),
        // 🔥 BURASI ÖNEMLİ: activeShops kullanmalısın
        itemCount: activeShops.length,
        itemBuilder: (context, index) {
          final shop = activeShops[index]; // 🔥 Burası da activeShops olmalı
          return _ShopCard(shop: shop);
        },
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final StoreSummary shop;
  const _ShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/stores-detail', extra: shop),
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
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: _ShopAvatar(url: shop.imageUrl),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _ShopInfo(shop: shop),
                  ),
                ),
              ],
            ),

            // ❤️ Favori butonu sağ üst (aynı)
            Positioned(
              top: 6,
              right: 6,
              child: FavButton(id: shop.id, isStore: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopAvatar extends StatelessWidget {
  final String url;
  const _ShopAvatar({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: ClipOval(
        child: url.isEmpty
            ? const Icon(Icons.storefront, color: Colors.black26, size: 28)
            : Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.storefront, color: Colors.black26, size: 28),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDarkGreen.withOpacity(0.3)));
          },
        ),
      ),
    );
  }
}

class _ShopInfo extends StatelessWidget {
  final StoreSummary shop;
  const _ShopInfo({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          shop.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          shop.address,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.star, size: 14, color: AppColors.primaryDarkGreen),
            const SizedBox(width: 4),
            Text(
              shop.overallRating?.toStringAsFixed(1) ?? "0.0",
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(width: 10),
            Icon(Icons.place, size: 14, color: AppColors.primaryDarkGreen),
            const SizedBox(width: 4),
            Text(
              '${shop.distanceKm?.toStringAsFixed(1) ?? "0.0"} km',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyShopsState extends StatelessWidget {
  const _EmptyShopsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.store_mall_directory_outlined,
              size: 64,
              color: AppColors.primaryDarkGreen,
            ),
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
