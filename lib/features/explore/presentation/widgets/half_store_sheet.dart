import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/navigation_link.dart';
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

                              const SizedBox(height: 6),

                              NavigationLink(
                                address: store.address,
                                latitude: store.latitude,
                                longitude: store.longitude,
                                label: store.name,
                                textStyle: const TextStyle(
                                  color: AppColors.primaryDarkGreen,
                                  decoration: TextDecoration.underline,
                                  fontSize: 13,
                                ),
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

                      return SizedBox(
                        height: 300, // 👈 sheet içi alan (isteğe göre 250–400)
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: products.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final product = products[index];

                            return _MiniProductRow(
                              product: product,
                              onTap: () {
                                if (product.id == null);
                                context.push('/product-detail/${product.id}');
                              },
                            );
                          },
                        ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          color: Colors.white,
        ),
        child: Row(
          children: [
            // 🍔 ÜRÜN İKONU / GÖRSEL
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.fastfood, size: 24),
            ),

            const SizedBox(width: 12),

            // 📄 ÜRÜN BİLGİLERİ
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // ⏰ TESLİM SAATİ
                  if (product.startHour != null && product.endHour != null)
                    Text(
                      "Bugün ${product.startHour} – ${product.endHour}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // 💰 FİYAT + OK
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Eski fiyat (üstü çizili)
                if (product.listPrice != null)
                  Text(
                    "${product.listPrice!.toStringAsFixed(2)} ₺",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),

                // Yeni fiyat
                Text(
                  "${product.salePrice?.toStringAsFixed(2)} ₺",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 6),

            // 👉 TIKLANABİLİRLİK OKU
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 22,
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
