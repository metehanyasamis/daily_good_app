import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_home_app_bar.dart';
import '../../../../core/widgets/custom_toggle_button.dart';
import '../../../location/domain/address_notifier.dart';

import '../../../product/data/models/product_model.dart';
import '../../../product/domain/products_notifier.dart';
import '../../../product/domain/products_state.dart';
import '../../../product/presentation/widgets/product_card.dart';

import '../../domain/providers/explore_state_provider.dart';
import '../widgets/category_filter_option.dart';
import '../widgets/explore_filter_sheet.dart';
import '../widgets/category_filter_sheet.dart';

enum SortDirection {
  ascending,
  descending,
}

class ExploreListScreen extends ConsumerStatefulWidget {
  final CategoryFilterOption? initialCategory;
  final bool fromHome;

  const ExploreListScreen({
    super.key,
    this.initialCategory,
    this.fromHome = false,
  });

  @override
  ConsumerState<ExploreListScreen> createState() =>
      _ExploreListScreenState();
}

class _ExploreListScreenState extends ConsumerState<ExploreListScreen> {
  ExploreFilterOption selectedFilter = ExploreFilterOption.recommended;
  SortDirection sortDirection = SortDirection.ascending;

  CategoryFilterOption selectedCategory = CategoryFilterOption.all;
  final TextEditingController _searchController = TextEditingController();

  late final ProviderSubscription<ProductsState> _productsSub;

  List<ProductModel> filteredProducts = [];

  // --------------------------------------------------
  // INIT
  // --------------------------------------------------
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final address = ref.read(addressProvider);
      if (!address.isSelected) return;

      // 🔥 HOME'DAN GELEN CATEGORY ID
      final routeState = GoRouterState.of(context);
      final extra = routeState.extra as Map<String, dynamic>?;

      final categoryId = extra?['categoryId'] as String?;

