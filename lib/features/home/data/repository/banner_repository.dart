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
      );

      debugPrint('📥 [BANNER_REPO] status=${response.statusCode}');

      final raw = response.data;

      if (raw is Map && raw['success'] == false) {
        debugPrint('❌ [BANNER_REPO] success=false message=${raw['message']}');
        return [];
      }

      final data = (raw is Map) ? raw['data'] : null;

      if (data == null || data is! List) {
        debugPrint('❌ [BANNER_REPO] data is null or not a list');
        return [];
      }

      final banners = (data as List)
          .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
          .where((banner) => banner.isActive)
          .toList();

      banners.sort((a, b) => a.order.compareTo(b.order));

      debugPrint('✅ [BANNER_REPO] Loaded ${banners.length} active banners');
      return banners;
    } catch (e) {
      debugPrint('❌ [BANNER_REPO] Error: $e');
      return [];
    }
  }
}
