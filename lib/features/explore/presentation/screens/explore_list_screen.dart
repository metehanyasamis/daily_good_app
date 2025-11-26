// ignore_for_file: prefer_const_constructors

import 'package:daily_good/core/widgets/custom_toggle_button.dart';
import 'package:daily_good/features/product/data/mock/mock_product_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_home_app_bar.dart';
import '../../../product/data/models/product_model.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../widgets/category_filter_option.dart';
import '../widgets/explore_filter_sheet.dart';
import '../widgets/category_filter_sheet.dart';

enum SortDirection { ascending, descending }

class ExploreListScreen extends StatefulWidget {
  final CategoryFilterOption? initialCategory;
  final bool fromHome;

  const ExploreListScreen({
    super.key,
    this.initialCategory,
    this.fromHome = false,
  });
  @override
  State<ExploreListScreen> createState() => _ExploreListScreenState();
}


class _ExploreListScreenState extends State<ExploreListScreen> {
  String selectedAddress = 'Nail Bey Sok.';

  ExploreFilterOption selectedFilter = ExploreFilterOption.recommended;
  SortDirection sortDirection = SortDirection.ascending;

  final List<ProductModel> allProducts = List.from(mockProducts);
  List<ProductModel> filteredProducts = List.from(mockProducts);

  CategoryFilterOption selectedCategory = CategoryFilterOption.all;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.initialCategory != null) {
      selectedCategory = widget.initialCategory!;
    }

    _applyFilters();
  }

  // ============================================================
  // 🔥 TEK FONKSİYON → Arama + Kategori + Sıralama
  // ============================================================
  void _applyFilters() {
    List<ProductModel> temp = List.from(allProducts);

    // 🔍 Arama
    final q = _searchController.text.trim().toLowerCase();
    if (q.length >= 3) {
      temp = temp.where((p) {
        return p.packageName.toLowerCase().contains(q) ||
            p.businessName.toLowerCase().contains(q);
      }).toList();
    }

    // 🟩 Kategori filtresi (artık direkt model'den gidiyoruz!)
    if (selectedCategory != CategoryFilterOption.all) {
      temp = temp.where((p) => p.category == selectedCategory).toList();
    }

    // 🔽 Sıralama
    temp.sort((a, b) {
      int result;
      switch (selectedFilter) {
        case ExploreFilterOption.recommended:
          result = b.rating.compareTo(a.rating);
          break;
        case ExploreFilterOption.price:
          result = a.newPrice.compareTo(b.newPrice);
          break;
        case ExploreFilterOption.rating:
          result = a.rating.compareTo(b.rating);
          break;
        case ExploreFilterOption.distance:
          result = a.distance.compareTo(b.distance);
          break;
      }

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
      shape: RoundedRectangleBorder(
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: CustomHomeAppBar(
          address: selectedAddress,
          onLocationTap: () {},
          onNotificationsTap: () {},
          leadingOverride: widget.fromHome
              ? IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.primaryDarkGreen),
            onPressed: () => context.pop(),
          )
              : null,
        ),
      ),

      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildHeader(),

              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 12),
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

              SliverToBoxAdapter(child: SizedBox(height: 120)),
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
      padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          // 🔍 Arama
          TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Restoran, paket veya mekan ara (3+ harf)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          SizedBox(height: 8),

          Row(
            children: [
              _sortCapsule(context),
              SizedBox(width: 10),
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
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: AnimatedRotation(
                turns: sortDirection == SortDirection.ascending ? 0 : .5,
                duration: Duration(milliseconds: 200),
                child: Icon(Icons.arrow_upward,
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => ExploreFilterSheet(
                  selected: selectedSort,
                  onApply: (opt) => onSortChanged(opt),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                _sortLabel(selectedSort),
                style: TextStyle(
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
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          "Kategori: ${categoryLabel(selectedCategory)}",
          style: TextStyle(
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
