import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart'; // 📦 Yeni eklendi

import '../../../../core/data/prefs_service.dart';
import '../../../../core/platform/dialogs.dart';
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
      final packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;
      final String platform = Platform.isAndroid ? "android" : "ios";

      final versionData = await ref.read(versionRepositoryProvider).checkVersion(platform, currentVersion);

      if (!mounted) return;

      // 🎯 URL açma işlemini kolaylaştırmak için yerel bir fonksiyon
      Future<void> openUpdateUrl() async {
        if (versionData.updateUrl != null) {
          final uri = Uri.parse(versionData.updateUrl!);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      }

      // 1️⃣ BAKIM MODU (Kritik: Kapatılamaz, İptal butonu yok)
      if (versionData.maintenanceMode) {
        await PlatformDialogs.confirm(
          context,
          title: "Bakım Çalışması 🛠️",
          message: "Size daha iyi hizmet verebilmek için kısa bir süreliğine bakımdayız.",
          confirmText: "Anladım",
          cancelText: "", // Butonu gizler
          barrierDismissible: false,
        );
        return; // Bakımdaysak aşağıya devam etmesin
      }

      // 2️⃣ ZORUNLU GÜNCELLEME (Kritik: Kapatılamaz, URL'e zorlar)
      if (versionData.forceUpdate) {
        final confirmed = await PlatformDialogs.confirm(
          context,
          title: "Güncelleme Gerekli 🚀",
          message: versionData.updateMessage ?? "Devam etmek için lütfen uygulamayı güncelleyin.",
          confirmText: "Güncelle",
          cancelText: "",
          barrierDismissible: false,
        );
        if (confirmed) await openUpdateUrl();
        return; // Zorunluysa aşağıya bakmasın
      }

      // 3️⃣ OPSİYONEL GÜNCELLEME (Kapatılabilir, Kullanıcıya bırakılır)
      if (versionData.updateAvailable) {
        final wantUpdate = await PlatformDialogs.confirm(
          context,
          title: "Yeni Versiyon Hazır!",
          message: versionData.updateMessage ?? "Yeni özelliklerimizi denemek ister misiniz?",
          confirmText: "Güncelle",
          cancelText: "Daha Sonra",
          barrierDismissible: true,
        );
        if (wantUpdate) await openUpdateUrl();
      }

    } catch (e) {
      debugPrint("❌ [VERSION_CONTROL] Hatası: $e");
    }
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