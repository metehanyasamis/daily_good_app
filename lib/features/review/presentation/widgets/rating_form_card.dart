// lib/features/review/presentation/widgets/rating_form_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🚀 Haptic için eklendi
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/platform/toasts.dart'; // 🚀 Yeni eklendi
import '../../providers/review_provider.dart';

class RatingFormCard extends ConsumerStatefulWidget {
  final String storeId;
  final String? existingReviewId;
  final Map<String, int> initialRatings;
  final String? orderId;

  const RatingFormCard({
    super.key,
    required this.storeId,
    this.existingReviewId,
    this.orderId,
    required this.initialRatings,
  });

  @override
  ConsumerState<RatingFormCard> createState() => _RatingFormCardState();
}

class _RatingFormCardState extends ConsumerState<RatingFormCard> {
  late Map<String, int> _ratings;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ratings = Map.from(widget.initialRatings);
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

          ..._ratings.keys.map((c) => _ratingRow(c)).toList(),

          const SizedBox(height: 12),

          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Görüşlerin bizim için çok değerli 💚\n(İsteğe bağlı)',
              hintStyle: const TextStyle(color: Colors.black45, fontSize: 14),
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

  Future<void> _handleSubmit(BuildContext context, ReviewController controller) async {
    debugPrint("button pressed: _handleSubmit triggered");

    if (_ratings.values.every((r) => r == 0)) {
      // 🎯 Hatalı işlem uyarısı
      HapticFeedback.vibrate();
      Toasts.error(context, 'Lütfen en az bir kategoriye puan verin.');
      return;
    }

    final success = await controller.submitReview(
      storeId: widget.storeId,
      existingReviewId: widget.existingReviewId,
      ratings: _ratings,
      comment: _commentController.text,
      orderId: widget.orderId,
    );

    if (!context.mounted) return;

    if (success) {
      debugPrint("🎉 UI Update: Success Dialog shown");

      // 🎯 Başarı hissi için kuvvetli tık
      HapticFeedback.mediumImpact();

      _showSuccessDialog(context);

      setState(() {
        _ratings = Map.from(widget.initialRatings);
        _commentController.clear();
      });

    } else {
      debugPrint("❗ UI Update: Dynamic error message shown");

      final errorState = ref.read(reviewControllerProvider);
      final errorMessage = errorState.maybeWhen(
        error: (error, _) => error.toString().replaceAll("Exception: ", ""),
        orElse: () => 'İşlem sırasında bir hata oluştu.',
      );

      // 🎯 Hata titreşimi
      HapticFeedback.vibrate();
      Toasts.error(context, errorMessage);
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Material(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: AppColors.primaryDarkGreen, size: 64),
                  const SizedBox(height: 16),
                  const Text("Harika!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    "Geri bildirimin başarıyla iletildi. Deneyimini paylaştığın için teşekkür ederiz 💚",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDarkGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.pop(context);
                      },
                      child: const Text("Kapat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );
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
                    // 🎯 Yıldızlara her basıldığında minik bir tık sesi/hissi
                    HapticFeedback.selectionClick();
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