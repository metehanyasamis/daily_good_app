import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    if (store == null && state.loading) return const Center(child: CircularProgressIndicator());
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

/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../stores/domain/providers/store_detail_provider.dart';
import '../widgets/store_rating_bars.dart';

class StoreReviewScreen extends ConsumerWidget {
  final String storeId;

  const StoreReviewScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storeDetailProvider(storeId));

    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar'ı daha modern ve sade yaptık
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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 19),
        ),
        centerTitle: true,
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, dynamic state) {
    final store = state.detail;
    if (store == null) return const Center(child: CircularProgressIndicator());

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 1. KART: İŞLETME DEĞERLENDİRME
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20), // Oval Köşeler
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "İşletme Değerlendirmesi", // Başlık Büyüklüğü Eşitlendi
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  StoreRatingBars(
                    storeId: storeId,
                    overallRating: store.overallRating,
                    totalReviews: store.totalReviews,
                    ratings: store.averageRatings!,
                    showHeader: false, // Başlığı kendimiz yukarıda yazdık
                    onTap: null,
                  ),
                ],
              ),
            ),
          ),
        ),

        // 2. KART: YORUMLAR BÖLÜMÜ
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20), // Oval Köşeler
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Yorumlar", // Başlık Büyüklüğü Eşitlendi
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 20),

                  state.reviews.isEmpty
                      ? const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text("Henüz yorum yapılmamış."),
                  ))
                      : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.reviews.length,
                    separatorBuilder: (context, index) => const Divider(height: 32, color: Color(0xFFF5F5F5)),
                    itemBuilder: (context, index) {
                      final review = state.reviews.reversed.toList()[index];

                      // 🎯 YORUM LİSTELEME YAPISI
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Yıldızlar ve İsim
                              Row(
                                children: [
                                  _buildSmallStars(review.rating), // Küçük Yıldız Widgetı
                                  const SizedBox(width: 8),
                                  Text(
                                    "${review.userFirstName} ${review.userLastName}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ],
                              ),
                              // Tarih
                              Text(
                                review.createdAt ?? "",
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Yorum Metni
                          Text(
                            review.comment ?? "",
                            style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Yıldız yapısı için yardımcı widget
  Widget _buildSmallStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({required this.minHeight, required this.maxHeight, required this.child});
  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override double get minExtent => minHeight;
  @override double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          if (shrinkOffset > 0)
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: child,
    );
  }

  @override bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => true;
}

 */


/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../stores/domain/providers/store_detail_provider.dart';
import '../../../stores/presentation/widgets/store_review_item.dart';
import '../widgets/store_rating_bars.dart';

class StoreReviewScreen extends ConsumerWidget {
  final String storeId;

  const StoreReviewScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storeDetailProvider(storeId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white, // Android'deki o morumsu gölgeyi siler
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Değerlendirmeler",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: _buildBody(context, state),
    );
  }


  Widget _buildBody(BuildContext context, dynamic state) {
    // Yüklenme ve hata kontrolleri burada (öncekiyle aynı)
    final store = state.detail;
    if (store == null) return const SizedBox.shrink();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 1. BÖLÜM: ÜST ÖZET KARTI
        SliverToBoxAdapter(
          child: Padding(
            // Padding'i Container dışına aldık ki hizalama daha kolay olsun
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
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

        // 2. BÖLÜM: YAPIŞKAN BAŞLIK (Hizalama Buradan Başlıyor)
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverAppBarDelegate(
            minHeight: 60.0,
            maxHeight: 60.0,
            child: Container(
              // Arka plan rengini beyaz yapıyoruz ki scroll yaparken altındaki yorumlar görünmesin
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFF1F1F1), width: 1)),
              ),
              // 🎯 SOL HİZALAMA: Kartın içindeki padding (16+20=36) ile eşitledik
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const Text(
                    "Kullanıcı Yorumları",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
        ),

        // 3. BÖLÜM: YORUMLAR (Aşağıda scroll olan kısım)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          sliver: state.reviews.isEmpty
              ? _buildEmptyState()
              : SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final review = state.reviews.reversed.toList()[index];
                return StoreReviewItem(review: review);
              },
              childCount: state.reviews.length,
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("Henüz yorum yapılmamış.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// 📌 Başlığın yukarı yapışmasını sağlayan özel yardımcı sınıf
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({required this.minHeight, required this.maxHeight, required this.child});
  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override double get minExtent => minHeight;
  @override double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight || child != oldDelegate.child;
  }
}
*/


/*
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../stores/domain/providers/store_detail_provider.dart';
import '../../../stores/presentation/widgets/store_review_item.dart';
import '../widgets/store_rating_bars.dart';

class StoreReviewScreen extends ConsumerWidget {
  final String storeId;

  const StoreReviewScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storeDetailProvider(storeId));

    return Scaffold(
      backgroundColor: Colors.white, // Daha ferah bir beyaz
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Mağaza Değerlendirmeleri",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, dynamic state) {
    if (state.loading && state.detail == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryDarkGreen));
    }

    final store = state.detail;
    if (store == null) return const Center(child: Text("Veri bulunamadı"));

    return CustomScrollView( // Akıcı bir kaydırma deneyimi için
      slivers: [
        // 📊 Üst Bölüm: Özet Puanlar
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
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

        // 💬 Orta Başlık
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Kullanıcı Yorumları (${state.reviews.length})",
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.sort, size: 20, color: Colors.grey),
              ],
            ),
          ),
        ),

        // 📝 Alt Bölüm: Yorum Listesi
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: state.reviews.isEmpty
              ? const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(top: 50),
                child: Text("Henüz yorum yapılmamış.", style: TextStyle(color: Colors.grey)),
              ),
            ),
          )
              : SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                // Yorumları ters çeviriyoruz ki "en yeni en üstte" olsun
                final review = state.reviews.reversed.toList()[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: StoreReviewItem(review: review),
                );
              },
              childCount: state.reviews.length,
            ),
          ),
        ),
      ],
    );
  }
}

 */