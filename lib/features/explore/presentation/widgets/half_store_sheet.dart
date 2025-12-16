import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../product/data/models/product_list_response.dart';
import '../../../product/data/models/product_model.dart';
import '../../../stores/data/model/store_summary.dart';


class HalfStoreSheet extends StatelessWidget {
  final StoreSummary store;
  final Future<ProductListResponse> productsFuture;
  final VoidCallback onStoreTap;

  const HalfStoreSheet({
    super.key,
    required this.store,
    required this.productsFuture,
    required this.onStoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      maxChildSize: 0.95,
      minChildSize: 0.3,
      expand: false,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------------- STORE HEADER ----------------
                  GestureDetector(
                    onTap: onStoreTap,
                    child: Row(
                      children: [
                        _StoreAvatar(imageUrl: store.imageUrl),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      store.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (store.overallRating != null) ...[
                                    const SizedBox(width: 6),
                                    const Icon(Icons.star,
                                        size: 18, color: Colors.amber),
                                    Text(
                                      store.overallRating!
                                          .toStringAsFixed(1),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                store.address,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Text(
                                "Bugün teslim al",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---------------- PRODUCTS ----------------
                  const Text(
                    "Seni bekleyen lezzetler",
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  FutureBuilder<ProductListResponse>(
                    future: productsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                              child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError) {
                        return const Text("Ürünler yüklenemedi");
                      }

                      final products =
                          snapshot.data?.products ?? <ProductModel>[];

                      if (products.isEmpty) {
                        return const Text("Bugün ürün bulunmuyor");
                      }

                      return Column(
                        children: products.map((product) {
                          return _MiniProductRow(
                            product: product,
                            onTap: () {
                              if (product.id == null) return;
                              context.push(
                                '/product-detail/${product.id}',
                              );
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ===================================================================
// MINI PRODUCT ROW
// ===================================================================

class _MiniProductRow extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const _MiniProductRow({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 48,
                  height: 48,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.fastfood),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                product.name,
                style:
                const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              "${product.salePrice.toStringAsFixed(0)} ₺",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// STORE AVATAR
// ===================================================================

class _StoreAvatar extends StatelessWidget {
  final String imageUrl;

  const _StoreAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 54,
        height: 54,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey.shade200,
            child:
            const Icon(Icons.store, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
