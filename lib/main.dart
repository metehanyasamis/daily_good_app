import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    );
  }
}
