// lib/features/product/presentation/screens/product_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/providers/product_list_provider.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProducts = ref.watch(productListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Ürünler",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryDarkGreen,
      ),
      body: asyncProducts.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text("Ürün bulunamadı."));
          }

          return Padding(
            padding: const EdgeInsets.all(14),
            child: GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (_, i) => ProductCard(product: products[i]),
            ),
          );
        },
        loading: () =>
        const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text("Hata: $err")),
      ),
    );
  }
}
