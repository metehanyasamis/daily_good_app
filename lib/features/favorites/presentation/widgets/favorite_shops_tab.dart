import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/fav_button.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../../domain/favorites_notifier.dart';
import '../../../stores/data/model/store_summary.dart';

class FavoriteShopsTab extends ConsumerWidget {
  const FavoriteShopsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shops = ref.watch(favoritesProvider.select((s) => s.stores));
    final shopIds = ref.watch(favoritesProvider.select((s) => s.storeIds));

    final activeShops = shops.where((s) => shopIds.contains(s.id.toLowerCase().trim())).toList();

    if (activeShops.isEmpty) return const _EmptyShopsState();

    return RefreshIndicator(
      color: AppColors.primaryDarkGreen,
      onRefresh: () => ref.read(favoritesProvider.notifier).loadAll(),
      child: ListView.builder( // separated yerine builder kullanıyoruz
        padding: EdgeInsets.fromLTRB(
          12, // Product tab ile aynı
          12,
          12,
          MediaQuery.of(context).padding.bottom + 80,
        ),
        itemCount: activeShops.length,
        itemBuilder: (context, index) => _ShopCard(shop: activeShops[index]),
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
      onTap: () => context.push('/store-detail/${shop.id}'),
      child: Container(
        // 🎯 ProductCard ile birebir aynı margin:
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08), // 0.06'yı 0.08 yaptık
              blurRadius: 10, // 8'i 10 yaptık
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- BANNER ---
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  NetworkImageOrPlaceholder(
                    url: shop.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: FavButton(id: shop.id, isStore: true),
                  ),
                  // Logo
                  Positioned(
                    bottom: 8,
                    left: 10,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: NetworkImageOrPlaceholder(
                          url: shop.imageUrl,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          fallbackIcon: Icons.store,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Banner altı çok ince ayraç çizgisi
            Divider(height: 1, thickness: 0.5, color: Colors.grey.shade300),
            // --- İÇERİK ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // İsim ve Puan Satırı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          shop.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Puan
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.orange),
                          const SizedBox(width: 2),
                          Text(
                            shop.overallRating?.toStringAsFixed(1) ?? "0.0",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Adres
                  Text(
                    shop.address,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Alt Bilgi Satırı: Mesafe | Saat (Kutusuz, doğrudan zemin üzerinde)
                  Row(
                    children: [
                      const Icon(Icons.place, size: 14, color: AppColors.primaryDarkGreen),
                      const SizedBox(width: 4),
                      Text(
                        '${shop.distanceKm?.toStringAsFixed(1) ?? "0.0"} km',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),

                      // Dikey Ayraç
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text("|", style: TextStyle(color: Colors.grey.shade300, fontSize: 14)),
                      ),

                      const Icon(Icons.access_time, size: 14, color: AppColors.primaryDarkGreen),
                      const SizedBox(width: 4),
                      const Text(
                        '09:00 - 22:00',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _EmptyShopsState extends StatelessWidget {
  const _EmptyShopsState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        // Ürünler tabı ile aynı yükseklikte durması için start ve 150px boşluk
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 170),

          // İkon boyutu küçültüldü ve daha soft bir görünüm için alpha eklendi
          Icon(
            Icons.storefront_outlined,
            size: 48, // 72 -> 48 yapıldı
            color: AppColors.primaryDarkGreen.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Favori İşletmen Bulunmuyor 🏪',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith( // titleLarge -> titleMedium
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDarkGreen,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Takip ettiğin işletmeleri burada görebilirsin.\n'
                'Beğendiğin işletmeleri favorilerine ekleyerek yeni paketlerden haberdar ol!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith( // bodyLarge -> bodyMedium
              height: 1.4,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}