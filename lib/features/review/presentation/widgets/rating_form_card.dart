// lib/features/review/presentation/widgets/rating_form_card.dart

/*
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
  final String? initialComment;
  final String? orderId;
  final String? productId;

  const RatingFormCard({
    super.key,
    required this.storeId,
    this.existingReviewId,
    this.initialComment,
    this.orderId,
    this.productId,
    required this.initialRatings,
  });

  @override
  ConsumerState<RatingFormCard> createState() => _RatingFormCardState();
}

class _RatingFormCardState extends ConsumerState<RatingFormCard> {
  late Map<String, int> _ratings;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmittedSuccess = false;


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
    final bool isReadOnly = widget.existingReviewId != null || _isSubmittedSuccess;

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
      productId: widget.productId,
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

 */

// lib/features/review/presentation/widgets/rating_form_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // 🚀 Ana sayfaya yönlendirme için
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/platform/toasts.dart';
import '../../providers/review_provider.dart';

class RatingFormCard extends ConsumerStatefulWidget {
  final String storeId;
  final String? existingReviewId;
  final Map<String, int> initialRatings;
  final String? initialComment;
  final String? orderId;
  final String? productId;

  const RatingFormCard({
    super.key,
    required this.storeId,
    this.existingReviewId,
    this.initialComment,
    this.orderId,
    this.productId,
    required this.initialRatings,
  });

  @override
  ConsumerState<RatingFormCard> createState() => _RatingFormCardState();
}

class _RatingFormCardState extends ConsumerState<RatingFormCard> {
  late Map<String, int> _ratings;
  late TextEditingController _commentController; // late olarak değiştirdik çünkü initState'te dolacak
  bool _isSubmittedSuccess = false; // 🎯 Başarılı gönderim sonrası ekranı kilitlemek için

  @override
  void initState() {
    super.initState();
    _ratings = Map.from(widget.initialRatings);
    // Eğer dışarıdan initialComment geliyorsa (daha önce yorum yapılmışsa) onu controller'a veriyoruz
    _commentController = TextEditingController(text: widget.initialComment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔒 KİLİTLEME ŞARTI: existingReviewId doluysa VEYA yeni gönderim başarılıysa
    final bool isReadOnly = widget.existingReviewId != null || _isSubmittedSuccess;

    final controller = ref.read(reviewControllerProvider.notifier);
    final isSending = ref.watch(reviewControllerProvider).isLoading;
    final buttonText = widget.existingReviewId != null ? 'Değerlendirmeyi Güncelle' : 'Geri Bildirim Gönder';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isReadOnly ? Colors.grey.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isReadOnly ? Border.all(color: Colors.black12) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isReadOnly ? 'Değerlendirmeniz' : 'Değerlendirme',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(width: 6),
              Icon(
                  isReadOnly ? Icons.verified : Icons.chat_bubble_outline,
                  size: 18,
                  color: isReadOnly ? AppColors.primaryDarkGreen.withValues(alpha: 0.5) : Colors.black54
              ),
            ],
          ),
          const SizedBox(height: 2),

          // ⭐️ Yıldız satırları (RatingRow metoduna isReadOnly gönderiyoruz)
          ..._ratings.keys.map((c) => _ratingRow(c, isReadOnly)),

          const SizedBox(height: 2),

