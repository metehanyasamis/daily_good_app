import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/platform/platform_widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/navigation_link.dart';
import '../../../product/data/models/product_model.dart';
import '../../../stores/data/model/store_summary.dart';

class HalfStoreSheet extends StatelessWidget {
  final StoreSummary store;
  // 🔥 DEĞİŞİKLİK: ProductListResponse yerine direkt Liste bekliyoruz
  final Future<List<ProductModel>> productsFuture;
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
                                    const Icon(Icons.star, size: 18, color: Colors.amber),
                                    Text(
                                      store.overallRating!.toStringAsFixed(1),
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                store.address,
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  FutureBuilder<List<ProductModel>>(
                    future: productsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: 150,
                          child: Center(
                            child: PlatformWidgets.loader(),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        debugPrint("❌ SHEET HATASI: ${snapshot.error}");
                        return const Center(child: Text("Ürünler yüklenemedi."));
                      }

                      final products = snapshot.data ?? [];

                      if (products.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Text("Bu dükkan için şu an ürün bulunamadı."),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: products.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return _MiniProductRow(
                                product: product,
                                onTap: () => context.push('/product-detail/${product.id}'),
                              );
                            },
                          ),
                          // 🔥 ÇÖZÜM BURADA:
                          // Alt barın yüksekliği genelde 80-100 px civarıdır.
                          // Buraya ekleyeceğin boşluk listenin en altını yukarı iter.
                          const SizedBox(height: 100),
                        ],
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

class _MiniProductRow extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  const _MiniProductRow({required this.product, required this.onTap});

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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.fastfood, size: 24, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Bugün ${product.startHour} – ${product.endHour}",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (product.listPrice > 0)
                  Text(
                    "${product.listPrice.toStringAsFixed(2)} ₺",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Text(
                  "${product.salePrice.toStringAsFixed(2)} ₺",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
          ],
        ),
      ),
    );
  }
}

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
          errorBuilder: (_, _, _) => Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.store, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}