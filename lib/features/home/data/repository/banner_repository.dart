import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../models/banner_model.dart';

final bannerRepositoryProvider = Provider<BannerRepository>((ref) {
  return BannerRepository(ref.watch(dioProvider));
});

class BannerRepository {
  final Dio _dio;

  BannerRepository(this._dio);

  Future<List<BannerModel>> fetchBanners({
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int page = 1,
    int perPage = 15,
  }) async {
    debugPrint('📡 [BANNER_REPO] Fetching banners...');
    debugPrint('   sort_by=$sortBy, sort_order=$sortOrder, page=$page, per_page=$perPage');

    try {
      final response = await _dio.get(
        '/mobile-banners',
        queryParameters: {
          'sort_by': sortBy,
          'sort_order': sortOrder,
          'page': page,
          'per_page': perPage,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 5),
        ),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⏱️ [BANNER_REPO] Request timeout after 10 seconds');
          throw Exception('Banner request timeout');
        },
      );

      debugPrint('📥 [BANNER_REPO] status=${response.statusCode}');
      debugPrint('📥 [BANNER_REPO] response type: ${response.data.runtimeType}');

      final raw = response.data;
      debugPrint('📥 [BANNER_REPO] raw data keys: ${raw is Map ? (raw as Map).keys.toList() : 'not a map'}');

      if (raw is Map && raw['success'] == false) {
        debugPrint('❌ [BANNER_REPO] success=false message=${raw['message']}');
        return [];
      }

      final data = (raw is Map) ? raw['data'] : null;
      debugPrint('📥 [BANNER_REPO] data type: ${data?.runtimeType}, isList: ${data is List}');

      if (data == null) {
        debugPrint('❌ [BANNER_REPO] data is null');
        return [];
      }

      if (data is! List) {
        debugPrint('❌ [BANNER_REPO] data is not a list, type: ${data.runtimeType}');
        return [];
      }

      if ((data as List).isEmpty) {
        debugPrint('⚠️ [BANNER_REPO] data list is empty');
        return [];
      }

      debugPrint('📥 [BANNER_REPO] Processing ${data.length} banner items...');
      final banners = (data as List)
          .map((e) {
            try {
              return BannerModel.fromJson(e as Map<String, dynamic>);
            } catch (parseError) {
              debugPrint('❌ [BANNER_REPO] Failed to parse banner: $parseError, data: $e');
              return null;
            }
          })
          .whereType<BannerModel>()
          .where((banner) {
            final isActive = banner.isActive;
            final hasImage = banner.imagePath.isNotEmpty;
            debugPrint('   Banner ${banner.id}: isActive=$isActive, hasImage=$hasImage, imagePath=${banner.imagePath}');
            return isActive && hasImage;
          })
          .toList();

      banners.sort((a, b) => a.order.compareTo(b.order));

      debugPrint('✅ [BANNER_REPO] Loaded ${banners.length} active banners with images');
      if (banners.isEmpty) {
        debugPrint('⚠️ [BANNER_REPO] No active banners with images found');
      }
      return banners;
    } on DioException catch (e) {
      debugPrint('❌ [BANNER_REPO] DioException: ${e.type} - ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        debugPrint('⏱️ [BANNER_REPO] Timeout error, returning empty list');
      }
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ [BANNER_REPO] Unexpected error: $e');
      debugPrint('📦 [BANNER_REPO] StackTrace: $stackTrace');
      return [];
    }
  }
}
