import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cart/application/cart_controller.dart';
import '../../../cart/domain/models/cart_item.dart';
import '../../../cart/presentation/widgets/cart_warning_modal.dart';
import '../../../product/presentation/widgets/product_card.dart'; // ProductModel için

class ProductDetailScreen extends ConsumerWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(product.brandName),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              product.bannerImage,
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.packageName,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.brandName,
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[600], size: 20),
                      const SizedBox(width: 4),
                      Text(product.rating.toStringAsFixed(1)),
                      const Spacer(),
                      const Icon(Icons.location_on_outlined, size: 20),
                      Text('${product.distanceKm.toStringAsFixed(1)} km'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        '${product.oldPrice.toStringAsFixed(2)} ₺',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${product.newPrice.toStringAsFixed(2)} ₺',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDarkGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.pickupTimeText,
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Açıklama',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bu paket, gün sonunda kalan taze yiyeceklerden oluşur. Her gün içerik değişebilir.',
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Sepete Ekle',
                    onPressed: () async {
                      final cart = ref.read(cartProvider.notifier);
                      final currentShopId =
                      ref.read(cartProvider.notifier).currentShopId();

                      final newItem = CartItem(
                        id: product.brandName,
                        name: product.packageName,
                        shopId: product.brandName,
                        shopName: product.brandName,
                        image: product.bannerImage,
                        price: product.newPrice,
                      );

                      if (currentShopId == null ||
                          currentShopId == newItem.shopId) {
                        cart.addItem(newItem);
                      } else {
                        final shouldReplace =
                        await showCartConflictModal(context);
                        if (shouldReplace == true) {
                          cart.replaceWithNewItem(newItem);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
