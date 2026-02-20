// lib/features/favorites/presentation/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // 1. Toolbar yüksekliğini biraz kısarak başlığı aşağı yaklaştırıyoruz
        toolbarHeight: 50,
        title: const Text(
          'Favorilerim',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18, // Biraz küçültmek arayı daha dar gösterir
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40), // TabBar yüksekliğini sabitledik
          child: Container(
            // 2. TabBar'ı yukarı çekmek için eksi margin veya transform kullanabiliriz
            // Ama en sağlıklısı başlığı aşağı, tab'ı yukarı iten bu padding düzenidir:
            padding: const EdgeInsets.only(bottom: 0),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryDarkGreen,
              unselectedLabelColor: Colors.black54,
              indicatorColor: AppColors.primaryDarkGreen,
              indicatorWeight: 3,
              // TabBar'ın kendi iç padding'ini sıfırlıyoruz
              labelPadding: EdgeInsets.zero,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              tabs: const [
                Tab(height: 40, text: 'Favori Ürün'),
                Tab(height: 40, text: 'Favori İşletme'),
              ],
            ),
          ),
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