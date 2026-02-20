// lib/features/explore/presentation/screens/explore_list_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/platform/platform_widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_home_app_bar.dart';
import '../../../../core/widgets/custom_toggle_button.dart';
import '../../../category/domain/category_notifier.dart';
import '../../../location/domain/address_notifier.dart';

import '../../../product/data/models/product_model.dart';
import '../../../product/domain/products_notifier.dart';
import '../../../product/domain/products_state.dart';
import '../../../product/presentation/widgets/product_card.dart';

import '../../domain/providers/category_flag_provider.dart';
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
  Timer? _searchDebounce;
  String? _lastBackendSearch; // debug için
  final FocusNode _searchFocus = FocusNode();
  String selectedCategoryName = 'Tümü';



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

      final extra = GoRouterState.of(context).extra;

      // Default: bottom-nav gibi düşün → feed/category temiz
      ExploreFilterOption? incomingFilter;
      String? incomingCategoryId;
      bool fromHome = widget.fromHome;

      if (extra is Map) {
        // filter
        final f = extra['filter'];
        if (f is ExploreFilterOption) incomingFilter = f;

        // fromHome
        fromHome = (extra['fromHome'] == true);

        // category id (önemli: null ise null kalmalı)
        final dynamic val = extra['categoryId'] ?? extra['category_id'] ?? extra['id'];
        if (val != null && val.toString().trim().isNotEmpty && val.toString() != 'null') {
          incomingCategoryId = val.toString();
        } else {
          incomingCategoryId = null;
        }

        debugPrint("🏠 [EXPLORE_INIT] extra=$extra");
        debugPrint("🏠 [EXPLORE_INIT] incomingFilter=$incomingFilter fromHome=$fromHome incomingCategoryId=$incomingCategoryId");
      } else {
        debugPrint("🏠 [EXPLORE_INIT] extra yok / map değil: $extra");
      }

      // 1) UI state
      setState(() {
        _fromHomeFlag = fromHome;
        selectedFilter = incomingFilter ?? ExploreFilterOption.recommended;
        selectedCategoryId = incomingCategoryId; // null olabilir
      });

      // 2) Global explore state (tek yerden set)
      final feedFilters = {
        ExploreFilterOption.hemenYaninda,
        ExploreFilterOption.sonSans,
        ExploreFilterOption.yeni,
        ExploreFilterOption.bugun,
        ExploreFilterOption.yarin,
      };

      // feedFilter set / clear
      ref.read(exploreStateProvider.notifier).setFeedFilter(
        feedFilters.contains(selectedFilter) ? selectedFilter : null,
      );

      // categoryId set (null olabilir)
      ref.read(exploreStateProvider.notifier).setCategoryId(selectedCategoryId);
      debugPrint("🔍🔍🔍 [UI_SUBMIT_SEARCH] text='${_searchController.text}' feed=$selectedFilter cat=$selectedCategoryId");

      debugPrint("🏠 [EXPLORE_INIT] ✅ exploreState.feedFilter=${feedFilters.contains(selectedFilter) ? selectedFilter : null}");
      debugPrint("🏠 [EXPLORE_INIT] ✅ exploreState.categoryId=$selectedCategoryId");

      _fetchData();
    });
  }


  // API Çağrısını merkezi bir yere topladık
  void _fetchData({String? searchOverride, bool keepOldList = false}) async {
    final address = ref.read(addressProvider);
    if (!address.isSelected) return;

    setState(() {
      _isInitialLoading = true;

      // ❌ search sırasında listeyi sıfırlama
      if (!keepOldList) filteredProducts = [];
    });

    try {
      final explore = ref.read(exploreStateProvider);
      final flagMap = ref.read(categoryFlagMapProvider);
      final flagKey = flagMap[explore.feedFilter];

      final String sortBy = _apiSortFor(selectedFilter) ?? 'created_at';
      final String sortOrder = sortDirection == SortDirection.ascending ? 'asc' : 'desc';

      final String? categoryIdToSend = explore.categoryId;
      debugPrint("📡 [FETCH] categoryId=$categoryIdToSend feed=${explore.feedFilter} search=${_searchController.text}");

      // ✅ Search: 3+ ise backend’e gidecek
      final String? searchToSend = (searchOverride != null && searchOverride.trim().isNotEmpty)
          ? searchOverride.trim()
          : null;

      _lastBackendSearch = searchToSend;

      debugPrint("   perPage=200 page=1");

      debugPrint("🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥");
      debugPrint("🚀 [FETCH_TRIGGER]");
      debugPrint("   fromHome=$_fromHomeFlag");
      debugPrint("   selectedFilter=$selectedFilter");
      debugPrint("   explore.feedFilter=${explore.feedFilter}");
      debugPrint("   flagKey=$flagKey");
      debugPrint("   categoryIdToSend=$categoryIdToSend");
      debugPrint("   searchToSend=$searchToSend");
      debugPrint("   lat=${address.lat} lng=${address.lng}");
      debugPrint("🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥");


      await ref.read(productsProvider.notifier).refresh(
        latitude: address.lat,
        longitude: address.lng,
        categoryId: categoryIdToSend,
        search: searchToSend,        // ✅ EKLENDİ
        sortBy: sortBy,
        sortOrder: sortOrder,
        perPage: 200,                // ✅ EKLENDİ (aşağıda notifier güncelleyeceğiz)

        hemenYaninda: flagKey == 'hemen_yaninda' ? true : null,
        sonSans: flagKey == 'son_sans' ? true : null,
        yeni: flagKey == 'yeni' ? true : null,
        bugun: flagKey == 'bugun' ? true : null,
        yarin: flagKey == 'yarin' ? true : null,
      );

      if (!mounted) return;

      final allProducts = ref.read(productsProvider).products;

      debugPrint("📥 [EXPLORE_FETCH] DONE products=${allProducts.length}");
      if (allProducts.isNotEmpty) {
        debugPrint("   first=${allProducts.first.name} id=${allProducts.first.id}");
      }

      _applyFilters(allProducts);

      debugPrint("🏁 [EXPLORE_FETCH] UI filtered=${filteredProducts.length}");
      debugPrint("--------------------------------------------------");

      setState(() => _isInitialLoading = false);
    } catch (e) {
      debugPrint("❌ [EXPLORE_FETCH] ERROR: $e");
      if (mounted) setState(() => _isInitialLoading = false);
    }
  }



  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }


  void _applyFilters(List<ProductModel> allProducts) {
    // ------------------------------------------------------------
    // 0) Boş liste
    // ------------------------------------------------------------
    if (allProducts.isEmpty) {
      if (filteredProducts.isNotEmpty) {
        setState(() => filteredProducts = []);
      }
      debugPrint("🧹 [APPLY_FILTERS] allProducts boş, filtered temizlendi.");
      return;
    }

    debugPrint("🧪 [APPLY_FILTERS] Başladı | selectedFilter=$selectedFilter | total=${allProducts.length}");

    // ------------------------------------------------------------
    // 1) Sadece UI'da gösterilebilir "geçerli" ürünleri al
    // ------------------------------------------------------------
    List<ProductModel> temp = allProducts.where((p) {
      final bool hasValidId = p.id.isNotEmpty;
      final bool hasValidName = p.name.isNotEmpty && p.name != "İsimsiz Ürün";
      final bool hasValidStore = p.store.name.isNotEmpty;
      return hasValidId && hasValidName && hasValidStore;
    }).toList();

    debugPrint("✅ [APPLY_FILTERS] validProducts=${temp.length}");

    // ------------------------------------------------------------
    // 2) Backend-driven kategoriler burada filtrelenmez
    // ------------------------------------------------------------
    // (hemenYaninda / sonSans / yeni / bugun / yarin) backend'den zaten filtreli gelir.
    // Burada client-side extra filtre yaparsan, Home vs Explore uyuşmaz.
    // O yüzden burada HİÇBİR şey yapmıyoruz.

    // ------------------------------------------------------------
    // 3) Arama (3+ karakter)
    // ------------------------------------------------------------
    final q = _searchController.text.trim().toLowerCase();
    final didBackendSearch = (_lastBackendSearch != null && _lastBackendSearch!.isNotEmpty);
    if (!didBackendSearch && q.length >= 3) {
      final before = temp.length;
      temp = temp.where((p) {
        final name = (p.name).toLowerCase();
        final storeName = (p.store.name).toLowerCase();
        return name.contains(q) || storeName.contains(q);
      }).toList();
      debugPrint("🔎 [APPLY_FILTERS] search='$q' before=$before after=${temp.length}");
    } else if (q.isNotEmpty) {
      debugPrint("ℹ️ [APPLY_FILTERS] search='$q' (3 harften kısa) filtre uygulanmadı.");
    } else {
      debugPrint("🔎 [APPLY_FILTERS] backend search active -> local search skipped");
    }

    // ------------------------------------------------------------
    // 4) Local sıralama (SADECE price/rating seçildiyse)
    // ------------------------------------------------------------
    // ÖNEMLİ: Diğer durumlarda API sırasını bozma.
    if (selectedFilter == ExploreFilterOption.price) {
      temp.sort((a, b) {
        final aPrice = a.salePrice;
        final bPrice = b.salePrice;
        return (sortDirection == SortDirection.ascending)
            ? aPrice.compareTo(bPrice)
            : bPrice.compareTo(aPrice);
      });
      debugPrint("💰 [APPLY_FILTERS] price sorted (${sortDirection.name})");
    } else if (selectedFilter == ExploreFilterOption.rating) {
      temp.sort((a, b) {
        final aR = a.store.overallRating ?? 0.0;
        final bR = b.store.overallRating ?? 0.0;
        return (sortDirection == SortDirection.ascending)
            ? aR.compareTo(bR)
            : bR.compareTo(aR);
      });
      debugPrint("⭐️ [APPLY_FILTERS] rating sorted (${sortDirection.name})");
    } else {
      debugPrint("↔️ [APPLY_FILTERS] API sırası korunuyor (local sort yok).");
    }

    // ------------------------------------------------------------
    // 5) State update
    // ------------------------------------------------------------
    setState(() => filteredProducts = temp);

    debugPrint("🏁 [APPLY_FILTERS] Bitti | filteredProducts=${filteredProducts.length}");

    if (filteredProducts.isNotEmpty) {
      final p = filteredProducts.first;
      debugPrint("🧾 [APPLY_FILTERS] first: id=${p.id} name=${p.name} store=${p.store.name} stock=${p.stock}");
    }
  }

  void _submitSearch() {
    final q = _searchController.text.trim();

    debugPrint('🔍 [SEARCH_SUBMIT] q="$q"');

    // boşsa: normal listeye dön
    if (q.isEmpty) {
      _lastBackendSearch = null;
      _fetchData(searchOverride: null, keepOldList: true);
      return;
    }

    // 1-2 harf yazdıysa backend’e gitme
    if (q.length < 3) return;

    _lastBackendSearch = q;
    _fetchData(searchOverride: q, keepOldList: true);
  }



  String? _apiSortFor(ExploreFilterOption opt) {
    final raw = _readSortOptionsRaw();
    return raw[opt]; // recommended/price/rating/distance
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
    if (id == null || id.isEmpty) return "Tümü";

    final list = _extractCategories(catsRaw);

    for (final c in list) {
      try {
        final cid = (c as dynamic).id.toString();
        if (cid == id) {
          final name = (c as dynamic).name;
          return (name ?? id).toString();
        }
      } catch (_) {
        // ignore
      }
    }

    return id; // bulamazsa id göster
  }


  @override
  Widget build(BuildContext context) {
    final address = ref.watch(addressProvider);
    final categoriesRaw = ref.watch(categoryProvider);


    ref.listen<ProductsState>(productsProvider, (prev, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _applyFilters(next.products);
      });
    });


    final currentCategoryLabel =
    selectedCategoryId == null
        ? 'Tümü'
        : _categoryNameFromId(selectedCategoryId, categoriesRaw);


    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomHomeAppBar(
        address: address.title,
        onLocationTap: () => context.push('/location-picker'),
        onNotificationsTap: () => context.push('/notifications'),
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
                ? Center(
              child: PlatformWidgets.loader(),
            )
                : CustomScrollView(
              key: const ValueKey('content_scroll'),
              slivers: [
                _buildHeader(categoriesRaw, address, currentCategoryLabel),
                if (_isInitialLoading)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: PlatformWidgets.loader(),
                      ),
                    ),
                  ),

                if (!_isInitialLoading && filteredProducts.isEmpty)
                  const SliverFillRemaining(child: Center(child: Text("Ürün bulunamadı.")))

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
    final searchEnabled = _searchController.text.trim().isNotEmpty;

    return SliverPersistentHeader(
      pinned: true,
      delegate: ExploreHeaderDelegate(

        controller: _searchController,
        searchFocus: _searchFocus,
        searchEnabled: searchEnabled,
        onSearchSubmit: _submitSearch,
        selectedSort: selectedFilter,
        sortDirection: sortDirection,
        selectedCategory: selectedCategory, // Bu satırı ekledik
        currentCategoryLabel: currentCategoryLabel,
        onSearchChanged: (_) {
          if (mounted) setState(() {});
        },
        // onQuickFilterSelected yerine onSortChanged üzerinden yürüyoruz
        onSortChanged: (opt) {
          if (opt == null) {
            _handleSortSelection(selectedFilter); // ✅ mevcut sort seçimli aç
            return;
          }

          // 1) Eğer bu bir FEED filtresi ise (Son Şans / Bugün / Yarın...)
          final feedFilters = {
            ExploreFilterOption.hemenYaninda,
            ExploreFilterOption.sonSans,
            ExploreFilterOption.yeni,
            ExploreFilterOption.bugun,
            ExploreFilterOption.yarin,
          };

          if (feedFilters.contains(opt)) {
            setState(() {
              selectedFilter = opt;
              // ✅ ben olsam desc yaparım ya da hiç dokunmam
              sortDirection = SortDirection.descending;
            });

            ref.read(exploreStateProvider.notifier).setFeedFilter(opt);

            // ✅ feed seçince sıralamayı recommended'a resetle
            ref.read(exploreStateProvider.notifier).setSort(ExploreFilterOption.recommended);

            debugPrint("🎛️ [FEED_PICK] feed=$opt | sort reset to recommended | dir=${sortDirection.name}");
            debugPrint("🧭 [FEED_PICK] state now: feedFilter=${ref.read(exploreStateProvider).feedFilter} sort=${ref.read(exploreStateProvider).sort}");

            _fetchData();
            return;
          }

          // 2) Yoksa bu SORT seçimidir (recommended/price/rating/distance)
          _handleSortSelection(selectedFilter);
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

          // ✅ opsiyonel ama öneririm:
          ref.read(exploreStateProvider.notifier).setSort(picked);
          ref.read(exploreStateProvider.notifier).setFeedFilter(null);
          debugPrint("🎚️ [SORT_APPLY] sort set: $picked | feedFilter cleared");

          _fetchData();
        },
      ),
    );
  }

  void _handleCategorySelection(dynamic categoriesRaw) async {
    final categoriesList = _extractCategories(categoriesRaw);

    // Sheet açıldığında mevcut seçili ID'yi gönderiyoruz
    debugPrint("🚀 [EXPLORE] Sheet Açılıyor. Mevcut Seçili ID: $selectedCategoryId");

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryFilterSheet(
        selectedId: selectedCategoryId, // Null ise 'Tümü' seçili açılır
        backendCategories: categoriesList.isNotEmpty ? categoriesList : null,
        onApply: (selectedMap) {
          Navigator.pop(context);

          final rawId = selectedMap['id']; // Sheet zaten bunu String? olarak gönderiyor
          final pickedName = selectedMap['name'] ?? 'Tümü';

          // 🚨 Tümü Kontrolü: ID null ise veya "null" stringi ise
          final String? finalPickedId = (rawId == null || rawId == "null" || rawId.toString().trim().isEmpty)
              ? null
              : rawId;

          debugPrint("🏷️ [CATEGORY_APPLY_CALLBACK] İsim: $pickedName -> Final ID: $finalPickedId");

          setState(() {
            selectedCategoryId = finalPickedId;
            selectedCategoryName = pickedName;

            // UI'daki yatay bar (varsa) için enum ayarı
            if (finalPickedId == null) {
              selectedCategory = CategoryFilterOption.all;
            } else {
              selectedCategory = CategoryFilterOption.custom;
            }
          });

          // Notifier'a işle
          ref.read(exploreStateProvider.notifier).setCategoryId(finalPickedId);

          // Listeyi yenile (Fetch fonksiyonun null ID'yi görünce tümünü çekecek)
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

  final VoidCallback onSearchSubmit;
  final bool searchEnabled; // ikon rengi için
  final FocusNode searchFocus;

  ExploreHeaderDelegate({
    required this.controller,
    required this.selectedSort,
    required this.sortDirection,
    required this.selectedCategory,
    required this.currentCategoryLabel,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onCategoryTap,

    required this.onSearchSubmit,
    required this.searchEnabled,
    required this.searchFocus,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        focusNode: searchFocus,
        controller: controller,

        // ✅ iOS klavyede “Ara” butonu
        textInputAction: TextInputAction.search,

        // ✅ her harfte backend yok — sadece UI state (ikon rengi vs) güncellensin
        onChanged: onSearchChanged,

        // ✅ klavyeden “Ara” basılınca
        onSubmitted: (_) => onSearchSubmit(),

        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search_rounded,
            color: searchEnabled ? Colors.black87 : Colors.grey, // ✅ canlanma
            size: 20,
          ),
          hintText: 'Ürün veya işletme ara...',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),

          // ✅ sağda “Ara” butonu (ikon)
          suffixIcon: IconButton(
            onPressed: searchEnabled ? onSearchSubmit : null,
            icon: Icon(
              Icons.search,
              color: searchEnabled ? AppColors.primaryDarkGreen : Colors.grey,
            ),
          ),
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
          border: Border.all(color: AppColors.primaryDarkGreen.withValues(alpha: 0.2)),
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
      onTap: () => onSortChanged(null),
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