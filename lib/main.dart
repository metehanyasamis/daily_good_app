
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _uploadToken();
    });

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
      // iOS’ta permission / APNS token süreci
      if (Platform.isIOS) {
        for (int i = 0; i < 3; i++) {
          final apns = await FirebaseMessaging.instance.getAPNSToken();
          if (apns != null) break;
          await Future.delayed(const Duration(seconds: 1));
        }
      }


      // Artık FCM token almayı dene (crash etmeyecek)
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        debugPrint("⚠️ FCM token null (henüz hazır değil).");
        return;
      }

      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      String deviceId = "unknown";
      String deviceName = "Unknown Device";

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        deviceName = "${androidInfo.brand} ${androidInfo.model}";
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? "ios_unknown";
        deviceName = iosInfo.name;
      }

      await ref.read(notificationRepositoryProvider).saveDeviceToken(
        fcmToken: fcmToken,
        deviceId: deviceId,
        deviceName: deviceName,
        deviceType: PlatformUtils.name.toLowerCase(),
        appVersion: packageInfo.version,
      );

      debugPrint("✅ Cihaz kaydı başarılı: $deviceName ($deviceId)");
    } catch (e, st) {
      debugPrint("❌ Cihaz kaydı hatası: $e");
      debugPrint("$st");
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

      // --- EKLEMEN GEREKEN KISIM BURASI ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate, // Özellikle bu iOS picker için şart
      ],
      supportedLocales: const [
        Locale('tr', 'TR'), // Türkçe
        Locale('en', 'US'), // İngilizce (Yedek olarak kalsın)
      ],
      locale: const Locale('tr', 'TR'), // Uygulamayı Türkçe'ye zorla
      // ------------------------------------


      // 🔥 GLOBAL KLAVYE KAPATMA DOKUNUŞU BURADA:
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: GestureDetector(
            onTap: () {
              // Mevcut odağı kontrol et ve klavyeyi kapat
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            // child! router'dan gelen o anki sayfadır
            child: child!,
          ),
        );
      },
    );
  }
}

