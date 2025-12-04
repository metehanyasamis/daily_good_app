import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../review/presentation/widgets/rating_form_card.dart';
import '../../domain/providers/store_detail_provider.dart';
import '../../../review/providers/review_provider.dart';

class StoreReviewSection extends ConsumerWidget {
  final String storeId;
  const StoreReviewSection({super.key, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storeDetailProvider(storeId));

    if (state.loading) return const SizedBox();

    // KULLANICININ KENDİ YORUMU VAR MI?
    final myReview = state.reviews.where((r) => r.isMine == true).toList();
    final existing = myReview.isNotEmpty ? myReview.first : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Senin Değerlendirmen",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 14),

          // ---------------------------------------
          // 1) HİÇ YORUM YAPMAMIŞSA FORM GÖSTER
          // ---------------------------------------
          if (existing == null)
            RatingFormCard(
              storeId: storeId,
              existingReviewId: null,
              initialRatings: {
                "Servis": 0,
                "Ürün Miktarı": 0,
                "Ürün Lezzeti": 0,
                "Ürün Çeşitliliği": 0,
              },
            ),

          // ---------------------------------------
          // 2) YORUM VARSA → GÜNCELLE + SİL
          // ---------------------------------------
          if (existing != null)
            Column(
              children: [
                RatingFormCard(
                  storeId: storeId,
                  existingReviewId: existing.id,
                  initialRatings: existing.toRatingMap(),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    final ok = await ref
                        .read(reviewControllerProvider.notifier)
                        .deleteReview(
                      storeId: storeId,
                      reviewId: existing.id,
                    );

                    if (ok) {
                      ref.read(storeDetailProvider(storeId).notifier)
                          .refreshReviews(storeId);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Değerlendirme silindi.")),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text("Değerlendirmeyi Sil",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                  ),
                )
              ],
            ),
        ],
      ),
    );
  }
}
