import 'dart:convert';
import 'package:daily_good/core/data/prefs_service.dart';
import 'package:daily_good/features/saving/model/saving_model.dart';
import 'package:http/http.dart' as http;

const String _savingKey = "saving_data";

class SavingRepository {
  final String baseUrl;

  SavingRepository({required this.baseUrl});

  // ------------------------------------------------
  // 1) LOCAL OKUMA
  // ------------------------------------------------
  Future<SavingModel?> loadLocal() async {
    try {
      final jsonString = await PrefsService.getString(_savingKey);
      if (jsonString == null) return null;

      return SavingModel.fromJson(jsonDecode(jsonString));
    } catch (_) {
      return null;
    }
  }

  // ------------------------------------------------
  // 2) LOCAL KAYDETME
  // ------------------------------------------------
  Future<void> saveLocal(SavingModel model) async {
    await PrefsService.setString(_savingKey, jsonEncode(model.toJson()));
  }

  // ------------------------------------------------
  // 3) REMOTE KAYDET
  // ------------------------------------------------
  Future<void> saveRemote(SavingModel model, String userId) async {
    final url = Uri.parse("$baseUrl/saving/$userId");

    try {
      await http
          .post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(model.toJson()),
      )
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // ❗ Backend yoksa sessizce geç (Offline-first)
      return;
    }
  }

  // ------------------------------------------------
  // 4) REMOTE YÜKLEME
  // ------------------------------------------------
  Future<SavingModel?> loadRemote(String userId) async {
    final url = Uri.parse("$baseUrl/saving/$userId");

    try {
      final res = await http
          .get(url)
          .timeout(const Duration(seconds: 5));

      if (res.statusCode != 200) return null;

      final json = jsonDecode(res.body);
      return SavingModel.fromJson(json);
    } catch (_) {
      return null; // Online değil veya backend hazır değil
    }
  }

  // ------------------------------------------------
  // 5) MERGED YÜKLEME (offline-first)
  // ------------------------------------------------
  Future<SavingModel> loadMerged(String userId) async {
    // online varsa remote’ı getir
    final remote = await loadRemote(userId);
    if (remote != null) {
      await saveLocal(remote);
      return remote;
    }

    // offline fallback → local’i getir
    final local = await loadLocal();
    return local ?? const SavingModel();
  }

  // ------------------------------------------------
  // 6) RESET (local + remote)
  // ------------------------------------------------
  Future<void> resetAll(String userId) async {
    await PrefsService.remove(_savingKey);

    final url = Uri.parse("$baseUrl/saving/$userId/reset");

    try {
      await http
          .post(url)
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // backend yoksa local reset yeterli olur
    }
  }
}
