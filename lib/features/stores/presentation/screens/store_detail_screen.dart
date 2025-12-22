// lib/features/stores/presentation/screens/store_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return Scaffold(
        body: Center(child: Text("Hata: ${state.error}")),
      );
    }

    final StoreDetailModel? store = state.detail;
    if (store == null) {
      return const Scaffold(
        body: Center(child: Text("Mağaza bulunamadı")),
      );
    }

    // modeldeki doğru alan isimlerini kullan
    final bannerRaw = store.bannerImageUrl;
    // logo tercihen brand.logoUrl, yoksa store.imageUrl
    final logoRaw = store.brand?.logoUrl ?? store.imageUrl;

    final bannerUrl = sanitizeImageUrl(bannerRaw);
    final logoUrl = sanitizeImageUrl(logoRaw);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _header(
                context,
                store,
                bannerUrl: bannerUrl,
                logoUrl: logoUrl,
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // içerik
                    StoreDetailsContent(
                      storeDetail: store,
                      onProductTap: (product) {
                        // Ürün detay ekranına yönlendiriyoruz
                        // GoRouter kullanıyorsan:
                        context.push('/product-detail/${product.id}');

                        // Eğer route yapın farklıysa (örneğin nested route):
                        // context.pushNamed('product_detail', pathParameters: {'id': product.id});
                      },
                    ),
                    const SizedBox(height: 12),
                    if (store.workingHours != null &&
                        store.workingHours!.days.isNotEmpty)
                      StoreWorkingHoursSection(
                        hours: store.workingHours!.toUiList(),
                      ),
                    const SizedBox(height: 16),
                    StoreMapCard(
                      storeId: store.id,
                      latitude: store.latitude,
                      longitude: store.longitude,
                      address: store.address,
                    ),
                    const SizedBox(height: 140),
                  ],
                ),
              ),
            ],
          ),

          // floating cart (sağ altta)
          const Positioned(
            right: 16,
            bottom: 16,
            child: FloatingCartButton(),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context,
      StoreDetailModel store, {
        required String? bannerUrl,
        required String? logoUrl,
      }) {
    // => yerine { açtık
    return SliverAppBar( // return ekledik
      pinned: true,
      expandedHeight: 230,
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
                    child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
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
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryDarkGreen,
                    width: 1,
                  ),
                ),
                child: CircleAvatar(
                  radius: 35,
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