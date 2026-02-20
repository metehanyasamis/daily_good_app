/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/platform/platform_widgets.dart';
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
    final String orderId = order is OrderDetailResponse ? order.id : (order as OrderListItem).id;
    final detailAsync = ref.watch(orderDetailProvider(orderId));



    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F5),
      appBar: AppBar(
        // 🚀 TÜM STİLİ MERKEZİ TEMADAN AL:
        backgroundColor: AppTheme.greenAppBarTheme.backgroundColor,
        foregroundColor: AppTheme.greenAppBarTheme.foregroundColor,
        systemOverlayStyle: AppTheme.greenAppBarTheme.systemOverlayStyle,
        iconTheme: AppTheme.greenAppBarTheme.iconTheme,
        titleTextStyle: AppTheme.greenAppBarTheme.titleTextStyle,
        centerTitle: AppTheme.greenAppBarTheme.centerTitle,
        elevation: 0,

        title: const Text("Sipariş Detayı"),
        actions: [
          TextButton(
            onPressed: () {
              // 🎯 Yardıma basıldığında hafif bir dokunuş hissi verelim
              HapticFeedback.lightImpact();
              context.push('/contact');
            },
            child: const Text(
                "Yardım",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                )
            ),
          ),
        ],
      ),

      body: detailAsync.when(
        loading: () => Center(
          child: PlatformWidgets.loader(color: AppColors.primaryDarkGreen),
        ),
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
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 6),
                        child: Text("Sipariş İçeriği", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),

                      // Ürün Listesi (Dinamik)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: fullOrder.items.length,
                        separatorBuilder: (_, _) => const Divider(height: 24, color: Color(0xFFF5F5F5)),
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
                      const SizedBox(height: 8),
                      RatingFormCard(
                        storeId: fullOrder.store.id,
                        orderId: fullOrder.id,
                        productId: fullOrder.items.isNotEmpty ? fullOrder.items.first.product.id : null,

                        // 🎯 Mevcut yorum bilgilerini modelden çekip gönderiyoruz
                        existingReviewId: fullOrder.review?.id,
                        initialComment: fullOrder.review?.comment,

                        initialRatings: {
                          'Servis': fullOrder.review?.serviceRating ?? 0,
                          'Ürün Miktarı': fullOrder.review?.productQuantityRating ?? 0,
                          'Ürün Lezzeti': fullOrder.review?.productTasteRating ?? 0,
                          'Ürün Çeşitliliği': fullOrder.review?.productVarietyRating ?? 0,
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
        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
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
          Text("Sipariş No: #${fullOrder.orderNumber}", style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
          Text(DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR').format(fullOrder.createdAt),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
        ],
      ),
    );
  }
}

 */

/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/platform/platform_widgets.dart';
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
    final String orderId = order is OrderDetailResponse ? order.id : (order as OrderListItem).id;
    final detailAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F5),
      appBar: AppBar(
        backgroundColor: AppTheme.greenAppBarTheme.backgroundColor,
        foregroundColor: AppTheme.greenAppBarTheme.foregroundColor,
        systemOverlayStyle: AppTheme.greenAppBarTheme.systemOverlayStyle,
        iconTheme: AppTheme.greenAppBarTheme.iconTheme,
        titleTextStyle: AppTheme.greenAppBarTheme.titleTextStyle,
        centerTitle: AppTheme.greenAppBarTheme.centerTitle,
        elevation: 0,
        title: const Text("Sipariş Detayı"),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/contact');
            },
            child: const Text("Yardım", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => Center(
          child: PlatformWidgets.loader(color: AppColors.primaryDarkGreen),
        ),
        error: (err, stack) => Center(child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text("Hata oluştu: $err", textAlign: TextAlign.center),
        )),
        data: (fullOrder) {

          // 🔥🔥🔥 DEBUG LOGLARI BURADA 🔥🔥🔥
          debugPrint("----------------------------------------------------------------");
          debugPrint("🛑 [DEBUG] SİPARİŞ DETAY EKRANI YÜKLENDİ");
          debugPrint("🛑 [DEBUG] Sipariş ID: ${fullOrder.id}");

          if (fullOrder.review == null) {
            debugPrint("🛑 [DEBUG] DURUM: Review Objesi TAMAMEN NULL Geliyor! ❌");
            debugPrint("   -> Backend bu sipariş için 'review' alanını boş gönderiyor.");
            debugPrint("   -> Ekranda değerlendirme formu AÇIK (aktif) görünecek.");
          } else {
            debugPrint("🛑 [DEBUG] DURUM: Review Objesi DOLU Geldi! ✅");
            debugPrint("   -> Yorum ID: ${fullOrder.review?.id}");
            debugPrint("   -> Yorum Metni: '${fullOrder.review?.comment}'");
            debugPrint("   -> Servis Puanı: ${fullOrder.review?.serviceRating}");
            debugPrint("   -> Ekranda değerlendirme formu KİLİTLİ (gri) görünecek.");
          }
          debugPrint("----------------------------------------------------------------");
          // 🔥🔥🔥 DEBUG SONU 🔥🔥🔥


          // 1. ADIM: Yorum yapılmış mı kontrolü
          final bool isReviewed = fullOrder.review != null;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildOrderHeader(fullOrder),

                // 1. KART: SİPARİŞ İÇERİĞİ
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: _whiteCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 6),
                        child: Text("Sipariş İçeriği", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: fullOrder.items.length,
                        separatorBuilder: (_, _) => const Divider(height: 24, color: Color(0xFFF5F5F5)),
                        itemBuilder: (context, index) {
                          final item = fullOrder.items[index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${item.quantity}x", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen)),
                              const SizedBox(width: 12),
                              Expanded(child: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
                              Text("${item.totalPrice.toStringAsFixed(2)} ₺", style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          );
                        },
                      ),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(height: 32)),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Ödenen Toplam", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text("${fullOrder.totalAmount.toStringAsFixed(2)} ₺", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primaryDarkGreen)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. KART: DEĞERLENDİRME
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  padding: const EdgeInsets.all(20),
                  decoration: _whiteCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Siparişi Değerlendir", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          if (isReviewed)
                            const Icon(Icons.check_circle, color: AppColors.primaryDarkGreen),
                        ],
                      ),

                      if (isReviewed)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Değerlendirmeniz kaydedildi.",
                            style: TextStyle(color: Colors.green.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),

                      const SizedBox(height: 12),

                      // KİLİTLEME VE GRİLEŞTİRME
                      IgnorePointer(
                        ignoring: isReviewed,
                        child: Opacity(
                          opacity: isReviewed ? 0.6 : 1.0,
                          child: RatingFormCard(
                            storeId: fullOrder.store.id,
                            orderId: fullOrder.id,
                            productId: fullOrder.items.isNotEmpty ? fullOrder.items.first.product.id : null,

                            // Mevcut verileri içeriye gönderiyoruz
                            existingReviewId: fullOrder.review?.id,
                            initialComment: fullOrder.review?.comment,
                            initialRatings: {
                              'Servis': fullOrder.review?.serviceRating ?? 0,
                              'Ürün Miktarı': fullOrder.review?.productQuantityRating ?? 0,
                              'Ürün Lezzeti': fullOrder.review?.productTasteRating ?? 0,
                              'Ürün Çeşitliliği': fullOrder.review?.productVarietyRating ?? 0,
                            },
                          ),
                        ),
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
        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
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
          Text("Sipariş No: #${fullOrder.orderNumber}", style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
          Text(DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR').format(fullOrder.createdAt),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
        ],
      ),
    );
  }
}

