// Refactored ExploreListScreen
// - Backend-driven category & sort sheets (Apply button, space for custom nav bar)
// - Safe handling of sortByMapProvider types (String? vs String)
// - Products -> filteredProducts sync via ref.listen and initial application
// - Robust initState handling for extras (home -> explore)
// NOTE: This file depends on your existing providers/widgets (addressProvider, productsProvider,
// categoryProvider, sortByMapProvider, exploreStateProvider, ProductCard, CategoryFilterSheet, ExploreFilterSheet).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_home_app_bar.dart';
import '../../../../core/widgets/custom_toggle_button.dart';
import '../../../category/domain/category_notifier.dart';
import '../../../location/domain/address_notifier.dart';

import '../../../product/data/models/product_model.dart';
import '../../../product/domain/products_notifier.dart';
import '../../../product/domain/products_state.dart';
import '../../../product/presentation/widgets/product_card.dart';

import '../../domain/providers/explore_state_provider.dart';
import '../../domain/providers/sort_options_provider.dart';
import '../widgets/category_filter_option.dart';
import '../widgets/explore_filter_sheet.dart';
import '../widgets/category_filter_sheet.dart';

enum SortDirection { ascending, descending }

class ExploreListScreen extends ConsumerStatefulWidget {
  final CategoryFilterOption? initialCategory;
  final bool fromHome;

  const ExploreListScreen({super.key, this.initialCategory, this.fromHome = false});

  @override
  ConsumerState<ExploreListScreen> createState() => _ExploreListScreenState();
}

class _ExploreListScreenState extends ConsumerState<ExploreListScreen> {
  ExploreFilterOption selectedFilter = ExploreFilterOption.recommended;
  SortDirection sortDirection = SortDirection.ascending;

  CategoryFilterOption selectedCategory = CategoryFilterOption.all;
  String? selectedCategoryId; // backend id if any

  final TextEditingController _searchController = TextEditingController();

  List<ProductModel> filteredProducts = [];

  // ---------------------------
  // INIT / DISPOSE
  // ---------------------------
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final address = ref.read(addressProvider);
      if (!address.isSelected) return;

      final routeState = GoRouterState.of(context);
      final dynamic extra = routeState.extra;
      String? categoryId;

      if (extra is Map) {
        final val = extra['categoryId'] ?? extra['category_id'] ?? extra['id'];
        if (val != null) categoryId = val.toString();
      } else if (extra != null) {
        categoryId = extra.toString();
      }

