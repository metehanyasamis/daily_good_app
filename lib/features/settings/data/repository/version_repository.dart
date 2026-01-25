// lib/features/settings/data/version_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dio_provider.dart';
import '../models/app_version_model.dart';

class VersionRepository {
  final Dio _dio;
  VersionRepository(this._dio);

  Future<AppVersionModel> checkVersion(String platform, String version) async {
    try {
      final response = await _dio.get(
        '/app-version/check',
        queryParameters: {
          'platform': platform,
          'version': version,
        },
      );
      return AppVersionModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}

// Provider Tanımı
final versionRepositoryProvider = Provider((ref) => VersionRepository(ref.watch(dioProvider)));