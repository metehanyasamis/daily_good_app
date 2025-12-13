// lib/features/product/presentation/screens/product_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/products_notifier.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productsProvider);
    final notifier = ref.read(productsProvider.notifier);

    // 🔹 ilk girişte bir kere yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifier.loadOnce();
    });

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
      body: state.isLoadingList
          ? const Center(child: CircularProgressIndicator())
          : state.products.isEmpty
          ? const Center(child: Text("Ürün bulunamadı."))
          : Padding(
        padding: const EdgeInsets.all(14),
        child: GridView.builder(
          itemCount: state.products.length,
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (_, i) =>
              ProductCard(product: state.products[i]),
        ),
      ),
    );
  }
}
