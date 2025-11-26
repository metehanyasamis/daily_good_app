import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_home_app_bar.dart';

import '../../../../core/widgets/floating_order_button.dart';
import '../../../explore/presentation/widgets/category_filter_option.dart';
import '../../../product/data/mock/mock_product_model.dart'; // mock products
import '../domain/providers/home_state_provider.dart';
import '../widgets/home_banner_slider.dart';
import '../widgets/home_category_bar.dart';
import '../widgets/home_active_order_box.dart';
import '../widgets/home_section_title.dart';
import '../widgets/home_product_list.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeStateProvider);
    final notifier = ref.read(homeStateProvider.notifier);

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
            body: const _HomeContent(),
          ),

          /// 🟢 Sipariş Takip Float Button
          const FloatingOrderButton(),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(
        top: 0,
        bottom: kBottomNavigationBarHeight + 24,
      ),
      children: [

        const HomeSectionTitle(title: "Hemen Yanımda"),
        HomeProductList(products: mockProducts),           // ✅ EKLENDİ

        const HomeSectionTitle(title: "Son Şans"),
        HomeProductList(products: mockProducts),

        const HomeSectionTitle(title: "Yeni Mekanlar"),
        HomeProductList(products: mockProducts),

        const HomeSectionTitle(title: "Bugün Al"),
        HomeProductList(products: mockProducts),

        const HomeSectionTitle(title: "Yarın Al"),
        HomeProductList(products: mockProducts),

        const HomeSectionTitle(title: "Favorilerim"),
        HomeProductList(products: mockProducts),

        const SizedBox(height: 32),
      ],
    );
  }
}
