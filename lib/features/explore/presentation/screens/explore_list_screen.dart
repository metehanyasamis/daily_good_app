// lib/features/explore/presentation/screens/explore_list_screen.dart

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
  String? selectedCategoryId;

  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> filteredProducts = [];

  bool _isInitialLoading = true; // 🔥 İlk açılışta "bulunamadı" yazısını engellemek için


  bool _fromHomeFlag = false; // Yeni değişken

  @override
  void initState() {
    super.initState();
    _isInitialLoading = true;

    Future.microtask(() {
      if (!mounted) return;
      final dynamic extra = GoRouterState.of(context).extra;

      if (extra is Map) {
        setState(() {
          if (extra['filter'] is ExploreFilterOption) {
            selectedFilter = extra['filter'];
          }
          // Home'dan gelip gelmediğini buradan da teyit edelim
          _fromHomeFlag = extra['fromHome'] ?? widget.fromHome;

          final val = extra['categoryId'] ?? extra['category_id'] ?? extra['id'];
          if (val != null) selectedCategoryId = val.toString();
          print("🏠 [EXPLORE_INIT] Extra Data: ${GoRouterState.of(context).extra}");
        });
      }
      _fetchData();
    });
  }

  // API Çağrısını merkezi bir yere topladık
  void _fetchData() async {
    final address = ref.read(addressProvider);
    if (!address.isSelected) return;

    final String sortBy = _apiSortFor(selectedFilter) ?? 'created_at';
    final String sortOrder = sortDirection == SortDirection.ascending ? 'asc' : 'desc';

    // 🔴 DEBUG 1: İSTEK PARAMETRELERİ
    print("--------------------------------------------------");
    print("📡 [EXPLORE_DEBUG] İSTEK BAŞLATILDI");
    print("   🔹 Hedef Filtre: $selectedFilter");
    print("   🔹 API sortBy: $sortBy");
    print("   🔹 Kategori ID: $selectedCategoryId");
    print("   🔹 Koordinat: ${address.lat}, ${address.lng}");

    setState(() {
      _isInitialLoading = true;
      filteredProducts = [];
    });

    try {
      await ref.read(productsProvider.notifier).refresh(
        latitude: address.lat,
        longitude: address.lng,
        categoryId: selectedCategoryId,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      if (mounted) {
        final allProducts = ref.read(productsProvider).products;

        // 🔴 DEBUG 2: API SONUCU
        print("📥 [EXPLORE_DEBUG] VERİ GELDİ");
        print("   🔹 Ham Ürün Sayısı: ${allProducts.length}");

        if (allProducts.isNotEmpty) {
          print("   🔹 İlk Ürün: ${allProducts.first.name} (ID: ${allProducts.first.id})");
        }

        _applyFilters(allProducts);

        // 🔴 DEBUG 3: FİLTRE SONRASI DURUM
        print("   🔹 UI Listesi Sayısı (filteredProducts): ${filteredProducts.length}");
        print("--------------------------------------------------");

        setState(() => _isInitialLoading = false);
      }
    } catch (e) {
      print("❌ [EXPLORE_DEBUG] HATA: $e");
      setState(() => _isInitialLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters(List<ProductModel> allProducts) {
    if (allProducts.isEmpty) {
      if (filteredProducts.isNotEmpty) setState(() => filteredProducts = []);
      return;
    }

    List<ProductModel> temp = allProducts.where((p) {
      final bool hasValidId = p.id != null && p.id.isNotEmpty;
      final bool hasValidName = p.name != null && p.name.isNotEmpty && p.name != "İsimsiz Ürün";
      final bool hasValidStore = p.store != null && p.store.name != null && p.store.name.isNotEmpty;
      return hasValidId && hasValidName && hasValidStore;
    }).toList();

    // 🔥 HATALARI GİDEREN YENİ FİLTRELEME MANTIĞI
    switch (selectedFilter) {
      case ExploreFilterOption.sonSans:
      // Modelinde 'isLastChance' yoksa, backend genelde stok miktarını gönderir.
      // Logda 'stock' alanı varsa onu kullanıyoruz:
        temp = temp.where((p) => (p.stock ?? 0) > 0 && (p.stock ?? 0) < 10).toList();
        break;

      case ExploreFilterOption.hemenYaninda:
      // 'distance' modelde yoksa hata verir. Modelinde mesafe hangi isimle kayıtlı?
      // Eğer mesafe verisi henüz modelde yoksa bu satırı yorum satırı yapabilirsin:
      // temp = temp.where((p) => (p.store.distanceValue ?? 0) <= 5.0).toList();
        break;

      case ExploreFilterOption.yeni:
      // 'createdAt' üzerinden manuel kontrol
        final limit = DateTime.now().subtract(const Duration(days: 7));
        temp = temp.where((p) => p.createdAt.isAfter(limit)).toList();
        break;

      default:
        break;
    }

    // Arama Filtresi
    final q = _searchController.text.trim().toLowerCase();
    if (q.length >= 3) {
      temp = temp.where((p) => p.name.toLowerCase().contains(q) || p.store.name.toLowerCase().contains(q)).toList();
    }

    // Sıralama
    temp.sort((a, b) {
      if (selectedFilter == ExploreFilterOption.price) {
        return (sortDirection == SortDirection.ascending)
            ? a.salePrice.compareTo(b.salePrice)
            : b.salePrice.compareTo(a.salePrice);
      }
      if (selectedFilter == ExploreFilterOption.rating) {
        return (sortDirection == SortDirection.ascending)
            ? (a.store.overallRating ?? 0.0).compareTo(b.store.overallRating ?? 0.0)
            : (b.store.overallRating ?? 0.0).compareTo(a.store.overallRating ?? 0.0);
      }
      return 0; // Diğer durumlarda API sırasını bozma
    });

    setState(() => filteredProducts = temp);
  }

  String? _apiSortFor(ExploreFilterOption opt) {
    // Burada yeni eklediğin enum değerlerini backend tag'lerine eşliyoruz
    switch (opt) {
      case ExploreFilterOption.hemenYaninda: return 'hemen-yaninda';
      case ExploreFilterOption.yeni: return 'yeni';
      case ExploreFilterOption.sonSans: return 'son-sans';
      case ExploreFilterOption.bugun: return 'bugun';
      case ExploreFilterOption.yarin: return 'yarin';
      default:
        final raw = _readSortOptionsRaw();
        return raw[opt];
    }
  }

  Map<ExploreFilterOption, String?> _readSortOptionsRaw() {
    final dynamic raw = ref.watch(sortByMapProvider);
    if (raw == null) return <ExploreFilterOption, String?>{};
    if (raw is Map<ExploreFilterOption, String?>) return raw;
    return <ExploreFilterOption, String?>{};
  }

  List<dynamic> _extractCategories(dynamic catsRaw) {
    if (catsRaw == null) return [];
    if (catsRaw is List) return catsRaw;
    try {
      final dyn = catsRaw as dynamic;
      if (dyn.categories is List) return List<dynamic>.from(dyn.categories as List);
    } catch (_) {}
    return [];
  }

  String _categoryNameFromId(String? id, dynamic catsRaw) {
    final list = _extractCategories(catsRaw);
    if (id != null && id.isNotEmpty) {
      final found = list.firstWhere((c) {
        try { return (c as dynamic).id.toString() == id; } catch (_) { return false; }
      }, orElse: () => null);
      if (found != null) return (found as dynamic).name.toString();
      return id;
    }
    return "Hepsi";
  }

  @override
  Widget build(BuildContext context) {
    final address = ref.watch(addressProvider);
    final productsState = ref.watch(productsProvider);
    final categoriesRaw = ref.watch(categoryProvider);

    ref.listen<ProductsState>(productsProvider, (prev, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _applyFilters(next.products);
      });
    });

    final currentCategoryId = selectedCategoryId ?? ref.read(exploreStateProvider).categoryId;
    final currentCategoryLabel = _categoryNameFromId(currentCategoryId, categoriesRaw);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomHomeAppBar(
        address: address.title,
        onLocationTap: () => context.push('/location-picker'),
        onNotificationsTap: () {},
        // 🔥 GÜNCELLEDİK: canPop varsa butonu göster
        leadingOverride: (context.canPop() || _fromHomeFlag)
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        )
            : null,
      ),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: (_isInitialLoading) // 🔥 Sadece çekim bitene kadar loader göster
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
              key: const ValueKey('content_scroll'),
              slivers: [
                _buildHeader(categoriesRaw, address, currentCategoryLabel),
                if (filteredProducts.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: Text("Ürün bulunamadı.")),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, i) => ProductCard(
                          key: ValueKey(filteredProducts[i].id),
                          product: filteredProducts[i],
                          onTap: () => context.push('/product-detail/${filteredProducts[i].id}'),
                        ),
                        childCount: filteredProducts.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
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

  SliverPersistentHeader _buildHeader(
      dynamic categoriesRaw,
      dynamic address,
      String currentCategoryLabel,
      ) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: ExploreHeaderDelegate(
        controller: _searchController,
        selectedSort: selectedFilter,
        sortDirection: sortDirection,
        selectedCategory: selectedCategory, // Bu satırı ekledik
        currentCategoryLabel: currentCategoryLabel,
        onSearchChanged: (_) {
          final all = ref.read(productsProvider).products;
          _applyFilters(all);
        },
        // onQuickFilterSelected yerine onSortChanged üzerinden yürüyoruz
        onSortChanged: (opt) {
          if (opt != null && opt != selectedFilter) {
            // Eğer hızlı filtre çipine tıklandıysa direkt filtrele
            setState(() => selectedFilter = opt);
            _fetchData(); // Sende refresh yapan metodun ismi
          } else {
            // Eğer zaten seçili olana tıklandıysa detaylı Sheet'i aç
            _handleSortSelection(selectedFilter);
          }
        },
        onCategoryTap: () => _handleCategorySelection(categoriesRaw),
      ),
    );
  }

  // --- Sheet Yöneticileri ---
  void _handleSortSelection(ExploreFilterOption? current) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExploreFilterSheet(
        selected: selectedFilter,
        direction: sortDirection,
        availableOptions: [ExploreFilterOption.recommended, ExploreFilterOption.price, ExploreFilterOption.rating, ExploreFilterOption.distance],
        onApply: (picked, dir) {
          Navigator.pop(ctx);
          setState(() { selectedFilter = picked; sortDirection = dir; });
          _fetchData();
        },
      ),
    );
  }

  void _handleCategorySelection(dynamic categoriesRaw) async {
    final categoriesList = _extractCategories(categoriesRaw);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryFilterSheet(
        selectedId: selectedCategoryId,
        backendCategories: categoriesList.isNotEmpty ? categoriesList : null,
        onApply: (selectedMap) {
          Navigator.pop(context);
          setState(() {
            selectedCategoryId = selectedMap['id'];
            selectedCategory = CategoryFilterOption.all;
          });
          _fetchData();
        },
      ),
    );
  }
}