      if (categoryId != null) {
        debugPrint('🏷️ HOME → EXPLORE categoryId = $categoryId');

        selectedCategoryId = categoryId;
        ref.read(exploreStateProvider.notifier).setCategoryId(categoryId);

        final apiSort = _apiSortFor(selectedFilter) ?? 'created_at';
        final sortOrder = sortDirection == SortDirection.ascending ? 'asc' : 'desc';

        ref.read(productsProvider.notifier).refresh(
          latitude: address.lat,
          longitude: address.lng,
          categoryId: categoryId,
          sortBy: apiSort,
          sortOrder: sortOrder,
        );
      } else {
        final apiSort = _apiSortFor(selectedFilter) ?? 'created_at';
        final sortOrder = sortDirection == SortDirection.ascending ? 'asc' : 'desc';

        ref.read(productsProvider.notifier).loadOnce(
          latitude: address.lat,
          longitude: address.lng,
          sortBy: apiSort,
          sortOrder: sortOrder,
        );
      }
    });
  }

  @override
  void dispose() {
    debugPrint('💀 ExploreListScreen dispose HASH=${hashCode}');
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------
  // FILTER (client-side fallback & search)
  // ---------------------------
  void _applyFilters(List<ProductModel> allProducts) {
    List<ProductModel> temp = List.from(allProducts);

    final q = _searchController.text.trim().toLowerCase();
    if (q.length >= 3) {
      temp = temp.where((p) {
        return p.name.toLowerCase().contains(q) || p.store.name.toLowerCase().contains(q);
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
          result = (a.store.distanceKm ?? 999).compareTo(b.store.distanceKm ?? 999);
          break;
        case ExploreFilterOption.rating:
          result = (b.store.overallRating ?? 0.0).compareTo(a.store.overallRating ?? 0.0);
          break;
      }
      return sortDirection == SortDirection.ascending ? result : -result;
    });

    setState(() {
      filteredProducts = temp;
    });
  }

  // ---------------------------
  // HELPERS
  // ---------------------------
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
      default:
        return null;
    }
  }

  // Read sort map from provider safely and return Map<ExploreFilterOption, String?>.
  Map<ExploreFilterOption, String?> _readSortOptionsSafe() {
    final dynamic raw = ref.read(sortByMapProvider);
    final Map<ExploreFilterOption, String?> result = {};
    if (raw == null) return result;
    if (raw is Map) {
      raw.forEach((k, v) {
        try {
          if (k is ExploreFilterOption) {
            result[k] = v?.toString();
          }
        } catch (_) {}
      });
    }
    return result;
  }

  // Return API key (nullable) for currently selectedFilter
  String? _apiSortFor(ExploreFilterOption opt) {
    final map = _readSortOptionsSafe();
    return map[opt];
  }

  // Extract categories list safely
  List<dynamic> _extractCategories(dynamic catsRaw) {
    if (catsRaw == null) return [];
    if (catsRaw is List) return catsRaw;
    try {
      final dyn = catsRaw as dynamic;
      if (dyn.categories is List) return List<dynamic>.from(dyn.categories as List);
      if (dyn.data is List) return List<dynamic>.from(dyn.data as List);
      if (dyn.items is List) return List<dynamic>.from(dyn.items as List);
      if (dyn.list is List) return List<dynamic>.from(dyn.list as List);
    } catch (_) {}
    return [];
  }

  // Find category name by backend id. If not found, return fallback label based on enum.
  String _categoryNameFromId(String? id, dynamic catsRaw) {
    if (id == null || id.isEmpty) {
      // legacy: show friendly label for enum-based selection
      return _categoryLabel(selectedCategory);
    }
    final list = _extractCategories(catsRaw);
    if (list.isEmpty) return _categoryLabel(selectedCategory);
    try {
      final found = list.firstWhere((c) {
        try {
          final cid = (c as dynamic).id;
          return cid != null && cid.toString() == id;
        } catch (_) {
          return false;
        }
      }, orElse: () => null);
      if (found == null) return _categoryLabel(selectedCategory);
      final name = ((found as dynamic).name ?? (found as dynamic).title ?? id).toString();
      return name;
    } catch (_) {
      return _categoryLabel(selectedCategory);
    }
  }

  String _categoryLabel(CategoryFilterOption c) {
    switch (c) {
      case CategoryFilterOption.all:
        return 'Tümü';
      case CategoryFilterOption.food:
        return 'Yemek';
      case CategoryFilterOption.bakery:
        return 'Fırın & Pastane';
      case CategoryFilterOption.breakfast:
        return 'Kahvaltı';
      case CategoryFilterOption.market:
        return 'Market & Manav';
      case CategoryFilterOption.vegetarian:
        return 'Vejetaryen';
      case CategoryFilterOption.vegan:
        return 'Vegan';
      case CategoryFilterOption.glutenFree:
        return 'Glutensiz';
    }
  }

  String _sortLabel(ExploreFilterOption opt) {
    switch (opt) {
      case ExploreFilterOption.recommended:
        return 'Önerilen';
      case ExploreFilterOption.price:
        return 'Fiyat';
      case ExploreFilterOption.distance:
        return 'Mesafe';
      case ExploreFilterOption.rating:
        return 'Puan';
    }
  }

  // ---------------------------
  // UI: backend-driven category sheet (returns selected id or null)
  // ---------------------------
  Future<String?> _showBackendCategoriesSheet(List categories) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String? pickedId = selectedCategoryId ?? ref.read(exploreStateProvider).categoryId;
        return StatefulBuilder(builder: (c, setState2) {
          return SafeArea(
            top: false,
            child: FractionallySizedBox(
              heightFactor: 0.80, // leave space for custom bottom bar
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const Text('Kategori Seç', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: categories.map<Widget>((cat) {
                            final idStr = ((cat as dynamic).id).toString();
                            final title = ((cat as dynamic).name ?? (cat as dynamic).title ?? idStr).toString();
                            return RadioListTile<String>(
                              value: idStr,
                              groupValue: pickedId,
                              title: Text(title),
                              onChanged: (v) => setState2(() => pickedId = v),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(ctx).viewPadding.bottom + kBottomNavigationBarHeight / 1.5,
                        top: 8,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, pickedId),
                          child: const Text('Uygula'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  // ---------------------------
  // UI: backend-driven SORT sheet (returns map {'opt': ExploreFilterOption, 'dir': SortDirection})
  // ---------------------------
  Future<Map<String, dynamic>?> _showBackendSortSheet(Map<ExploreFilterOption, String?> sortOptions) {
    // If backend does not provide any mapping, we still show the local options (fallback)
    final options = sortOptions.keys.toList();
    final available = options.isNotEmpty ? options : ExploreFilterOption.values;

    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        ExploreFilterOption picked = selectedFilter;
        SortDirection pickedDir = sortDirection;
        return StatefulBuilder(builder: (c, setState2) {
          return SafeArea(
            top: false,
            child: FractionallySizedBox(
              heightFactor: 0.6,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const Text('Sırala', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: available.map((opt) {
                            return RadioListTile<ExploreFilterOption>(
                              value: opt,
                              groupValue: picked,
                              title: Text(_sortLabel(opt)),
                              onChanged: (v) => setState2(() => picked = v!),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sıralama yönü: '),
                        IconButton(
                          icon: Transform.rotate(
                            angle: pickedDir == SortDirection.ascending ? 0 : 3.14159,
                            child: const Icon(Icons.arrow_upward),
                          ),
                          onPressed: () => setState2(() {
                            pickedDir = pickedDir == SortDirection.ascending ? SortDirection.descending : SortDirection.ascending;
                          }),
                        ),
                        Text(pickedDir == SortDirection.ascending ? 'Artan' : 'Azalan'),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(ctx).viewPadding.bottom + kBottomNavigationBarHeight / 1.5,
                        top: 8,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, {'opt': picked, 'dir': pickedDir}),
                          child: const Text('Uygula'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  // ---------------------------
  // BUILD
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    final address = ref.watch(addressProvider);
    final productsState = ref.watch(productsProvider);
    final categoriesRaw = ref.watch(categoryProvider);

    // listen to products state changes and apply filters when changed
    ref.listen<ProductsState>(productsProvider, (prev, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _applyFilters(next.products);
      });
    });

    // ensure initial application if backend already provided items
    final products = productsState.products;
    if (filteredProducts.isEmpty && products.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _applyFilters(products);
      });
    }

    // read sort options safely and pass to header & sort sheet
    final sortOptions = _readSortOptionsSafe();

    debugPrint('EXPLORE LIST BUILD products=${productsState.products.length} filtered=${filteredProducts.length} loading=${productsState.isLoadingList}');

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
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())
            : null,
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildHeader(categoriesRaw, address, sortOptions, _categoryNameFromId(selectedCategoryId, categoriesRaw)),
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
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
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

  // Header builder with injected sortOptions and currentCategoryLabel
  SliverPersistentHeader _buildHeader(
      dynamic categoriesRaw,
      dynamic address,
      Map<ExploreFilterOption, String?> sortOptions,
      String currentCategoryLabel,
      ) {
    final categoriesList = _extractCategories(categoriesRaw);
    final currentCategoryId = selectedCategoryId ?? ref.read(exploreStateProvider).categoryId;
    final currentCategoryLabelComputed = _categoryNameFromId(currentCategoryId, categoriesRaw);

    return SliverPersistentHeader(
      pinned: true,
      delegate: ExploreHeaderDelegate(
        controller: _searchController,
        selectedSort: selectedFilter,
        sortDirection: sortDirection,
        selectedCategory: selectedCategory,
        currentCategoryLabel: currentCategoryLabelComputed,

        // SEARCH → local filter
        onSearchChanged: (_) {
          final all = ref.read(productsProvider).products;
          _applyFilters(all);
        },

        // SORT → open backend/constructed sheet (Apply inside sheet)
        onSortChanged: (opt) async {
          final res = await _showBackendSortSheet(sortOptions);
          if (res == null) return;

          final picked = res['opt'] as ExploreFilterOption;
          final dir = res['dir'] as SortDirection;

          setState(() {
            selectedFilter = picked;
            sortDirection = dir;
          });

          if (address == null || address.isSelected == false) {
            debugPrint('❌ ADDRESS NOT SELECTED → SKIP FETCH');
            return;
          }

          final categoryIdFromState = selectedCategoryId ?? ref.read(exploreStateProvider).categoryId;
          final apiSort = _apiSortFor(selectedFilter);
          final sortOrder = sortDirection == SortDirection.ascending ? 'asc' : 'desc';

          debugPrint('📡 SORT SELECTED → apiSort=$apiSort sortOrder=$sortOrder');

          if (apiSort == null) {
            // fallback client-side
            final all = ref.read(productsProvider).products;
            _applyFilters(all);
            return;
          }

          await ref.read(productsProvider.notifier).refresh(
            latitude: address.lat,
            longitude: address.lng,
            categoryId: categoryIdFromState,
            sortBy: apiSort,
            sortOrder: sortOrder,
          );
        },

        // CATEGORY → backend-driven sheet when available
        onCategoryTap: () async {
          if (categoriesList.isNotEmpty) {
            final pickedId = await _showBackendCategoriesSheet(categoriesList);
            if (pickedId == null) return;

            debugPrint('🟡 UI CATEGORY SELECTED (ID) → $pickedId');
            setState(() {
              selectedCategoryId = pickedId;
              selectedCategory = CategoryFilterOption.all; // show backend label instead of enum
            });

            ref.read(exploreStateProvider.notifier).setCategoryId(pickedId);

            if (address == null || address.isSelected == false) return;

            final apiSort = _apiSortFor(selectedFilter);
            final sortOrder = sortDirection == SortDirection.ascending ? 'asc' : 'desc';

            await ref.read(productsProvider.notifier).refresh(
              latitude: address.lat,
              longitude: address.lng,
              categoryId: pickedId,
              sortBy: apiSort ?? 'created_at',
              sortOrder: apiSort == null ? 'desc' : sortOrder,
            );

            return;
          }

          // fallback legacy enum sheet
          final res = await showModalBottomSheet<CategoryFilterOption>(
            context: context,
            isScrollControlled: true,
            builder: (_) => CategoryFilterSheet(
              selected: selectedCategory,
              onApply: (c) => Navigator.pop(context, c),
            ),
          );
          if (res == null) return;

          final categoryId = mapCategoryToCategoryId(res);
          setState(() {
            selectedCategory = res;
            selectedCategoryId = categoryId;
          });

          ref.read(exploreStateProvider.notifier).setCategoryId(categoryId ?? '');

          if (address == null || address.isSelected == false) return;

          await ref.read(productsProvider.notifier).refresh(
            latitude: address.lat,
            longitude: address.lng,
            categoryId: categoryId,
            sortBy: _apiSortFor(selectedFilter) ?? 'created_at',
            sortOrder: sortDirection == SortDirection.ascending ? 'asc' : 'desc',
          );
        },
      ),
    );
  }
}

// ---------------------------
// Header delegate (unchanged layout, but accepts currentCategoryLabel)
// ---------------------------
class ExploreHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final ExploreFilterOption selectedSort;
  final SortDirection sortDirection;
  final CategoryFilterOption selectedCategory;
  final String currentCategoryLabel;

  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ExploreFilterOption?> onSortChanged;
  final VoidCallback onCategoryTap;

  ExploreHeaderDelegate({
    required this.controller,
    required this.selectedSort,
    required this.sortDirection,
    required this.selectedCategory,
    required this.currentCategoryLabel,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onCategoryTap,
  });

  @override
  double get minExtent => 120;

  @override
  double get maxExtent => 120;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
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
                turns: sortDirection == SortDirection.ascending ? 0 : 0.5,
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
              // open sheet handled by onSortChanged
              onSortChanged(selectedSort);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                _labelForSort(selectedSort),
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

  String _labelForSort(ExploreFilterOption opt) {
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
          "Kategori: $currentCategoryLabel",
          style: const TextStyle(
            color: AppColors.primaryDarkGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}