import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_home_app_bar.dart';
import '../../../../core/widgets/floating_order_button.dart';
import '../../../explore/presentation/widgets/category_filter_option.dart';
import '../../../product/data/models/product_model.dart'; // ProductModel kalsın
import '../../../product/domain/providers/product_list_provider.dart'; // Product Repository/Provider
import '../domain/providers/home_state_provider.dart';
import '../widgets/home_banner_slider.dart';
import '../widgets/home_category_bar.dart';
import '../widgets/home_active_order_box.dart';
import '../widgets/home_email_warning_banner.dart';
import '../widgets/home_section_title.dart';
import '../widgets/home_product_list.dart';

// 💡 Her bölüm için ayrı bir FutureProvider tanımlıyoruz.
// Bu, Riverpod'ın caching özelliğini kullanarak her bölümün verisini izole etmemizi sağlar.
// ProductListController'ı kullanmak yerine, direkt repo'yu sarmalayan FutureProvider'lar daha clean olacaktır.

// 1. Hemen Yanımda (hemen_yaninda = true)
final nearbyProductsProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  // 🔥 Harita/Konum bilgisi HomeState'ten veya Geolocation provider'dan çekilebilir.
  // Varsayılan olarak 5 km içindeki ürünleri çekelim.
  try {
    final result = await repo.fetchProducts(
      hemenYaninda: true,
      perPage: 10, // Anasayfa için limit koyarız
      // location bilgisi (latitude/longitude) burada HomeState'ten çekilmelidir.
      // final location = ref.watch(homeStateProvider).currentLocation;
      // latitude: location?.latitude, longitude: location?.longitude,
    );
    return result.products;
  } catch (e) {
    debugPrint("Nearby Products Error: $e");
    return []; // Hata durumunda boş liste dön
  }
});

// 2. Son Şans (son_sans = true)
final lastChanceProductsProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  try {
    final result = await repo.fetchProducts(
      sonSans: true,
      perPage: 10,
    );
    return result.products;
  } catch (e) {
    debugPrint("Last Chance Products Error: $e");
    return [];
  }
});

// 3. Yeni Mekanlar (yeni = true, fakat Product API'si bunu ürün bazında veriyor, mekan bazında değil)
// Eğer API'de 'yeni' filtresi ürün bazında ise:
final newProductsProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  try {
    final result = await repo.fetchProducts(
      yeni: true, // son 2 hafta içinde eklenen ürünler
      perPage: 10,
    );
    return result.products;
  } catch (e) {
    debugPrint("New Products Error: $e");
    return [];
  }
});

// 4. Bugün Al (bugun = true)
final todayProductsProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  try {
    final result = await repo.fetchProducts(
      bugun: true,
      perPage: 10,
    );
    return result.products;
  } catch (e) {
    debugPrint("Today Products Error: $e");
    return [];
  }
});

// 5. Yarın Al (yarin = true)
final tomorrowProductsProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  try {
    final result = await repo.fetchProducts(
      yarin: true,
      perPage: 10,
    );
    return result.products;
  } catch (e) {
    debugPrint("Tomorrow Products Error: $e");
    return [];
  }
});

// 6. Favorilerim (Bu kısım için Favorites API'si veya product list'te is_favorite'e göre filtreleme gerekir)
// FavoritesProvider'ı kullanmalıyız. Şimdilik bu kısmı boş bırakalım veya HomeState'i kullanalım.
// (Gerektiğinde Favorites/Store API'si refactor edilmelidir)
final favoriteProductsProvider = Provider.autoDispose<List<ProductModel>>((ref) {
  // 💡 Normalde burada Favoriler API'si veya local cache kullanılır.
  // Product API'si token gönderilirse `is_favorite` bilgisini dönse de,
  // sadece favorileri listeleme endpoint'imiz (GET /favorites/products) varsayılır.
  return []; // Şimdilik boş liste
});