// ---------------------------
// HEADER DELEGATE - Tasarımı bozmadan Hızlı Filtreleri ekledik
// ---------------------------
class ExploreHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final ExploreFilterOption selectedSort;
  final SortDirection sortDirection;
  final CategoryFilterOption selectedCategory; // Geri eklendi
  final String currentCategoryLabel;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ExploreFilterOption?> onSortChanged;
  final VoidCallback onCategoryTap;
  final ScrollController _chipScrollController = ScrollController();

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

  @override double get minExtent => 175;
  @override double get maxExtent => 175;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // 2. Seçili öğenin index'ini buluyoruz
    final filters = [
      ExploreFilterOption.hemenYaninda,
      ExploreFilterOption.sonSans,
      ExploreFilterOption.yeni,
      ExploreFilterOption.bugun,
      ExploreFilterOption.yarin,
    ];
    final selectedIndex = filters.indexOf(selectedSort);

    // 3. Ekran çizildikten hemen sonra seçili öğeye kaydır
    if (selectedIndex != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_chipScrollController.hasClients) {
          // Çip genişliği + margin (yaklaşık 100-110 birim)
          double offset = selectedIndex * 95.0;
          _chipScrollController.animateTo(
            offset.clamp(0.0, _chipScrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. SATIR: SIRALA BUTONU + KATEGORİLER (Yemek, Kahvaltı vb.)
          Row(
            children: [
              _sortTuneButton(),
              const SizedBox(width: 8),
              Expanded(
                child: _categoryModernButton(), // Kategorileri buraya aldık
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 2. SATIR: ARAMA FIELD
          _buildSearchField(),
          const SizedBox(height: 6),

          // 3. SATIR: HIZLI FİLTRE BAŞLIKLARI (Hemen Yanında, Son Şans vb.)
          SizedBox(
            height: 40,
            child: SingleChildScrollView(
              controller: _chipScrollController, // Controller bağlandı
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _quickChip("Hemen Yanımda", ExploreFilterOption.hemenYaninda),
                  _quickChip("Son Şans", ExploreFilterOption.sonSans),
                  _quickChip("Yeni", ExploreFilterOption.yeni),
                  _quickChip("Bugün", ExploreFilterOption.bugun),
                  _quickChip("Yarın", ExploreFilterOption.yarin),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Arama alanını temiz tutmak için ayırdım
  Widget _buildSearchField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: controller,
        onChanged: onSearchChanged,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey, size: 20),
          hintText: 'Ürün veya işletme ara...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  // Kategori butonu genişletildi
  Widget _categoryModernButton() {
    return InkWell(
      onTap: onCategoryTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryDarkGreen.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.layers_outlined, size: 18, color: AppColors.primaryDarkGreen),
                const SizedBox(width: 8),
                Text(
                  currentCategoryLabel,
                  style: const TextStyle(
                      color: AppColors.primaryDarkGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 14
                  ),
                ),
              ],
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryDarkGreen),
          ],
        ),
      ),
    );
  }

  Widget _sortTuneButton() {
    return InkWell(
      onTap: () => onSortChanged(selectedSort),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Icon(Icons.tune_rounded, size: 20, color: AppColors.primaryDarkGreen),
      ),
    );
  }

  Widget _quickChip(String label, ExploreFilterOption opt) {
    final isSelected = selectedSort == opt;
    return GestureDetector(
      onTap: () => onSortChanged(opt),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDarkGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primaryDarkGreen : Colors.grey.shade200),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}