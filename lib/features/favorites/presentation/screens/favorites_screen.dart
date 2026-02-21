// lib/features/favorites/presentation/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/favorite_products_tab.dart';
import '../widgets/favorite_shops_tab.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 🔥 Ekran her açıldığında arka planda favorileri tazele
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ProviderScope/WidgetRef'e erişmek için ProviderContainer
      // veya ConsumerStatefulWidget kullanmalısın.
      // Mevcut kodunu ConsumerStatefulWidget'a çevirmek en iyisi.
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Favorilerim',
        showBackButton: false,
        toolbarHeight: 50,

        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryDarkGreen,
          unselectedLabelColor: Colors.black54,
          indicatorColor: AppColors.primaryDarkGreen,
          indicatorWeight: 3,
          labelPadding: EdgeInsets.zero,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(height: 40, text: 'Favori Ürün'),
            Tab(height: 40, text: 'Favori İşletme'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FavoriteProductsTab(),
          FavoriteShopsTab(),
        ],
      ),
    );
  }
}