*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/platform/platform_widgets.dart';
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
    final String orderId = order is OrderDetailResponse ? order.id : (order as OrderListItem).id;
    final detailAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.background, // F1F3F5 yerine ortak rengimiz
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Sipariş Detayı",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/contact');
            },
            child: const Text("Yardım",
                style: TextStyle(color: AppColors.primaryDarkGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => Center(
          child: PlatformWidgets.loader(color: AppColors.primaryDarkGreen),
        ),
        // 🎯 HATA DURUMUNDA KULLANICIYI KORKUTMUYORUZ
        error: (err, stack) => _buildErrorState(context),
        data: (fullOrder) {
          // Eğer data gelmiş ama içi boşsa yine hata gösterelim
          final bool isReviewed = fullOrder.review != null;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildOrderHeader(fullOrder),

                // 1. KART: SİPARİŞ İÇERİĞİ
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: _whiteCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 6),
                        child: Text("Sipariş İçeriği", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: fullOrder.items.length,
                        separatorBuilder: (_, _) => const Divider(height: 24, color: Color(0xFFF5F5F5)),
                        itemBuilder: (context, index) {
                          final item = fullOrder.items[index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${item.quantity}x", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryLightGreen)),
                              const SizedBox(width: 12),
                              Expanded(child: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
                              Text("${item.totalPrice.toStringAsFixed(2)} ₺", style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          );
                        },
                      ),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(height: 32)),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Ödenen Toplam", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text("${fullOrder.totalAmount.toStringAsFixed(2)} ₺",
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.primaryLightGreen)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. KART: DEĞERLENDİRME
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  padding: const EdgeInsets.all(20),
                  decoration: _whiteCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Siparişi Değerlendir", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          if (isReviewed)
                            const Icon(Icons.check_circle, color: AppColors.primaryLightGreen),
                        ],
                      ),
                      if (isReviewed)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Değerlendirmeniz kaydedildi.",
                            style: TextStyle(color: Colors.green.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      const SizedBox(height: 12),
                      IgnorePointer(
                        ignoring: isReviewed,
                        child: Opacity(
                          opacity: isReviewed ? 0.6 : 1.0,
                          child: RatingFormCard(
                            storeId: fullOrder.store.id,
                            orderId: fullOrder.id,
                            productId: fullOrder.items.isNotEmpty ? fullOrder.items.first.product.id : null,
                            existingReviewId: fullOrder.review?.id,
                            initialComment: fullOrder.review?.comment,
                            initialRatings: {
                              'Servis': fullOrder.review?.serviceRating ?? 0,
                              'Ürün Miktarı': fullOrder.review?.productQuantityRating ?? 0,
                              'Ürün Lezzeti': fullOrder.review?.productTasteRating ?? 0,
                              'Ürün Çeşitliliği': fullOrder.review?.productVarietyRating ?? 0,
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 🎯 MODERN HATA GÖRÜNÜMÜ
  // ---------------------------------------------------------------------------
  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              "Sipariş bulunamadı",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              "Sipariş detaylarına şu an ulaşılamıyor. Lütfen daha sonra tekrar deneyin.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLightGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Geri Dön", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _whiteCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20), // Köşeleri biraz daha yumuşattım
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 5)),
      ],
    );
  }

  Widget _buildOrderHeader(OrderDetailResponse fullOrder) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryLightGreen, // Koyu yeşilden senin sevdiğin açık yeşile geçtik
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      child: Column(
        children: [
          const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          Text(fullOrder.store.name, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text("Sipariş No: #${fullOrder.orderNumber}",
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Text(DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR').format(fullOrder.createdAt),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
        ],
      ),
    );
  }
}