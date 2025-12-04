// lib/features/review/presentation/widgets/rating_form_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../providers/review_provider.dart';

class RatingFormCard extends ConsumerStatefulWidget {
  final String storeId;
  final String? existingReviewId;
  final Map<String, int> initialRatings;

  const RatingFormCard({
    super.key,
    required this.storeId,
    this.existingReviewId,
    required this.initialRatings, // Varsayılan veya mevcut oyları almak için
  });

  @override
  ConsumerState<RatingFormCard> createState() => _RatingFormCardState();
}

class _RatingFormCardState extends ConsumerState<RatingFormCard> {
  // 💡 State'i initialRatings ile başlatıyoruz
  late Map<String, int> _ratings;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Gelen initialRatings'i kopyalıyoruz ki, state değişimi dışarıyı etkilemesin
    _ratings = Map.from(widget.initialRatings);
    // Yorumun da mevcut veriden gelmesi gerekebilir, şimdilik boş bırakıyoruz.
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(reviewControllerProvider.notifier);
    final isSending = ref.watch(reviewControllerProvider).isLoading;
    final buttonText = widget.existingReviewId != null ? 'Değerlendirmeyi Güncelle' : 'Geri Bildirim Gönder';

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

          // ⭐ Rating satırları
          ..._ratings.keys.map((c) => _ratingRow(c)).toList(),

          const SizedBox(height: 12),

          // 💬 Yorum alanı
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
            text: isSending ? 'Gönderiliyor...' : buttonText,
            onPressed: isSending ? null : () {
              _handleSubmit(context, controller);
            },
            showPrice: false,
          ),
        ],
      ),
    );
  }

  // ⭐ YENİ METOT: Asenkron işi senkron onPressed içinden çağırır.
  Future<void> _handleSubmit(BuildContext context, ReviewController controller) async {
    // En az bir rating seçildi mi kontrol et
    if (_ratings.values.every((r) => r == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir kategoriye puan verin.')),
      );
      return;
    }

    final success = await controller.submitReview(
      storeId: widget.storeId,
      existingReviewId: widget.existingReviewId,
      ratings: _ratings,
      comment: _commentController.text,
    );

    if (success) {
      // Başarılı bildirim
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingReviewId != null
              ? 'Değerlendirmen güncellendi 💚'
              : 'Geri bildirimin için teşekkür ederiz 💚'),
        ),
      );
      // Opsiyonel: Başarılı olduktan sonra yorum alanını temizleyebilirsiniz.
      // _commentController.clear();
      // Opsiyonel: Başarılı olduktan sonra puanları sıfırlayabilirsiniz.
      // setState(() { _ratings = Map.from(widget.initialRatings); });

    } else {
      // Hata bildirimi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İşlem sırasında bir hata oluştu.')),
      );
    }
  }

  Widget _ratingRow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),

          Expanded(
            child: Wrap(
              spacing: 15,
              children: List.generate(5, (index) {
                final isFilled = index < _ratings[label]!;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _ratings[label] = index + 1;
                    });
                  },
                  child: Icon(
                    isFilled ? Icons.star : Icons.star_border,
                    size: 22,
                    color: AppColors.primaryDarkGreen,
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}