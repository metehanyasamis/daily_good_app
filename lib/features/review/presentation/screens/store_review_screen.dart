import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/platform/platform_widgets.dart';
import '../../../stores/domain/providers/store_detail_provider.dart';
import '../../../review/domain/models/review_model.dart';
import '../widgets/store_rating_bars.dart';

class StoreReviewScreen extends ConsumerWidget {
  final String storeId;

  const StoreReviewScreen({super.key, required this.storeId});

  // --- MODELİNE TAM UYUMLU MOCK VERİLER ---
  List<ReviewModel> _getMockReviews() {
    return [
      ReviewModel(
        id: "1",
        storeId: storeId,
        userName: "Ahmet Yılmaz",
        serviceRating: 5,        // double (5.0) değil int (5) yaptık
        productQuantityRating: 5,
        productTasteRating: 5,
        productVarietyRating: 4,
        comment: "Ürünler beklediğimden çok daha taze çıktı. Harika!",
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now(),
      ),
      ReviewModel(
        id: "2",
        storeId: storeId,
        userName: "Selin Kaya",
        serviceRating: 4,
        productQuantityRating: 4,
        productTasteRating: 5,
        productVarietyRating: 3,
        comment: "Porsiyonlar gayet doyurucu. Lezzet 10 numara.",
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storeDetailProvider(storeId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Değerlendirmeler",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, dynamic state) {
    final store = state.detail;
    if (store == null && state.loading) {
      return Center( // 🚀 'const' kaldırıldı
        child: PlatformWidgets.loader(), // 🎯 Adaptive yapı
      );
    }
    if (store == null) return const Center(child: Text("Veri yüklenemedi."));

    // Backend yorumları boşsa mock listesini kullan
    final List<ReviewModel> displayReviews = state.reviews.isEmpty ? _getMockReviews() : state.reviews.reversed.toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4)),
                ],
              ),
              child: StoreRatingBars(
                storeId: storeId,
                overallRating: store.overallRating,
                totalReviews: store.totalReviews,
                ratings: store.averageRatings!,
                showHeader: true,
                onTap: null,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                const Text("Kullanıcı Yorumları", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (state.reviews.isEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                    child: const Text("TEST VERİSİ", style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ]
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final review = displayReviews[index];
                return _buildReviewItem(review);
              },
              childCount: displayReviews.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildStars(review.averageRating),
                  const SizedBox(width: 10),
                  Text(
                    review.userName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              // Tarih formatlama (DateTime'ı String'e çeviriyoruz)
              Text(
                "${review.createdAt.day}.${review.createdAt.month}.${review.createdAt.year}",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment ?? "Yorum belirtilmemiş.",
            style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }
}

