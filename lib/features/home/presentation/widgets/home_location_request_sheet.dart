import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';

// Önceki adımda oluşturduğumuz helper'ı import ediyoruz
// import '../../../../core/utils/location_helper.dart';

class HomeLocationRequestSheet extends ConsumerWidget {
  const HomeLocationRequestSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar (çekme çubuğu görseli)
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Icon(Icons.location_on_rounded, size: 60, color: AppColors.primaryDarkGreen),
          const SizedBox(height: 16),
          const Text(
            "En Yakın Lezzetleri Gör",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            "Çevrendeki sürpriz paketleri mesafeye göre listelememiz için konum iznine ihtiyacımız var.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 32),

          CustomButton(
            text: "Konumumu Kullan",
            showPrice: false,
            onPressed: () async {
              Navigator.pop(context);
              // LocationHelper.checkAndRequestLocation fonksiyonunu çağırıyoruz
              // final position = await LocationHelper.checkAndRequestLocation(context);
              // if (position != null) { ... }
            },
          ),

          const SizedBox(height: 8),

          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/location-picker');
            },
            child: Text(
              "Haritadan Manuel Seç",
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}