          TextField(
            controller: _commentController,
            maxLines: 3,
            enabled: !isReadOnly,
            style: TextStyle(color: isReadOnly ? Colors.black54 : Colors.black),
            decoration: InputDecoration(
              hintText: isReadOnly ? '' : 'Görüşlerin bizim için çok değerli 💚\n(İsteğe bağlı)',
              hintStyle: const TextStyle(color: Colors.black45, fontSize: 14),
              filled: isReadOnly,
              fillColor: Colors.black.withValues(alpha: 0.02),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: isReadOnly ? Colors.transparent : Colors.grey),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🔘 BUTON VEYA TEŞEKKÜR YAZISI
          if (!isReadOnly)
            CustomButton(
              text: isSending ? 'Gönderiliyor...' : buttonText,
              onPressed: isSending ? null : () {
                _handleSubmit(context, controller);
              },
              showPrice: false,
            )
          else
            _buildReadOnlyFooter(), // Sadece bir tane tanımlı olduğundan emin ol!
        ],
      ),
    );
  }

  // ✅ TEK BİR TANE _buildReadOnlyFooter METODU BIRAKIN:
  Widget _buildReadOnlyFooter() {
    return Column(
      children: [
        const Center(
          child: Text(
            "Geri bildiriminiz için teşekkürler! 💚",
            style: TextStyle(
                color: AppColors.primaryDarkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 15
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.home_filled, size: 18),
            label: const Text(
                "Ana Sayfaya Dön",
                style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
            ),
          ),
        ),
      ],
    );
  }


  /*
  Future<void> _handleSubmit(BuildContext context, ReviewController controller) async {
    debugPrint("button pressed: _handleSubmit triggered");

    if (_ratings.values.every((r) => r == 0)) {
      HapticFeedback.vibrate();
      Toasts.error(context, 'Lütfen en az bir kategoriye puan verin.');
      return;
    }

    final success = await controller.submitReview(
      storeId: widget.storeId,
      productId: widget.productId,
      existingReviewId: widget.existingReviewId,
      ratings: _ratings,
      comment: _commentController.text,
      orderId: widget.orderId,
    );

    if (!context.mounted) return;

    if (success) {
      debugPrint("🎉 UI Update: Success Dialog shown");
      HapticFeedback.mediumImpact();
      _showSuccessDialog(context);

      setState(() {
        _isSubmittedSuccess = true; // 🎯 Ekranı kilitli moda sokar
      });
    } else {
      debugPrint("❗ UI Update: Dynamic error message shown");
      final errorState = ref.read(reviewControllerProvider);
      final errorMessage = errorState.maybeWhen(
        error: (error, _) => error.toString().replaceAll("Exception: ", ""),
        orElse: () => 'İşlem sırasında bir hata oluştu.',
      );
      HapticFeedback.vibrate();
      Toasts.error(context, errorMessage);
    }
  }


   */

  // lib/features/review/presentation/widgets/rating_form_card.dart

  Future<void> _handleSubmit(BuildContext context, ReviewController controller) async {
    debugPrint("button pressed: _handleSubmit triggered");

    if (_ratings.values.every((r) => r == 0)) {
      HapticFeedback.vibrate();
      Toasts.error(context, 'Lütfen en az bir kategoriye puan verin.');
      return;
    }

    final success = await controller.submitReview(
      storeId: widget.storeId,
      productId: widget.productId,
      existingReviewId: widget.existingReviewId,
      ratings: _ratings,
      comment: _commentController.text,
      orderId: widget.orderId,
    );

    if (!context.mounted) return;

    if (success) {
      debugPrint("🎉 UI Update: Success Dialog shown");
      HapticFeedback.mediumImpact();

      // 🎯 BURASI KRİTİK: Başarı mesajı geldikten sonra UI'ı kilitliyoruz.
      // Backend veriyi göndermese bile bu state sayesinde kullanıcı sayfadan çıkana kadar form kilitli kalır.
      setState(() {
        _isSubmittedSuccess = true;
      });

      _showSuccessDialog(context);

    } else {
      final errorState = ref.read(reviewControllerProvider);
      final errorMessage = errorState.maybeWhen(
        error: (error, _) => error.toString().replaceAll("Exception: ", ""),
        orElse: () => 'İşlem sırasında bir hata oluştu.',
      );

      // 🎯 Backend 400 dönse bile "zaten yapılmış" diyorsa UI'ı kilitliyoruz
      if (errorMessage.contains("zaten") || errorMessage.contains("400")) {
        setState(() {
          _isSubmittedSuccess = true;
        });
        Toasts.error(context, 'Bu siparişi zaten değerlendirdiniz.');
      } else {
        HapticFeedback.vibrate();
        Toasts.error(context, errorMessage);
      }
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

  // ⭐️ RatingRow güncellendi: isReadOnly parametresi etkileşimi ve renk tonunu kontrol eder.
  Widget _ratingRow(String label, bool isReadOnly) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 14,
                  color: isReadOnly ? Colors.black45 : Colors.black
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 15,
              children: List.generate(5, (index) {
                final isFilled = index < _ratings[label]!;
                return GestureDetector(
                  onTap: isReadOnly ? null : () { // 🔒 Kilitli ise tıklamayı kapat
                    HapticFeedback.selectionClick();
                    setState(() {
                      _ratings[label] = index + 1;
                    });
                  },
                  child: Icon(
                    isFilled ? Icons.star : Icons.star_border,
                    size: 22,
                    // 🎨 Kilitli modda renk tonu %30 görünürlüğe çekildi (2-3 ton açık yeşil)
                    color: isFilled
                        ? (isReadOnly ? AppColors.primaryDarkGreen.withValues(alpha: 0.3) : AppColors.primaryDarkGreen)
                        : Colors.grey.shade300,
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