import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/order_model.dart'; // Bu dosyanın orders modülünüzde var olduğunu varsayıyorum
import '../../../review/presentation/widgets/rating_form_card.dart'; // YENİ WIDGET

class OrderDetailScreen extends ConsumerStatefulWidget {
  final OrderItem order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  // 💡 Bu map artık initial data olarak kullanılacak.
  // Güncel state'i RatingFormCard yönetiyor.
  final Map<String, int> _initialRatings = const {
    'Servis': 0,
    'Ürün Miktarı': 0,
    'Ürün Lezzeti': 0,
    'Ürün Çeşitliliği': 0,
  };

  // 💡 NOT: Eğer kullanıcı daha önce değerlendirme yaptıysa,
  // bu order'ın API'den çekilmiş detayında (örneğin widget.order.reviewId)
  // bir reviewId ve daha önce verdiği oyların olması gerekir.
  // Şu an için varsayılan değerleri kullanıyoruz.
  final String? _existingReviewId = null; // API'den çekilecek gerçek ID buraya gelmeli

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    // Locale'ı Türkiye olarak ayarladık
    final dateFormatter = DateFormat('dd MMMM yyyy', 'tr_TR');

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
            onPressed: () {
              context.push('/support');
            },
            child: const Text('Yardım', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🟢 Ürün kartı
            _buildProductCard(order, dateFormatter),

            const SizedBox(height: 12),

            // 🏪 İşletme Bilgileri
            _buildBusinessCard(order),

            const SizedBox(height: 14),

            // ⭐ Değerlendirme Kartı (YENİ WIDGET İLE DEĞİŞTİRİLDİ)
            RatingFormCard(
              storeId: order.businessId, // OrderItem modelinde store ID'nin olması GEREKLİ
              existingReviewId: _existingReviewId,
              initialRatings: _initialRatings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(OrderItem order, DateFormat dateFormatter) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              order.businessLogo,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${order.oldPrice.toStringAsFixed(0)}₺',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${order.newPrice.toStringAsFixed(0)}₺',
                      style: const TextStyle(
                        color: AppColors.primaryDarkGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormatter.format(order.orderTime),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sipariş numarası: ${order.id}',
                  style: const TextStyle(
                    color: AppColors.primaryDarkGreen,
                    fontWeight: FontWeight.w600,
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

  Widget _buildBusinessCard(OrderItem order) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
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
                  order.businessName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.businessAddress,
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
}