class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeStateProvider);
    final notifier = ref.read(homeStateProvider.notifier);

    // ⚠️ Bu satırı kaldırdık, artık provider'lar kullanılacak:
    // final List<ProductModel> mockProducts = [];

    final List<CategoryFilterOption> homeCategories = [
      CategoryFilterOption.all,
      CategoryFilterOption.food,
      CategoryFilterOption.bakery,
      CategoryFilterOption.breakfast,
      CategoryFilterOption.market,
      CategoryFilterOption.vegetarian,
      CategoryFilterOption.vegan,
      CategoryFilterOption.glutenFree,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: CustomHomeAppBar(
          address: homeState.selectedAddress,
          onLocationTap: () async {
            debugPrint("APPBAR CLICKED !!!!");
            final result = await context.push('/map');
            print("PUSH RESULT = $result");

            if (result != null) {
              final latLng = result as LatLng;
              final address =
                  "${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}";

              notifier.setAddress(address);

              // 💡 Konum değişince tüm ürün listelerini yenile
              ref.invalidate(nearbyProductsProvider);
              // Diğerleri de konum tabanlı filtreleme kullanıyorsa invalidate edilmeli
            }
          },
          onNotificationsTap: () => context.push('/notifications'),
        ),
      ),

      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, scrolled) => [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: const HomeBannerSlider(),
                ),
              ),

              SliverToBoxAdapter(
                child: const HomeEmailWarningBanner(),
              ),

              SliverPersistentHeader(
                pinned: true,
                delegate: HomeCategoryBar(
                  categories: homeCategories,
                  selectedIndex: homeState.selectedCategoryIndex,
                  onSelected: (index) {
                    notifier.setCategory(index);

                    final selectedEnum = homeCategories[index];

                    context.push(
                      '/explore',
                      extra: {
                        'category': selectedEnum,
                        'fromHome': true,
                      },
                    );
                  },
                ),
              ),

              if (homeState.hasActiveOrder)
                SliverToBoxAdapter(
                  child: HomeActiveOrderBox(
                    onTap: () => context.push('/order-tracking'),
                  ),
                ),
            ],
            // 💡 _HomeContent artık ConsumerWidget olmalı
            body: const _HomeContent(),
          ),

          /// 🟢 Sipariş Takip Float Button
          const FloatingOrderButton(),
        ],
      ),
    );
  }
}

// 💡 _HomeContent, verileri provider'lardan çekebilmek için ConsumerWidget olarak güncellendi
class _HomeContent extends ConsumerWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔥 Tüm ürün listelerini izle
    final nearbyAsync = ref.watch(nearbyProductsProvider);
    final lastChanceAsync = ref.watch(lastChanceProductsProvider);
    final newAsync = ref.watch(newProductsProvider);
    final todayAsync = ref.watch(todayProductsProvider);
    final tomorrowAsync = ref.watch(tomorrowProductsProvider);
    final favorites = ref.watch(favoriteProductsProvider); // Direkt liste dönüyor

    return ListView(
      padding: const EdgeInsets.only(
        top: 0,
        bottom: kBottomNavigationBarHeight + 24,
      ),
      children: [
        // 1. Hemen Yanımda
        const HomeSectionTitle(title: "Hemen Yanımda"),
        nearbyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator.adaptive()),
          error: (err, stack) => const Center(child: Text("Hata oluştu.")),
          data: (products) => HomeProductList(products: products),
        ),

        // 2. Son Şans
        const HomeSectionTitle(title: "Son Şans"),
        lastChanceAsync.when(
          loading: () => const Center(child: CircularProgressIndicator.adaptive()),
          error: (err, stack) => const Center(child: Text("Hata oluştu.")),
          data: (products) => HomeProductList(products: products),
        ),

        // 3. Yeni Mekanlar (Ürünler)
        const HomeSectionTitle(title: "Yeni Mekanlar"),
        newAsync.when(
          loading: () => const Center(child: CircularProgressIndicator.adaptive()),
          error: (err, stack) => const Center(child: Text("Hata oluştu.")),
          data: (products) => HomeProductList(products: products),
        ),

        // 4. Bugün Al
        const HomeSectionTitle(title: "Bugün Al"),
        todayAsync.when(
          loading: () => const Center(child: CircularProgressIndicator.adaptive()),
          error: (err, stack) => const Center(child: Text("Hata oluştu.")),
          data: (products) => HomeProductList(products: products),
        ),

        // 5. Yarın Al
        const HomeSectionTitle(title: "Yarın Al"),
        tomorrowAsync.when(
          loading: () => const Center(child: CircularProgressIndicator.adaptive()),
          error: (err, stack) => const Center(child: Text("Hata oluştu.")),
          data: (products) => HomeProductList(products: products),
        ),

        // 6. Favorilerim (FutureProvider'ı kullanmıyorsa direkt liste)
        if (favorites.isNotEmpty) ...[
          const HomeSectionTitle(title: "Favorilerim"),
          HomeProductList(products: favorites),
        ],

        const SizedBox(height: 32),
      ],
    );
  }
}