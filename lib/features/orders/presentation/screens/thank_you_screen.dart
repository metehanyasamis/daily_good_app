import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod eklendi
import 'package:go_router/go_router.dart';
import '../../../../core/platform/platform_widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../orders/domain/providers/order_provider.dart'; // Provider yolu

class ThankYouScreen extends ConsumerWidget { // ConsumerWidget yapıldı
  const ThankYouScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔥 Backend verisini izliyoruz
    final summaryAsync = ref.watch(orderHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: summaryAsync.when(
          loading: () => Center(child: PlatformWidgets.loader()),
          error: (err, _) => const Center(child: Text("Veriler güncellenirken bir hata oluştu.")),
          data: (summary) {
            // Backend'den gelen gerçek veriler
            final double carbonSaved = summary.carbonFootprintSaved;
            final double moneySaved = summary.totalSavings;

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logos/dailyGood_tekSaatLogo.png', height: 120),
                  const SizedBox(height: 24),
                  const Text(
                    "Teşekkürler!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 38),
                  const Text(
                    "Bir paketi kurtardın 🌱\nGıdanı korudun, geleceğine sahip çıktın 💚",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),

                  // 🔥 Backend'den gelen gerçek Karbon verisi
                  _infoCard(
                      "Bu sipariş ile birlikte",
                      "${carbonSaved.toStringAsFixed(1)} kg",
                      "karbon salımını önledin"
                  ),
                  const SizedBox(height: 16),

                  // 🔥 Backend'den gelen gerçek Tasarruf verisi
                  _infoCard(
                      "Bu sipariş ile birlikte",
                      "${moneySaved.toStringAsFixed(0)} ₺",
                      "tasarruf ettin"
                  ),

                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Harika! Ana Sayfaya Dön',
                    onPressed: () => context.go('/home'),
                    showPrice: false,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value, String desc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primaryDarkGreen.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDarkGreen)),
          const SizedBox(height: 2),
          Text(desc,
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }
}