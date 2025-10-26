import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../product/data/mock/mock_product_model.dart';
import '../../../product/data/models/product_model.dart';
import '../../../product/presentation/widgets/product_card.dart';

class FavoriteProductsTab extends StatelessWidget {
  const FavoriteProductsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ProductModel> favoriteProducts = mockProducts
        .where((p) => p.stockLabel.toLowerCase().contains('kaldı'))
        .toList();

    if (favoriteProducts.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: favoriteProducts.length,
      itemBuilder: (context, index) {
        final product = favoriteProducts[index];
        return ProductCard(
          product: product,
          onTap: () => context.push('/product-detail', extra: product),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🟢 Başlık
            Text(
              'Henüz Keşfedilecek Çok Lezzet Var! 🤩',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDarkGreen,
              ),
            ),
            const SizedBox(height: 40),

            // 🟢 Büyük ikon
            const Icon(
              Icons.favorite_outline,
              size: 72,
              color: AppColors.primaryDarkGreen,
            ),
            const SizedBox(height: 40),

            // 🟢 Açıklama metni
            Text(
              'Favorilediğiniz tüm DailyGood mağazaları ve\n'
                  'kurtarılmayı bekleyen sürprizleri burada görebilirsiniz.\n\n'
                  'Hemen haritayı açın ve size en yakın lezzet duraklarını kalpleyin!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),

            // 🟢 Placeholder kart (görsel hissi)
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryDarkGreen, width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Icon(Icons.image_outlined,
                        size: 50, color: AppColors.primaryDarkGreen),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Icon(Icons.favorite_border,
                        size: 35, color: AppColors.primaryDarkGreen),
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
