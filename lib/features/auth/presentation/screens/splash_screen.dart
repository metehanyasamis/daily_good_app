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
    try {
      // 1) Sadece Kritik Kontroller (Versiyon ve Auth)
      await Future.wait([
        ref.read(appStateProvider.notifier).load(),
        _checkAppVersion(),
      ]);

      final token = await PrefsService.readToken();
      if (token != null && token.isNotEmpty) {
        // 🎯 Sadece Kullanıcıyı Doğrula (Ürünleri ve Favorileri Home'a bırak)
        await ref.read(authNotifierProvider.notifier).loadUserFromToken();
      }

    } catch (e) {
      debugPrint("🚨 Error: $e");
    } finally {
      // Hazır olduğun an yönlendir!
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