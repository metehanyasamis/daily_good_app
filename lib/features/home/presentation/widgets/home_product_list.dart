import 'package:flutter/material.dart';
import '../../../product/data/models/product_model.dart';
import '../../../product/presentation/widgets/product_card.dart';
import 'package:go_router/go_router.dart';

class HomeProductList extends StatelessWidget {
  final List<ProductModel> products;

  /// Ürün kartına tıklayınca çalışacak callback
  final Function(ProductModel)? onProductTap;

  const HomeProductList({
    super.key,
    required this.products,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            "Bu kategori için ürün bulunamadı.",
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];

          return Container(
            width: MediaQuery.of(context).size.width * 0.82,
            margin: EdgeInsets.only(
              right: index == products.length - 1 ? 0 : 8,
            ),
            child: ProductCard(
              product: product,

              onTap: () {
                if (onProductTap != null) {
                  onProductTap!(product);
                } else {
                  context.push('/product-detail', extra: product);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
