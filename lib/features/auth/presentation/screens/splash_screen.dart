import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    debugPrint("🚀 [SPLASH] Startup süreci başlatıldı...");
    final stopwatch = Stopwatch()..start();

    try {
      // 1) TEMEL AYARLAR VE VERSİYON KONTROLÜ (PARALEL)
      debugPrint("📡 [SPLASH] AppState ve Versiyon kontrolü paralel başlatılıyor...");
      await Future.wait([
        ref.read(appStateProvider.notifier).load(),
        _checkAppVersion(),
      ]);
      debugPrint("⚙️ [SPLASH] Temel kontroller bitti. Geçen süre: ${stopwatch.elapsedMilliseconds}ms");

      // 2) TOKEN KONTROLÜ
      final token = await PrefsService.readToken();
      final bool hasToken = token != null && token.isNotEmpty;
      debugPrint("🔑 [SPLASH] Token durumu: ${hasToken ? 'VAR' : 'YOK'}");

      if (hasToken) {
        debugPrint("👤 [SPLASH] Kullanıcı login durumda. Veri senkronizasyonu başlatılıyor...");

        // 🎯 DARBOĞAZI ÇÖZEN NOKTA: Tüm veri çekme işlerini aynı anda yapıyoruz.
        // Biri takılsa bile (Örn: Konum güncelleme) uygulama tamamen donmaz.
        await Future.wait([
          ref.read(authNotifierProvider.notifier).loadUserFromToken().then((_) {
            debugPrint("✅ [SPLASH] Kullanıcı bilgileri yüklendi.");
          }),
          ref.read(productsProvider.notifier).refresh().then((_) {
            debugPrint("✅ [SPLASH] Ürünler güncellendi.");
          }),
          ref.read(favoritesProvider.notifier).loadAll().then((_) {
            debugPrint("✅ [SPLASH] Favoriler senkronize edildi.");
          }),
        ]);

        // Verilerin birbirine bağlanmasını sağlar
        ref.read(appStateProvider.notifier).completeSync();
        debugPrint("📊 [SPLASH] Tüm veriler RAM'e işlendi.");
      }

      // 3) LOGO ANİMASYONUNUN TAMAMLANMASI
      // Eğer internet çok hızlıysa logo 'pat' diye kaybolmasın diye 1.2 sn'yi tamamlıyoruz.
      if (_controller.isAnimating) {
        debugPrint("🎬 [SPLASH] Animasyonun bitmesi bekleniyor...");
        await _controller.forward();
      }

    } catch (e, stack) {
      debugPrint("🚨 [SPLASH_CRITICAL_ERROR]: $e");
      debugPrint("📦 [STACKTRACE]: $stack");
      // Hata olsa bile kullanıcıyı içeride hapsetmiyoruz.
    } finally {
      stopwatch.stop();
      debugPrint("🎯 [SPLASH] Startup bitti. Toplam Süre: ${stopwatch.elapsed.inSeconds}sn. Yönlendiriliyor...");

      // Uygulamayı 'hazır' hale getir. Router bu değişkeni dinlediği için otomatik yönlenecek.
      await ref.read(appStateProvider.notifier).setInitialized(true);
    }
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

    // 🚀 UYGULAMA İLK AÇILDIĞINDA İKONLARI BEYAZ YAPAR
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Android için beyaz
        statusBarBrightness: Brightness.dark,      // iOS için beyaz
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Gradyanın görünmesi için
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
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}