import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/order_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderItem order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final Map<String, int> _ratings = {
    'Servis': 0,
    'Ürün Miktarı': 0,
    'Ürün Lezzeti': 0,
    'Ürün Çeşitliliği': 0,
  };

  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
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
            onPressed: () {},
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
            Container(
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
            ),

            const SizedBox(height: 12),

            // 🏪 İşletme Bilgileri
            Container(
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
            ),

            const SizedBox(height: 14),

            // ⭐ Değerlendirme Kartı
            _buildRatingSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Değerlendirme',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              SizedBox(width: 6),
              Icon(Icons.chat_bubble_outline, size: 18, color: Colors.black54),
            ],
          ),
          const SizedBox(height: 10),
          ..._ratings.keys.map((c) => _ratingRow(c)).toList(),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Görüşlerin bizim için çok değerli 💚\n(isteğe bağlı)',
              hintStyle: const TextStyle(color: Colors.black45),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Geri Bildirim Gönder',
            onPressed: () {
              debugPrint('⭐ Ratings: $_ratings');
              debugPrint('💬 Comment: ${_commentController.text}');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Geri bildirimin için teşekkür ederiz 💚'),
                ),
              );
            },
            showPrice: false, // sade, tek parça yeşil buton
          ),
        ],
      ),
    );
  }

  Widget _ratingRow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 14))),
          Row(
            children: List.generate(5, (index) {
              final isFilled = index < _ratings[label]!;
              return IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  isFilled ? Icons.star : Icons.star_border,
                  color: AppColors.primaryDarkGreen,
                  size: 24,
                ),
                onPressed: () {
                  setState(() {
                    _ratings[label] = index + 1;
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
