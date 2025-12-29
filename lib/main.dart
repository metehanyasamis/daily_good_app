import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  /// 🔥 Firebase
  await Firebase.initializeApp();

  String? token = await FirebaseMessaging.instance.getToken();
  print("-----------------------------------------");
  print("🔥 FCM TOKEN: $token");
  print("-----------------------------------------");

  /// 📅 Türkçe tarih formatları
  await initializeDateFormatting('tr_TR');

  runApp(
    const ProviderScope(
      child: Bootstrap(),
    ),
  );
}

class Bootstrap extends ConsumerWidget {
  const Bootstrap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Daily Good',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      // 🔥 TÜM APP'İ KURTARAN DOKUNUŞ:
      builder: (context, child) {
        return Scaffold(
          // Bu sayede alt barın üzerine binen içerikler engellenir
          body: SafeArea(
            top: false, // Üst tarafı genelde AppBar yönettiği için false bırakabilirsin
            bottom: true, // İşte Android butonlarından kurtaran ayar
            child: child!,
          ),
        );
      },
    );
  }
}
