import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/favorite_products_tab.dart';
import '../widgets/favorite_shops_tab.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorilerim'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Ürünler'),
              Tab(text: 'İşletmeler'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FavoriteProductsTab(),
            FavoriteShopsTab(),
          ],
        ),
      ),
    );
  }
}
