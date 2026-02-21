import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum EmptyStateType {
  noProduct,    // Yakınlarda paket yok
  noLocation,   // Konum seçilmedi veya kapalı
  noFavorites,  // Favori ürün yok
  searchNoResult // Arama sonucu bulunamadı
}

class CustomEmptyState extends StatelessWidget {
  final EmptyStateType type;
  final String? addressTitle;
  final VoidCallback onActionTap;
  final String? customMessage; // Opsiyonel: Özel bir mesaj yazmak istersen

  const CustomEmptyState({
    super.key,
    required this.type,
    required this.onActionTap,
    this.addressTitle,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    // Tip bazlı yapılandırma
    final config = _getConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // İkon Alanı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLightGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(config.icon, size: 40, color: AppColors.primaryDarkGreen),
          ),
          const SizedBox(height: 16),
          // Başlık
          Text(
            config.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // Açıklama
          _buildDescription(config.description),
          const SizedBox(height: 24),
          // Aksiyon Butonu
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onActionTap,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryDarkGreen),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                config.buttonText,
                style: const TextStyle(
                  color: AppColors.primaryDarkGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(String defaultDesc) {
    // Eğer noProduct ise ve adres varsa RichText göster
    if (type == EmptyStateType.noProduct && addressTitle != null) {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          children: [
            const TextSpan(text: "Şu an "),
            TextSpan(
              text: addressTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen),
            ),
            const TextSpan(text: " yakınlarında aktif bir paket bulunmuyor."),
          ],
        ),
      );
    }
    // Diğer durumlar için düz text
    return Text(
      customMessage ?? defaultDesc,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
    );
  }

  _EmptyStateConfig _getConfig() {
    switch (type) {
      case EmptyStateType.noLocation:
        return _EmptyStateConfig(
          icon: Icons.location_off_rounded,
          title: "Konumunuz Seçilmedi",
          description: "Sana en yakın sürpriz paketleri listelemek için konumunu bilmemiz gerekiyor.",
          buttonText: "Konum Seç / Ayarları Aç",
        );
      case EmptyStateType.noFavorites:
        return _EmptyStateConfig(
          icon: Icons.favorite_border_rounded,
          title: "Favoriniz Bulunmuyor",
          description: "Beğendiğin paketleri favorilerine ekleyerek onları burada kolayca bulabilirsin.",
          buttonText: "Keşfetmeye Başla",
        );
      case EmptyStateType.searchNoResult:
        return _EmptyStateConfig(
          icon: Icons.search_off_rounded,
          title: "Sonuç Bulunamadı",
          description: "Aradığın kriterlere uygun paket bulamadık. Kelimeleri değiştirmeyi deneyebilirsin.",
          buttonText: "Aramayı Temizle",
        );
      case EmptyStateType.noProduct:
      default:
        return _EmptyStateConfig(
          icon: Icons.storefront_outlined,
          title: "Yakınında Paket Bulunamadı",
          description: "Bu bölge yakınlarında şu an aktif bir paket bulunmuyor.",
          buttonText: "Başka Bir Adres Seç",
        );
    }
  }
}

class _EmptyStateConfig {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;

  _EmptyStateConfig({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
  });
}