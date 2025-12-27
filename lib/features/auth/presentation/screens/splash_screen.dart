import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart'; // 📦 Yeni eklendi

import '../../../../core/data/prefs_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../favorites/domain/favorites_notifier.dart';
import '../../../product/domain/products_notifier.dart';
import '../../../settings/data/repository/version_repository.dart';
import '../../domain/providers/auth_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    Future.microtask(_startup);
  }

  Future<void> _startup() async {
    debugPrint("🚀 [SPLASH] Startup süreci başladı...");

    // 1) AppState yükle (Senin orijinal kodun)
    await ref.read(appStateProvider.notifier).load();
    debugPrint("⚙️ [SPLASH] AppState Yüklendi");

    // 2) Versiyon Kontrolü (Az önce atlanan kısım, geri eklendi)
    await _checkAppVersion();
    debugPrint("🔄 [SPLASH] Versiyon kontrolü tamamlandı.");

    // 3) Token işlemleri
    final token = await PrefsService.readToken();
    debugPrint("🔑 [SPLASH] Token durumu: ${token != null && token.isNotEmpty}");

    if (token != null && token.isNotEmpty) {
      debugPrint("👤 [SPLASH] Kullanıcı yükleniyor...");
      // Kullanıcıyı yükle ve bitmesini BEKLE
      await ref.read(authNotifierProvider.notifier).loadUserFromToken();

      // Kullanıcı nesnesi dolana kadar kısa bir güvenlik beklemesi
      await Future.delayed(const Duration(milliseconds: 200));

      final user = ref.read(authNotifierProvider).user;

      if (user != null) {
        debugPrint("✅ [SPLASH] Kullanıcı onaylandı (ID: ${user.id}). Veriler senkronize ediliyor...");

        try {
          // 4) Ürünleri çek (Refresh et ki favorilerle eşleşsin)
          await ref.read(productsProvider.notifier).refresh();

          // 5) FAVORİLERİ ÇEK VE BEKLE
          // Burası asıl favori listesinin dolmasını sağlayan yer
          debugPrint("⭐ [SPLASH] Favoriler loadAll başlatılıyor...");
          await ref.read(favoritesProvider.notifier).loadAll();
          ref.read(appStateProvider.notifier).completeSync();

          final finalFavs = ref.read(favoritesProvider);
          debugPrint("📊 [SPLASH] Senkronizasyon Bitti: ${finalFavs.productIds.length} Ürün, ${finalFavs.storeIds.length} Mağaza");
        } catch (e) {
          debugPrint("❌ [SPLASH] Veri çekme sırasında hata: $e");
        }
      } else {
        debugPrint("🚨 [SPLASH] Token var ama kullanıcı yüklenemedi!");
      }
    } else {
      debugPrint("⚠️ [SPLASH] Token yok, login bekleniyor.");
    }

    debugPrint("🎯 [SPLASH] Startup süreci bitti.");
    await ref.read(appStateProvider.notifier).setInitialized(true);
  }

  Future<void> _checkAppVersion() async {
    try {
      // 🎯 Paket bilgisini cihazdan alıyoruz
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version; // Örn: "1.0.0"
      final String platform = Platform.isAndroid ? "android" : "ios";

      debugPrint("📱 Cihaz Versiyonu: $currentVersion | Platform: $platform");

      final versionData = await ref.read(versionRepositoryProvider).checkVersion(platform, currentVersion);

      if (!mounted) return;

      // A) Bakım Modu
      if (versionData.maintenanceMode) {
        await _showVersionDialog(
          title: "Bakım Çalışması 🛠️",
          message: "Size daha iyi hizmet verebilmek için kısa bir süreliğine bakımdayız.",
          canCancel: false,
        );
      }

      // B) Zorunlu Güncelleme
      if (versionData.forceUpdate) {
        await _showVersionDialog(
          title: "Güncelleme Gerekli 🚀",
          message: versionData.updateMessage ?? "Devam etmek için lütfen uygulamayı güncelleyin.",
          canCancel: false,
          url: versionData.updateUrl,
        );
      }
      // C) Opsiyonel Güncelleme
      else if (versionData.updateAvailable) {
        await _showVersionDialog(
          title: "Yeni Versiyon Hazır!",
          message: versionData.updateMessage ?? "Yeni özelliklerimizi denemek ister misiniz?",
          canCancel: true,
          url: versionData.updateUrl,
        );
      }
    } catch (e) {
      debugPrint("❌ Versiyon kontrolü hatası: $e");
    }
  }

  Future<void> _showVersionDialog({
    required String title,
    required String message,
    required bool canCancel,
    String? url,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: canCancel,
      builder: (context) => PopScope(
        canPop: canCancel, // Kullanıcı geri tuşuyla kapatamasın (canCancel false ise)
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(message),
          actions: [
            if (canCancel)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Daha Sonra", style: TextStyle(color: Colors.grey)),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDarkGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (url != null) {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              },
              child: const Text("Güncelle"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.dark),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: Image.asset(
              "assets/logos/whiteLogo.png",
              height: size.height * 0.32,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}