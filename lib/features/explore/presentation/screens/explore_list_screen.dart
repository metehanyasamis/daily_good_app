import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Riverpod eklendi
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_home_app_bar.dart';
import '../../../product/data/models/product_model.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../widgets/category_filter_option.dart';
import '../widgets/explore_filter_sheet.dart';
import '../widgets/category_filter_sheet.dart';
import 'package:daily_good/core/widgets/custom_toggle_button.dart';


// ⚠️ MOCK VERİLERİ SİLİNDİ
// final List<ProductModel> mockProducts = ... (Kaldırıldı)

// -------------------------------------------------------------
// 🔥 YENİ: Asenkron Veriyi Yönetecek Basit Bir Provider Tanımı
// Normalde bu Repository/Notifier katmanında olur, ama derleme için burada dummy oluşturuyoruz.
final exploreProductListProvider = FutureProvider<List<ProductModel>>((ref) async {
  // 💡 Gerçek projede: ref.watch(productRepositoryProvider).getExploreProducts();

  // Şimdilik boş bir liste döndürerek mock verisini siliyoruz
  await Future.delayed(const Duration(milliseconds: 500));
  return [];
});
// -------------------------------------------------------------


enum SortDirection { ascending, descending }

// ✅ StatefulWidget -> ConsumerStatefulWidget
class ExploreListScreen extends ConsumerStatefulWidget {
  final CategoryFilterOption? initialCategory;
  final bool fromHome;

  const ExploreListScreen({
    super.key,
    this.initialCategory,
    this.fromHome = false,
  });
  @override
  ConsumerState<ExploreListScreen> createState() => _ExploreListScreenState();
}


class _ExploreListScreenState extends ConsumerState<ExploreListScreen> {
  String selectedAddress = 'Nail Bey Sok.';

  ExploreFilterOption selectedFilter = ExploreFilterOption.recommended;
  SortDirection sortDirection = SortDirection.ascending;

  // ⚠️ Mock verileri silindi, gerçek veriler ProductModel listesi olarak tutulacak
  List<ProductModel> _allProducts = [];
  List<ProductModel> filteredProducts = [];

