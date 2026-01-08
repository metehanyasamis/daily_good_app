// lib/features/stores/presentation/screens/store_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/platform/platform_widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/fav_button.dart';
import '../../../../core/widgets/floating_cart_button.dart';
import '../../../../core/utils/image_utils.dart'; // sanitizeImageUrl fonksiyonu
import '../../domain/providers/store_detail_provider.dart';
import '../widgets/store_details_content.dart';
import '../widgets/store_map_card.dart';
import '../widgets/store_working_hours_section.dart';
import '../../data/model/working_hours_mapper.dart';
import '../../data/model/store_detail_model.dart';

class StoreDetailScreen extends ConsumerWidget {
  final String storeId;

  const StoreDetailScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storeDetailProvider(storeId));

    if (state.loading) {
      return Scaffold( // 🚀 'const' kaldırıldı
        body: Center(
          child: PlatformWidgets.loader(),
        ),
      );
    }
    if (state.error != null) return Scaffold(body: Center(child: Text("Hata: ${state.error}")));

    final StoreDetailModel? store = state.detail;
    if (store == null) return const Scaffold(body: Center(child: Text("Mağaza bulunamadı")));

    final bannerUrl = sanitizeImageUrl(store.bannerImageUrl);
    final logoUrl = sanitizeImageUrl(store.brand?.logoUrl ?? store.imageUrl);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8), // Sayfa arka planını hafif gri yap ki beyaz kartlar patlasın (Figma'daki gibi)
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _header(context, store, bannerUrl: bannerUrl, logoUrl: logoUrl),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // 1. ANA İÇERİK: Ürünler + Bilgi + Rating
                    // Bu widget zaten kendi içinde beyaz kart yapısına sahip.
                    StoreDetailsContent(
                      storeDetail: store,
                      onProductTap: (product) => context.push('/product-detail/${product.id}'),
                    ),

                    // 2. ÇALIŞMA SAATLERİ
                    // Debug yazılarını sildik, sadece veri varsa kartı gösteriyoruz.
                    if (store.workingHours != null && store.workingHours!.days.isNotEmpty) ...[
                      const SizedBox(height: 16), // Bölümler arası nefes payı
                      StoreWorkingHoursSection(
                        hours: store.workingHours!.toUiList(),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // 3. HARİTA KARTI
                    StoreMapCard(
                      storeId: store.id,
                      latitude: store.latitude,
                      longitude: store.longitude,
                      address: store.address,
                    ),

                    const SizedBox(height: 140), // Alt bar için kaydırma payı
                  ],
                ),
              ),
            ],
          ),
          const Positioned(right: 16, bottom: 16, child: FloatingCartButton()),
        ],
      ),
    );
  }
  Widget _header(BuildContext context,
      StoreDetailModel store, {
        required String? bannerUrl,
        required String? logoUrl,
      }) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    // => yerine { açtık
    return SliverAppBar( // return ekledik
      pinned: true,
      expandedHeight: 180 + statusBarHeight,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      leading: _roundIcon(
        icon: Icons.arrow_back_ios_new_rounded,
        onTap: () => context.pop(),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: FavButton( // Buradaki FavButton'ın doğru import edildiğinden emin ol
            id: store.id,
            isStore: true,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Banner: önce network, hata olursa asset placeholder
            if (bannerUrl != null)
              Image.network(
                bannerUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, err, __) {
                  debugPrint('BANNER IMAGE ERROR: $err');
                  return Image.asset(
                      'assets/images/sample_food3.jpg', fit: BoxFit.cover);
                },
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.grey.shade200,
                    child: Center( // 🚀 'const' kaldırıldı
                      child: PlatformWidgets.loader(strokeWidth: 2), // 🎯 Adaptive yapıya geçildi
                    ),
                  );
                },
              )
            else
              Image.asset(
                'assets/images/sample_food3.jpg',
                fit: BoxFit.cover,
              ),

            // Circular logo bottom-left
            Positioned(
              left: 16,
              bottom: 16,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryDarkGreen,
                    width: 1,
                  ),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: logoUrl != null
                        ? Image.network(
                      logoUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, err, __) {
                        debugPrint('LOGO IMAGE ERROR: $err');
                        return Image.asset('assets/images/sample_food3.jpg',
                            width: 60, height: 60, fit: BoxFit.cover);
                      },
                    )
                        : Image.asset(
                        'assets/images/sample_food3.jpg', width: 60,
                        height: 60,
                        fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

    Widget _roundIcon({required IconData icon, VoidCallback? onTap}) =>
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, size: 18, color: Colors.black87),
            ),
          ),
        );

}