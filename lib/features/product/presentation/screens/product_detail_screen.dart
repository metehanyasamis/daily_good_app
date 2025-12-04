// lib/features/product/presentation/screens/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../cart/domain/providers/cart_provider.dart';
import '../../../cart/presentation/widgets/cart_warning_modal.dart';
import '../../domain/providers/product_detail_provider.dart';
import '../../data/models/product_model.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProduct = ref.watch(productDetailProvider(productId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Ürün Detayı", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryDarkGreen,
        centerTitle: true,
      ),
      body: asyncProduct.when(
        data: (product) => _DetailBody(product: product),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Hata: $e")),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  final ProductModel product;
  const _DetailBody({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCtrl = ref.read(cartProvider.notifier);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Image
                Image.network(
                  product.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                const SizedBox(height: 20),

                // Name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Prices
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${product.salePrice.toStringAsFixed(2)} ₺",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDarkGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${product.listPrice.toStringAsFixed(2)} ₺",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Store Info
                _StoreInfo(product: product),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Add to cart
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDarkGreen,
              minimumSize: const Size(double.infinity, 54),
            ),
            onPressed: () async {
              final cartCtrl = ref.read(cartProvider.notifier);
              final storeId = product.store.id;

              final same = cartCtrl.isSameStore(storeId);

              if (same) {
                final ok = await cartCtrl.addProduct(product, 1);
                if (ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${product.name} sepete eklendi.")),
                  );
                }
                return;
              }

              final proceed = await showCartConflictModal(context);

              if (proceed == true) {
                final ok = await cartCtrl.replaceWith(product, 1);
                if (ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${product.name} sepete eklendi.")),
                  );
                }
              }
            },
            child: Text(
              "Sepete Ekle • ${product.salePrice.toStringAsFixed(2)} ₺",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _StoreInfo extends StatelessWidget {
  final ProductModel product;
  const _StoreInfo({required this.product});

  @override
  Widget build(BuildContext context) {
    final s = product.store;

    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "İşletme Bilgileri",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),

          Text(s.name, style: const TextStyle(fontSize: 15)),

          if (s.distanceKm != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text("${s.distanceKm!.toStringAsFixed(2)} km uzakta"),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