  CategoryFilterOption selectedCategory = CategoryFilterOption.all;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.initialCategory != null) {
      selectedCategory = widget.initialCategory!;
    }

    // Veri asenkron yükleneceği için _applyFilters() burada çağrılmayacak.
  }

  // ============================================================
  // 🔥 TEK FONKSİYON → Arama + Kategori + Sıralama
  // ============================================================
  void _applyFilters() {
    List<ProductModel> temp = List.from(_allProducts);

    // 🔍 Arama
    final q = _searchController.text.trim().toLowerCase();
    if (q.length >= 3) {
      temp = temp.where((p) {
        // Hata Çözümü: Artık p.packageName ve p.businessName yerine p.name ve p.store.name kullanıyoruz
        return p.name.toLowerCase().contains(q) ||
            p.store.name.toLowerCase().contains(q);
      }).toList();
    }

    // 🟩 Kategori filtresi (⚠️ Kategori filtresini devre dışı bırakıyorum
    // çünkü ProductModel'de CategoryFilterOption alanı artık yok. API'ya göre yeniden yazılması gerekir)
    // if (selectedCategory != CategoryFilterOption.all) {
    //   temp = temp.where((p) => p.category == selectedCategory).toList();
    // }

    // 🔽 Sıralama
    temp.sort((a, b) {
      int result;
      // Hata Çözümü: Artık p.rating alanı ProductModel'de yok, ProductStoreModel'den geliyor 
      // veya mock'ta olmadığı için varsayılan değerlerle sıralama yapmalıyız. 
      // Şimdilik sadece Fiyat ve Mesafeyi bırakıyorum, Puan ve Önerilen'i varsayılan hale getiriyorum.

      switch (selectedFilter) {
        case ExploreFilterOption.recommended:
        // Varsayılan sıralama: Satış fiyatı azalan
          result = b.salePrice.compareTo(a.salePrice);
          break;
        case ExploreFilterOption.price:
          result = a.salePrice.compareTo(b.salePrice);
          break;
        case ExploreFilterOption.rating:
        // Hata Çözümü: Store'daki rating'i kullanmalıyız.
          result = a.store.rating.compareTo(b.store.rating);
          break;
        case ExploreFilterOption.distance:
        // Hata Çözümü: Store'daki distance'ı kullanmalıyız.
          result = a.store.distanceKm.compareTo(b.store.distanceKm);
          break;
      }

      // Sıralama yönünü de dikkate al
      return sortDirection == SortDirection.ascending ? result : -result;
    });

    setState(() => filteredProducts = temp);
  }

  // ============================================================
  // 🔥 Kategori bottom sheet
  // ============================================================
  void _openCategoryFilter() async {
    final res = await showModalBottomSheet<CategoryFilterOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CategoryFilterSheet(
        selected: selectedCategory,
        onApply: (cat) => Navigator.pop(context, cat),
      ),
    );

    if (res != null) {
      selectedCategory = res;
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Riverpod ile veriyi dinle
    final productListAsyncValue = ref.watch(exploreProductListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: CustomHomeAppBar(
          address: selectedAddress,
          onLocationTap: () {},
          onNotificationsTap: () {},
          leadingOverride: widget.fromHome
              ? IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryDarkGreen),
            onPressed: () => context.pop(),
          )
              : null,
        ),
      ),

      body: Stack(
        children: [
          productListAsyncValue.when(
            // ⏳ Yükleniyor
            loading: () => const Center(child: CircularProgressIndicator()),
            // ❌ Hata
            error: (err, stack) => Center(child: Text('Hata: $err')),
            // ✅ Veri geldi
            data: (products) {
              // Veri ilk geldiğinde state'i ayarla ve filtrele
              if (products.isNotEmpty && _allProducts.isEmpty) {
                // initState'te yapılamayan filtreleme ve ürün atamasını burada yapıyoruz.
                _allProducts = products;
                _applyFilters();
              }

              if (filteredProducts.isEmpty) {
                // Eğer filtreleme sonucunda liste boşsa veya henüz yüklenmediyse
                return const Center(child: Text("Filtrelerinize uygun ürün bulunamadı."));
              }

              return CustomScrollView(
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
                            onTap: () => context.push('/product-detail', extra: p),
                          );
                        },
                        childCount: filteredProducts.length,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              );
            },
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

  // ============================================================
  // HEADER
  // ============================================================
  SliverPersistentHeader _buildHeader() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _HeaderDelegate(
        controller: _searchController,
        selectedSort: selectedFilter,
        sortDirection: sortDirection,
        selectedCategory: selectedCategory,
        onSearchChanged: (v) => _applyFilters(),
        onSortChanged: (opt) {
          if (opt == null) return;

          if (opt == selectedFilter) {
            sortDirection = sortDirection == SortDirection.ascending
                ? SortDirection.descending
                : SortDirection.ascending;
          } else {
            selectedFilter = opt;
            sortDirection = SortDirection.ascending;
          }

          _applyFilters();
        },
        onCategoryTap: _openCategoryFilter,
      ),
    );
  }
}

// _HeaderDelegate kısmı değiştirilmedi, sadece `const` eklendi.
class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final ExploreFilterOption selectedSort;
  final SortDirection sortDirection;
  final CategoryFilterOption selectedCategory;

  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ExploreFilterOption?> onSortChanged;
  final VoidCallback onCategoryTap;

  _HeaderDelegate({
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

  // -------------------------------------------------------
  @override
  Widget build(context, shrink, overlap) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          // 🔍 Arama
          TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Restoran, paket veya mekan ara (3+ harf)',
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
          )
        ],
      ),
    );
  }

  // -------------------------------------------------------
  //  SIRALAMA KAPSÜLÜ
  // -------------------------------------------------------
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
                turns: sortDirection == SortDirection.ascending ? 0 : .5,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.arrow_upward,
                    color: AppColors.primaryDarkGreen),
              ),
            ),
          ),

          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                useSafeArea: true,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => ExploreFilterSheet(
                  selected: selectedSort,
                  onApply: (opt) => onSortChanged(opt),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  // -------------------------------------------------------
  //  KATEGORİ BUTONU
  // -------------------------------------------------------
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
  bool shouldRebuild(_) => true;
}