      if (categoryId != null) {
        debugPrint('🏷️ HOME → EXPLORE categoryId = $categoryId');

        ref.read(exploreStateProvider.notifier)
            .setCategoryId(categoryId);

        // 🔥 BACKEND FETCH
        ref.read(productsProvider.notifier).refresh(
          latitude: address.lat,
          longitude: address.lng,
          categoryId: categoryId,
        );
      } else {
        // Normal explore açılışı
        ref.read(productsProvider.notifier).loadOnce(
          latitude: address.lat,
          longitude: address.lng,
        );
      }
    });


  }

  @override
  void dispose() {
    debugPrint('💀 ExploreListScreen dispose HASH=${hashCode}');
    _productsSub.close();
    _searchController.dispose();
    super.dispose();
  }

  // --------------------------------------------------
  // FILTER
  // --------------------------------------------------
  void _applyFilters(List<ProductModel> allProducts) {
    List<ProductModel> temp = List.from(allProducts);

    final q = _searchController.text.trim().toLowerCase();
    if (q.length >= 3) {
      temp = temp.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.store.name.toLowerCase().contains(q);
      }).toList();
    }

    temp.sort((a, b) {
      int result;

      switch (selectedFilter) {
        case ExploreFilterOption.recommended:
          result = b.createdAt.compareTo(a.createdAt);
          break;
        case ExploreFilterOption.price:
          result = a.salePrice.compareTo(b.salePrice);
          break;
        case ExploreFilterOption.distance:
          result = (a.store.distanceKm ?? 999)
              .compareTo(b.store.distanceKm ?? 999);
          break;
        case ExploreFilterOption.rating:
          result = 0;
          break;
      }

      return sortDirection == SortDirection.ascending ? result : -result;
    });

    setState(() {
      filteredProducts = temp;
    });
  }

  // --------------------------------------------------
  // BUILD (PURE)
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final address = ref.watch(addressProvider);
    final productsState = ref.watch(productsProvider);

    debugPrint(
      '🟢 EXPLORE LIST BUILD '
          'products=${productsState.products.length} '
          'filtered=${filteredProducts.length} '
          'loading=${productsState.isLoadingList}',
    );

    if (productsState.isLoadingList && filteredProducts.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomHomeAppBar(
        address: address.title,
        onLocationTap: () => context.push('/location-picker'),
        onNotificationsTap: () {},
        leadingOverride: widget.fromHome
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        )
            : null,
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildHeader(),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, i) {
                      final p = filteredProducts[i];
                      return ProductCard(
                        product: p,
                        onTap: () => context.push('/product-detail/${p.id}'),
                      );
                    },
                    childCount: filteredProducts.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          ),

          CustomToggleButton(
            label: "Harita",
            icon: Icons.map_outlined,
            onPressed: () => context.push('/explore-map'),
          ),
        ],
      ),
    );
  }

  String? mapCategoryToCategoryId(CategoryFilterOption c) {
    switch (c) {
      case CategoryFilterOption.all:
        return null;
      case CategoryFilterOption.food:
        return 'food';
      case CategoryFilterOption.bakery:
        return 'bakery';
      case CategoryFilterOption.breakfast:
        return 'breakfast';
      case CategoryFilterOption.market:
        return 'market';
      case CategoryFilterOption.vegetarian:
        return 'vegetarian';
      case CategoryFilterOption.vegan:
        return 'vegan';
      case CategoryFilterOption.glutenFree:
        return 'gluten_free';
    }
  }


  // --------------------------------------------------
  // HEADER (AYNI)
  // --------------------------------------------------
  SliverPersistentHeader _buildHeader() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: ExploreHeaderDelegate(
        controller: _searchController,
        selectedSort: selectedFilter,
        sortDirection: sortDirection,
        selectedCategory: selectedCategory,

        // 🔍 SEARCH → local filter
        onSearchChanged: (_) {
          final all = ref.read(productsProvider).products;
          _applyFilters(all);
        },

        // 🔃 SORT → local filter
        onSortChanged: (opt) {
          setState(() {
            if (opt == selectedFilter) {
              sortDirection =
              sortDirection == SortDirection.ascending
                  ? SortDirection.descending
                  : SortDirection.ascending;
            } else {
              selectedFilter = opt!;
              sortDirection = SortDirection.ascending;
            }
          });

          final all = ref.read(productsProvider).products;
          _applyFilters(all);
        },

        // 🔥 CATEGORY → BACKEND REFRESH
        onCategoryTap: () async {
          final res = await showModalBottomSheet<CategoryFilterOption>(
            context: context,
            isScrollControlled: true,
            builder: (_) => CategoryFilterSheet(
              selected: selectedCategory,
              onApply: (c) => Navigator.pop(context, c),
            ),
          );

          if (res == null) return;

          debugPrint('🟡 UI CATEGORY SELECTED → $res');
          setState(() => selectedCategory = res);

          final address = ref.read(addressProvider);
          if (!address.isSelected) {
            debugPrint('❌ ADDRESS NOT SELECTED → SKIP FETCH');
            return;
          }

          final categoryId = mapCategoryToCategoryId(res);

          debugPrint(
            '📡 BACKEND REFRESH → '
                'lat=${address.lat}, '
                'lng=${address.lng}, '
                'categoryId=$categoryId',
          );

          await ref.read(productsProvider.notifier).refresh(
            latitude: address.lat,
            longitude: address.lng,
            categoryId: categoryId,
          );
        },
      ),
    );
  }
}

class ExploreHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final ExploreFilterOption selectedSort;
  final SortDirection sortDirection;
  final CategoryFilterOption selectedCategory;

  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ExploreFilterOption?> onSortChanged;
  final VoidCallback onCategoryTap;

  ExploreHeaderDelegate({
    required this.controller,
    required this.selectedSort,
    required this.sortDirection,
    required this.selectedCategory,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onCategoryTap,
  });

  @override
  double get minExtent => 120;

  @override
  double get maxExtent => 120;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          // 🔍 SEARCH
          TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Ürün veya işletme ara (3+ harf)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              _sortCapsule(context),
              const SizedBox(width: 10),
              _categoryButton(),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // 🔽 SORT CAPSULE
  // --------------------------------------------------
  Widget _sortCapsule(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => onSortChanged(selectedSort),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: AnimatedRotation(
                turns:
                sortDirection == SortDirection.ascending ? 0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.arrow_upward,
                  color: AppColors.primaryDarkGreen,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => ExploreFilterSheet(
                  selected: selectedSort,
                  onApply: onSortChanged,
                ),
              );
            },
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                _sortLabel(selectedSort),
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _sortLabel(ExploreFilterOption opt) {
    switch (opt) {
      case ExploreFilterOption.recommended:
        return "Önerilen";
      case ExploreFilterOption.price:
        return "Fiyat";
      case ExploreFilterOption.distance:
        return "Mesafe";
      case ExploreFilterOption.rating:
        return "Puan";
    }
  }

  // --------------------------------------------------
  // 🟩 CATEGORY BUTTON
  // --------------------------------------------------
  Widget _categoryButton() {
    return InkWell(
      onTap: onCategoryTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          "Kategori: ${categoryLabel(selectedCategory)}",
          style: const TextStyle(
            color: AppColors.primaryDarkGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
