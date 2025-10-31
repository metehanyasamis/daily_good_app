import 'package:daily_good/core/widgets/custom_toggle_button.dart';
import 'package:daily_good/features/product/data/mock/mock_product_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_home_app_bar.dart';
import '../../../product/data/models/product_model.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../widgets/explore_filter_sheet.dart';

enum SortDirection { ascending, descending }

class ExploreListScreen extends StatefulWidget {
  const ExploreListScreen({super.key});

  @override
  State<ExploreListScreen> createState() => _ExploreListScreenState();
}

class _ExploreListScreenState extends State<ExploreListScreen> {
  String selectedAddress = 'Nail Bey Sok.';
  ExploreFilterOption selectedFilter = ExploreFilterOption.recommended;
  SortDirection sortDirection = SortDirection.ascending;
  List<ProductModel> allProducts = List.from(mockProducts);
  List<ProductModel> filteredProducts = List.from(mockProducts);

  final TextEditingController _searchController = TextEditingController();

  // 🔍 Arama
  void _applySearch(String query) {
    final lower = query.trim().toLowerCase();
    setState(() {
      if (lower.length < 3) {
        filteredProducts = List.from(allProducts);
      } else {
        filteredProducts = allProducts.where((p) {
          return p.packageName.toLowerCase().contains(lower) ||
              p.businessName.toLowerCase().contains(lower);
        }).toList();
      }
      _applySorting();
    });
  }

  // 🔽 Sıralama mantığı
  void _applySorting() {
    final sorted = List<ProductModel>.from(filteredProducts);

    sorted.sort((a, b) {
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

    setState(() {
      filteredProducts = sorted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: CustomHomeAppBar(
          address: selectedAddress,
          onLocationTap: () {},
          onNotificationsTap: () {},
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _SearchAndSortHeader(
                  controller: _searchController,
                  selectedSort: selectedFilter,
                  sortDirection: sortDirection,
                  onSortChanged: (value) {
                    setState(() {
                      if (value == selectedFilter) {
                        sortDirection = sortDirection == SortDirection.ascending
                            ? SortDirection.descending
                            : SortDirection.ascending;
                      } else {
                        selectedFilter = value!;
                        sortDirection = SortDirection.ascending;
                      }
                      _applySorting();
                    });
                  },
                  onSearchChanged: _applySearch,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = filteredProducts[index];
                  return ProductCard(
                    product: product,
                    onTap: () =>
                        context.push('/product-detail', extra: product),
                  );
                }, childCount: filteredProducts.length),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),

          // 🔹 Harita / Liste geçiş butonu
          CustomToggleButton(
            label: "Harita",
            icon: Icons.map_outlined,
            onPressed: () => context.push('/explore-map'),
          ),
        ],
      ),
    );
  }
}

// 🔹 Header
class _SearchAndSortHeader extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final ExploreFilterOption selectedSort;
  final SortDirection sortDirection;
  final ValueChanged<ExploreFilterOption?> onSortChanged;
  final ValueChanged<String> onSearchChanged;

  _SearchAndSortHeader({
    required this.controller,
    required this.selectedSort,
    required this.sortDirection,
    required this.onSortChanged,
    required this.onSearchChanged,
  });

  @override
  double get minExtent => 100;

  @override
  double get maxExtent => 100;

  String _labelForOption(ExploreFilterOption opt) {
    switch (opt) {
      case ExploreFilterOption.recommended:
        return 'Önerilen';
      case ExploreFilterOption.distance:
        return 'Mesafeye göre';
      case ExploreFilterOption.price:
        return 'Fiyata göre';
      case ExploreFilterOption.rating:
        return 'Puana göre';
    }
  }

  String _sortDirectionLabel(ExploreFilterOption opt, SortDirection dir) {
    return dir == SortDirection.ascending ? '(Artan)' : '(Azalan)';
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Restoran, paket veya mekan ara (3+ harf)',
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('Sırala:', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(width: 6),

              // 🔹 Yeni sıralama kapsülü
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔽 Yön ok
                    InkWell(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                      ),
                      onTap: () {
                        onSortChanged(selectedSort);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: AnimatedRotation(
                          turns: sortDirection == SortDirection.ascending
                              ? 0.0
                              : 0.5,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: const Icon(
                            Icons.arrow_upward,
                            color: AppColors.primaryDarkGreen,
                            size: 18,
                          ),
                        ),
                      ),
                    ),

                    // 🔤 Etiket - filtre seçimi açar
                    InkWell(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      onTap: () {
                        showModalBottomSheet<ExploreFilterOption>(
                          context: context,
                          useRootNavigator: true,
                          isScrollControlled: true,
                          useSafeArea: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (_) => ExploreFilterSheet(
                            selected: selectedSort,
                            onApply: (opt) {
                              onSortChanged(opt);
                            },
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(
                          '${_labelForOption(selectedSort)} ${_sortDirectionLabel(selectedSort, sortDirection)}',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchAndSortHeader old) => true;
}
