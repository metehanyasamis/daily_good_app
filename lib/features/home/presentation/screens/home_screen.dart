import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_home_app_bar.dart';
import '../../../../core/widgets/floating_order_button.dart';

import '../../../location/domain/address_notifier.dart';
import '../data/models/home_state.dart';
import '../domain/providers/home_state_provider.dart';
import '../widgets/home_active_order_box.dart';
import '../widgets/home_banner_slider.dart';
import '../widgets/home_category_bar.dart';
import '../widgets/home_email_warning_banner.dart';
import '../widgets/home_product_list.dart';
import '../widgets/home_section_title.dart';
import '../../../explore/presentation/widgets/category_filter_option.dart';

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
      final notifier = ref.read(homeStateProvider.notifier);
      final addressState = ref.read(addressProvider);

      // Konum seçilmemişse hiçbir şey çağırma
      if (!addressState.isSelected) return;

      final lat = addressState.lat;
      final lng = addressState.lng;

      notifier.loadSection(HomeSection.hemenYaninda,
          latitude: lat, longitude: lng);
      notifier.loadSection(HomeSection.sonSans,
          latitude: lat, longitude: lng);
      notifier.loadSection(HomeSection.yeni,
          latitude: lat, longitude: lng);
      notifier.loadSection(HomeSection.bugun,
          latitude: lat, longitude: lng);
      notifier.loadSection(HomeSection.yarin,
          latitude: lat, longitude: lng);
    });
  }


  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeStateProvider);
    final homeNotifier = ref.read(homeStateProvider.notifier);
    final addressState = ref.watch(addressProvider);

    // 🔥 EKLENEN KISIM (BURASI ÖNEMLİ)
    final hasAnyData = homeState.sectionProducts.values
        .any((list) => list.isNotEmpty);

    if (!hasAnyData) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    // 🔥 EKLENEN KISIM BİTTİ

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
              const SliverToBoxAdapter(
                child: HomeEmailWarningBanner(),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: HomeCategoryBar(
                  categories: homeCategories,
                  selectedIndex: homeState.selectedCategoryIndex,
                  onSelected: (index) {
                    homeNotifier.setCategory(index);
                    context.push(
                      '/explore',
                      extra: {
                        'category': homeCategories[index],
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


// ============================================================================
// HOME CONTENT
// ============================================================================

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeStateProvider);

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
        // --------------------------------------------------
        // HEMEN YANIMDA
        // --------------------------------------------------
        const HomeSectionTitle(title: "Hemen Yanımda"),
        HomeProductList(products: hemenYaninda),

        // --------------------------------------------------
        // SON ŞANS
        // --------------------------------------------------
        const HomeSectionTitle(title: "Son Şans"),
        HomeProductList(products: sonSans),

        // --------------------------------------------------
        // YENİ MEKANLAR
        // --------------------------------------------------
        const HomeSectionTitle(title: "Yeni Mekanlar"),
        HomeProductList(products: yeni),

        // --------------------------------------------------
        // BUGÜN AL
        // --------------------------------------------------
        const HomeSectionTitle(title: "Bugün Al"),
        HomeProductList(products: bugun),

        // --------------------------------------------------
        // YARIN AL
        // --------------------------------------------------
        const HomeSectionTitle(title: "Yarın Al"),
        HomeProductList(products: yarin),

        const SizedBox(height: 32),
      ],
    );
  }
}
