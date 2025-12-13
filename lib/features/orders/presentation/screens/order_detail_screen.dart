import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../review/presentation/widgets/rating_form_card.dart';
import '../../data/models/order_details_response.dart';

class OrderDetailScreen extends ConsumerWidget {
  final OrderDetailResponse order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormatter = DateFormat('dd MMMM yyyy', 'tr_TR');
    final product = order.items.isNotEmpty ? order.items.first.product : null;
    final store = order.store;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDarkGreen,
        centerTitle: true,
        title: const Text(
          'Sipariş Detay',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: () => context.push('/contact'),
            child: const Text('Yardım', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),

      backgroundColor: Colors.grey.shade100,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProductCard(product, order, dateFormatter),
            const SizedBox(height: 12),
            _buildStoreCard(store),
            const SizedBox(height: 16),

            // ⭐ Değerlendirme Kartı
            RatingFormCard(
              storeId: store.id,
              existingReviewId: null,
              initialRatings: const {
                'Servis': 0,
                'Ürün Miktarı': 0,
                'Ürün Lezzeti': 0,
                'Ürün Çeşitliliği': 0,
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 🟢 ÜRÜN KARTI
  // ---------------------------------------------------------------------------

  Widget _buildProductCard(product, OrderDetailResponse order, DateFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _boxDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ürün görseli
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product?.imageUrl ?? "",
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 60),
            ),
          ),

          const SizedBox(width: 12),

          // Ürün bilgiler
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product?.name ?? "Ürün",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  formatter.format(order.createdAt),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Sipariş numarası: ${order.orderNumber}",
                  style: const TextStyle(
                    color: AppColors.primaryDarkGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Ücret: ${order.totalAmount.toStringAsFixed(2)} ₺",
                  style: const TextStyle(
                    color: AppColors.primaryDarkGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 🏪 İŞLETME KARTI
  // ---------------------------------------------------------------------------

  Widget _buildStoreCard(store) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _boxDecoration(),
      child: Row(
        children: [
          const Icon(Icons.store_mall_directory_outlined,
              color: AppColors.primaryDarkGreen, size: 32),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  store.address ?? "",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 🎨 TEK TİP BOX DECORATION
  // ---------------------------------------------------------------------------

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
