import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_home_app_bar.dart';
import '../../../../core/widgets/floating_order_button.dart';

import '../../../category/domain/category_notifier.dart';
import '../../../location/domain/address_notifier.dart';

import '../data/models/home_state.dart';
import '../domain/providers/home_state_provider.dart';

import '../widgets/home_active_order_box.dart';
import '../widgets/home_banner_slider.dart';
import '../widgets/home_category_bar.dart';
import '../widgets/home_email_warning_banner.dart';
import '../widgets/home_product_list.dart';
import '../widgets/home_section_title.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      debugPrint("🏠 [HOME] initState");

      // 1️⃣ Category load (auth gerekmiyor)
      ref.read(categoryProvider.notifier).load();

      // 2️⃣ Address kontrol
      final address = ref.read(addressProvider);
      debugPrint("📍 [HOME] address.isSelected = ${address.isSelected}");

      if (!address.isSelected) {
        debugPrint("⛔ [HOME] Konum seçilmedi → home load yok");
        return;
      }

      // 3️⃣ HOME TEK ÇAĞRI
      ref.read(homeStateProvider.notifier).loadHome(
        latitude: address.lat,
        longitude: address.lng,
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeStateProvider);
    final addressState = ref.watch(addressProvider);
    final categoryState = ref.watch(categoryProvider);
    final categories = categoryState.categories;

    debugPrint(
      "🏠 [HOME BUILD] sections="
          "${homeState.sectionProducts.map((k,v)=>MapEntry(k.name,v.length))}",
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: CustomHomeAppBar(
          address: addressState.title,
          onLocationTap: () => context.push('/location-picker'),
          onNotificationsTap: () => context.push('/notifications'),
        ),
      ),
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, _) => [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: HomeBannerSlider(),
                ),
              ),

              if (categories.isNotEmpty)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: HomeCategoryBar(
                    categories: categories,
                    selectedIndex: homeState.selectedCategoryIndex,
                    onSelected: (index) {
                      ref
                          .read(homeStateProvider.notifier)
                          .setCategory(index);

                      context.push(
                        '/explore',
                        extra: {
                          'categoryId': categories[index].id,
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
            body: const HomeContent(),
          ),
          const FloatingOrderButton(),
        ],
      ),
    );
  }
}

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeStateProvider);

    final isLoading =
    homeState.loadingSections.values.any((v) => v);

    final hasAnyData =
    homeState.sectionProducts.values.any((l) => l.isNotEmpty);

    debugPrint(
      "📄 [HOME CONTENT] "
          "loading=${homeState.loadingSections} "
          "sizes=${homeState.sectionProducts.map((k,v)=>MapEntry(k.name,v.length))}",
    );

    if (isLoading && !hasAnyData) {
      return const Center(child: CircularProgressIndicator());
    }

    final hemenYaninda =
        homeState.sectionProducts[HomeSection.hemenYaninda] ?? const [];
    final sonSans =
        homeState.sectionProducts[HomeSection.sonSans] ?? const [];
    final yeni =
        homeState.sectionProducts[HomeSection.yeni] ?? const [];
    final bugun =
        homeState.sectionProducts[HomeSection.bugun] ?? const [];
    final yarin =
        homeState.sectionProducts[HomeSection.yarin] ?? const [];

    return ListView(
      padding: const EdgeInsets.only(
        bottom: kBottomNavigationBarHeight + 24,
      ),
      children: [
        // 📧 E-POSTA WARNING BANNER BURADA
        const HomeEmailWarningBanner(),

        const HomeSectionTitle(title: "Hemen Yanımda"),
        HomeProductList(products: hemenYaninda),

        const HomeSectionTitle(title: "Son Şans"),
        HomeProductList(products: sonSans),

        const HomeSectionTitle(title: "Yeni"),
        HomeProductList(products: yeni),

        const HomeSectionTitle(title: "Bugün"),
        HomeProductList(products: bugun),

        const HomeSectionTitle(title: "Yarın"),
        HomeProductList(products: yarin),

        const SizedBox(height: 32),
      ],
    );
  }
}
