// lib/features/settings/domain/providers/legal_settings_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../data/models/legal_settings_model.dart';
import '../../data/repository/settings_repository.dart';

// ✅ REPO PROVIDER (Hata veren eksik kısım buydu)
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SettingsRepository(dio);
});

// ✅ FUTURE PROVIDER
final legalSettingsProvider = FutureProvider<LegalSettingsModel>((ref) async {
  debugPrint("🔄 [LegalSettingsProvider] Çalışıyor...");
  final repository = ref.watch(settingsRepositoryProvider);

  try {
    final result = await repository.getLegalSettings();
    debugPrint("✨ [LegalSettingsProvider] Veri başarıyla yüklendi.");
    return result;
  } catch (e, stack) {
    debugPrint("💥 [LegalSettingsProvider] HATA YAKALANDI: $e");
    debugPrint("📚 StackTrace: $stack");
    rethrow;
  }
});