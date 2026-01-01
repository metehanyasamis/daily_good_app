import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../review/presentation/widgets/rating_form_card.dart';
import '../../data/models/order_details_response.dart';
import '../../data/models/order_list_item.dart';
import '../../domain/providers/order_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  final dynamic order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Gelen objeden ID'yi çekiyoruz (Liste mi Detay mı kontrolü)
    final String orderId = order is OrderDetailResponse ? order.id : (order as OrderListItem).id;

    // 2. Repository üzerinden tam detayı çeken provider'ı dinliyoruz
    final detailAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F5),
      appBar: AppBar(
        title: const Text("Sipariş Detayı", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primaryDarkGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.push('/contact'),
            child: const Text("Yardım", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryDarkGreen)),
        error: (err, stack) => Center(child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text("Hata oluştu: $err", textAlign: TextAlign.center),
        )),
        data: (fullOrder) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // YEŞİL HEADER
                _buildOrderHeader(fullOrder),

                // 1. BEYAZ KART: SİPARİŞ İÇERİĞİ VE ÖDEME
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: _whiteCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                        child: Text("Sipariş İçeriği", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),

                      // Ürün Listesi (Dinamik)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: fullOrder.items.length,
                        separatorBuilder: (_, __) => const Divider(height: 24, color: Color(0xFFF5F5F5)),
                        itemBuilder: (context, index) {
                          final item = fullOrder.items[index];

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Miktar: 1x, 2x
                              Text(
                                "${item.quantity}x",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen),
                              ),
                              const SizedBox(width: 12),

                              // Ürün İsmi
                              Expanded(
                                child: Text(
                                  item.product.name,
                                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                                ),
                              ),

                              // Fiyat Bilgisi: Senin modelindeki 'totalPrice' alanını kullanıyoruz
                              Text(
                                "${item.totalPrice.toStringAsFixed(2)} ₺",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          );
                        },
                      ),

                      const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(height: 32)),

                      // Ödenen Toplam
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Ödenen Toplam", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text("${fullOrder.totalAmount.toStringAsFixed(2)} ₺",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primaryDarkGreen)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. BEYAZ KART: DEĞERLENDİRME
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  padding: const EdgeInsets.all(20),
                  decoration: _whiteCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Siparişi Değerlendir", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      RatingFormCard(
                        storeId: fullOrder.store.id,
                        orderId: fullOrder.id, // Hangi sipariş olduğunu da bildirdik
                        existingReviewId: null,
                        initialRatings: const {
                          'Servis': 0,
                          'Ürün Miktarı': 0,
                          'Ürün Lezzeti': 0,
                          'Ürün Çeşitliliği': 0
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  BoxDecoration _whiteCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
      ],
    );
  }

  Widget _buildOrderHeader(OrderDetailResponse fullOrder) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryDarkGreen,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          Text(fullOrder.store.name, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Sipariş No: #${fullOrder.orderNumber}", style: TextStyle(color: Colors.white.withOpacity(0.9))),
          Text(DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR').format(fullOrder.createdAt),
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
        ],
      ),
    );
  }
}