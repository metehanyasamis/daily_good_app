import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../review/presentation/widgets/rating_form_card.dart';
import '../../domain/providers/store_detail_provider.dart';

class StoreReviewSection extends ConsumerWidget {
  final String storeId;

  const StoreReviewSection({
    super.key,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔥 DOĞRU: family provider storeId ile izlenir
    final state = ref.watch(storeDetailProvider(storeId));

    // Yüklenirken alan kaplamasın
    if (state.loading) {
      return const SizedBox.shrink();
    }

    // Hata varsa review formu gösterme
    if (state.error != null) {
      return const SizedBox.shrink();
    }

    // Backend artık existing review göndermiyor
    // → her zaman yeni review
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
            "Değerlendirmen",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),

          RatingFormCard(
            storeId: storeId,
            existingReviewId: null,
            initialRatings: const {
              "Servis": 0,
              "Ürün Miktarı": 0,
              "Ürün Lezzeti": 0,
              "Ürün Çeşitliliği": 0,
            },
          ),
        ],
      ),
    );
  }
}
