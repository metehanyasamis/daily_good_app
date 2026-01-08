
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'core/platform/platform_utils.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/global_error_screen.dart';
import 'features/notification/data/models/notification_model.dart';
import 'features/notification/domain/providers/notification_provider.dart';
import 'features/notification/presentation/logic/notification_permission.dart';
import 'features/notification/presentation/logic/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

// 🛡️ GLOBAL HATA EKRANI (Refactored)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: GlobalErrorScreen(),
      ),
    );
  };


  /*
  // 🔥 GLOBAL AYAR: Uygulamanın sistem çubuklarıyla olan ilişkisini düzenler
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Üst bar şeffaf olsun
    statusBarIconBrightness: Brightness.dark, // Üst ikonlar (saat vs) koyu
    systemNavigationBarColor: Colors.white, // Alt bar (Android butonları) arkası beyaz
    systemNavigationBarIconBrightness: Brightness.dark, // Alt bar ikonları koyu
  ));


   */

  /// 🌍 ENV
  await dotenv.load(fileName: '.env');

  /// 🗺️ Mapbox
  final mapboxToken = dotenv.env['MAPBOX_ACCESS_TOKEN'];
  if (mapboxToken == null || mapboxToken.isEmpty) {
    throw Exception('MAPBOX_ACCESS_TOKEN bulunamadı (.env)');
  }
  MapboxOptions.setAccessToken(mapboxToken);

  /// 🔥 Firebase & Bildirim Başlatma
  await Firebase.initializeApp();

  // 1. Local Notification Servisini Başlat
  await NotificationService.init();

  // 2. İzin İste (iOS ve Android 13+)
  await NotificationPermission.request();

  // 3. Token'ı al (Zaten yapmışsın, kalsın)
  String? token = await FirebaseMessaging.instance.getToken();
  print("🔥 FCM TOKEN: $token");


  /// 📅 Türkçe tarih formatları
  await initializeDateFormatting('tr_TR');

  runApp(
    Phoenix(
      child: const ProviderScope(
        child: Bootstrap(),
      ),
    ),
  );
}

class Bootstrap extends ConsumerStatefulWidget {
  const Bootstrap({super.key});

  @override
  ConsumerState<Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends ConsumerState<Bootstrap> {
  @override
  void initState() {
    super.initState();

    // 1. Token'ı Backend'e gönder
    _uploadToken();

    // 2. Uygulama AÇIKKEN (Foreground) bildirim gelirse
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("📩 ON MESSAGE TETİKLENDİ!"); // Bu logu konsolda görmelisin

      if (message.notification != null) {
        // 1. Badge sayısını artır
        ref.read(notificationBadgeProvider.notifier).update((state) => state + 1);

        // 2. Yerel listeye ekle (Ekrandaki listeye hemen düşmesi için)
        final newNotif = NotificationModel(
          id: message.messageId ?? DateTime.now().toString(),
          title: message.notification!.title ?? 'Test',
          body: message.notification!.body ?? '',
          isRead: false,
          status: 'sent',
          createdAt: DateTime.now(),
        );

        ref.read(localNotificationsProvider.notifier).update((state) => [newNotif, ...state]);

        // 3. Bildirimi göster
        NotificationService.show(
          id: message.notification.hashCode,
          title: message.notification!.title ?? '',
          body: message.notification!.body ?? '',
        );
      }
    });

    // 3. Uygulama ARKAPLANDAYKEN bildirime tıklanırsa
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("📩 Bildirime tıklandı, sayfaya gidiliyor...");
      ref.read(appRouterProvider).push('/notifications');
    });

    _checkInitialMessage();
  }

  Future<void> _uploadToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      String deviceId = "unknown";
      String deviceName = "Unknown Device";

      // 📱 Cihaz bilgilerini dinamik alalım
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id; // Cihazın benzersiz ID'si
        deviceName = "${androidInfo.brand} ${androidInfo.model}";
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? "ios_unknown";
        deviceName = iosInfo.name;
      }

      // 🚀 Backend'e gerçek verileri gönderiyoruz
      await ref.read(notificationRepositoryProvider).saveDeviceToken(
        fcmToken: token,
        deviceId: deviceId, // Artık "device_id_123" değil!
        deviceName: deviceName, // "Samsung S21" veya "iPhone 13" gibi
        deviceType: PlatformUtils.name.toLowerCase(), // Senin sınıfın: "android" veya "ios"
        appVersion: packageInfo.version, // package_info_plus ile dinamik sürüm: "1.0.4"
      );

      debugPrint("✅ Cihaz kaydı başarılı: $deviceName ($deviceId)");
    } catch (e) {
      debugPrint("❌ Cihaz kaydı hatası: $e");
    }
  }

  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint("🚀 Uygulama bildirimle açıldı, yönlendiriliyor...");
      ref.read(appRouterProvider).push('/notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Daily Good',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      // 🔥 GLOBAL KLAVYE KAPATMA DOKUNUŞU BURADA:
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            // Mevcut odağı kontrol et ve klavyeyi kapat
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          // child! router'dan gelen o anki sayfadır
          child: child!,
        );
      },
    );
  }
}

