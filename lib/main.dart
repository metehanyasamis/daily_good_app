/*

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/global_error_screen.dart';
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


  // 🔥 GLOBAL AYAR: Uygulamanın sistem çubuklarıyla olan ilişkisini düzenler
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Üst bar şeffaf olsun
    statusBarIconBrightness: Brightness.dark, // Üst ikonlar (saat vs) koyu
    systemNavigationBarColor: Colors.white, // Alt bar (Android butonları) arkası beyaz
    systemNavigationBarIconBrightness: Brightness.dark, // Alt bar ikonları koyu
  ));

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

  String? fcmToken = await FirebaseMessaging.instance.getToken();
  debugPrint("🚀 FCM TOKEN ALINDI: $fcmToken");


  // 3. Token'ı al (Zaten yapmışsın, kalsın)
  String? token = await FirebaseMessaging.instance.getToken();
  print("🔥 FCM TOKEN: $token");

  // 4. Uygulama AÇIKKEN bildirim gelirse yakala (Foreground listener)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint("📩 Bildirime tıklandı! Veri: ${message.data}");
    if (message.notification != null) {
      NotificationService.show(
        id: message.notification.hashCode,
        title: message.notification!.title ?? '',
        body: message.notification!.body ?? '',
      );
    }
  });


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

    // Uygulama arka plandayken bildirime tıklanırsa çalışır
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("📩 Bildirime tıklandı, sayfaya gidiliyor...");
      ref.read(appRouterProvider).push('/notifications');
    });

    _checkInitialMessage();
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

 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/global_error_screen.dart';
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


  // 🔥 GLOBAL AYAR: Uygulamanın sistem çubuklarıyla olan ilişkisini düzenler
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Üst bar şeffaf olsun
    statusBarIconBrightness: Brightness.dark, // Üst ikonlar (saat vs) koyu
    systemNavigationBarColor: Colors.white, // Alt bar (Android butonları) arkası beyaz
    systemNavigationBarIconBrightness: Brightness.dark, // Alt bar ikonları koyu
  ));

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

  String? fcmToken = await FirebaseMessaging.instance.getToken();
  debugPrint("🚀 FCM TOKEN ALINDI: $fcmToken");


  // 3. Token'ı al (Zaten yapmışsın, kalsın)
  String? token = await FirebaseMessaging.instance.getToken();
  print("🔥 FCM TOKEN: $token");

  // 4. Uygulama AÇIKKEN bildirim gelirse yakala (Foreground listener)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint("📩 Bildirime tıklandı! Veri: ${message.data}");
    if (message.notification != null) {
      NotificationService.show(
        id: message.notification.hashCode,
        title: message.notification!.title ?? '',
        body: message.notification!.body ?? '',
      );
    }
  });


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

    // Uygulama arka plandayken bildirime tıklanırsa çalışır
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("📩 Bildirime tıklandı, sayfaya gidiliyor...");
      ref.read(appRouterProvider).push('/notifications');
    });

    _checkInitialMessage();
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

