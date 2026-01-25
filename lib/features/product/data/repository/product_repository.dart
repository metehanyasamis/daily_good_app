// lib/features/product/data/repository/product_repository.dart
/*import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../core/providers/dio_provider.dart';
import '../../../home/presentation/data/models/home_state.dart';
import '../models/product_list_response.dart';
import '../models/product_model.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(dioProvider));
});

class ProductRepository {
  final Dio _dio;
  ProductRepository(this._dio);

  /// Existing method (kept) — returns ProductListResponse for compatibility.
  Future<ProductListResponse> fetchProducts({
    String? categoryId,
    String? storeId,
    double? latitude,
    double? longitude,
    String? search,
    int perPage = 15,
    int page = 1,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    bool? hemenYaninda,
    bool? sonSans,
    bool? yeni,
    bool? bugun,
    bool? yarin,
  }) async {
    debugPrint(
      '🟣 PRODUCT FETCH PARAMS → '
          'categoryId=$categoryId '
          'lat=$latitude lng=$longitude '
          'sortBy=$sortBy sortOrder=$sortOrder '
          'hemenYaninda=$hemenYaninda '
          'sonSans=$sonSans '
          'yeni=$yeni '
          'bugun=$bugun '
          'yarin=$yarin',
    );

    final params = <String, dynamic>{
      if (categoryId != null) 'categoryId': categoryId,
      if (storeId != null) 'store_id': storeId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (search != null && search.isNotEmpty) 'name': search,
      'per_page': perPage,
      'page': page,
      'sort_by': sortBy,
      'sort_order': sortOrder,
      if (hemenYaninda == true) 'hemen_yaninda': true,
      if (sonSans == true) 'son_sans': true,
      if (yeni == true) 'yeni': true,
      if (bugun == true) 'bugun': true,
      if (yarin == true) 'yarin': true,
    };

    final res = await _dio.get(
      '/products/category',
      queryParameters: params,
    );

    // safer logging: data may be a List or Map (grouped)
    final data = res.data['data'];
    if (data is Map) {
      int total = 0;
      data.forEach((k, v) {
        if (v is List) total += v.length;
      });
      debugPrint('🟢 PRODUCT API RESULT → grouped data with total $total items (groups: ${data.keys.toList()})');
    } else if (data is List) {
      debugPrint('🟢 PRODUCT API RESULT → list data with ${data.length} items');
    } else {
      debugPrint('🟢 PRODUCT API RESULT → data type = ${data.runtimeType}');
    }

    return ProductListResponse.fromJson(res.data);
  }

  /// New helper: returns flattened List<ProductModel> regardless of grouped/list shape.
  Future<List<ProductModel>> fetchProductsFlat({
    String? categoryId,
    String? storeId,
    double? latitude,
    double? longitude,
    String? search,
    int perPage = 15,
    int page = 1,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    bool? hemenYaninda,
    bool? sonSans,
    bool? yeni,
    bool? bugun,
    bool? yarin,
  }) async {
    final params = <String, dynamic>{
      if (categoryId != null) 'categoryId': categoryId,
      if (storeId != null) 'store_id': storeId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (search != null && search.isNotEmpty) 'name': search,
      'per_page': perPage,
      'page': page,
      'sort_by': sortBy,
      'sort_order': sortOrder,
      if (hemenYaninda == true) 'hemen_yaninda': true,
      if (sonSans == true) 'son_sans': true,
      if (yeni == true) 'yeni': true,
      if (bugun == true) 'bugun': true,
      if (yarin == true) 'yarin': true,
    };

    final res = await _dio.get('/products/category', queryParameters: params);

    final dynamic data = res.data != null ? res.data['data'] : null;
    final List<ProductModel> out = [];

    if (data == null) {
      debugPrint('PRODUCT REPO: fetchProductsFlat -> data is null');
      return out;
    }

    // Local helper to try to parse a single "item" into ProductModel and push to out.
    void _tryParseItem(dynamic item, String ctx) {
      try {

        debugPrint(' denenen item: $item');

        if (item == null) {
          debugPrint('PRODUCT REPO: skip null item in $ctx');
          return;
        }

        if (item is ProductModel) {
          out.add(item);
          return;
        }

        // Many server responses are Map<String, dynamic>
        if (item is Map<String, dynamic>) {
          out.add(ProductModel.fromJsonMap(item));
          return;
        }

        // If item is a List (nested), try first element if it's a Map
        if (item is List && item.isNotEmpty) {
          final first = item.first;
          if (first is ProductModel) {
            out.add(first);
            return;
          } else if (first is Map<String, dynamic>) {
            out.add(ProductModel.fromJsonMap(first));
            return;
          } else {
            debugPrint('PRODUCT REPO: nested list item has unsupported first type in $ctx -> ${first.runtimeType}');
            return;
          }
        }

        // If it's a JSON-like decoded object but typed as LinkedHashMap (non-generic), handle generically
        if (item is Map) {
          // attempt to cast to Map<String, dynamic>
          final castMap = Map<String, dynamic>.from(item);
          out.add(ProductModel.fromJsonMap(castMap));
          return;
        }

        debugPrint('PRODUCT REPO: unexpected item type in $ctx -> ${item.runtimeType} : $item');
      } catch (e, st) {
        debugPrint('PRODUCT REPO: parse error for item in $ctx -> $e\n$st');
        debugPrint('🔥 PARSE FAIL in $ctx! Hata: $e');
        debugPrint('🔥 HATALI ITEM DATA: $item');
      }
    }

    // If server returned grouped object (hemen_yaninda, yeni, etc.)
    if (data is Map) {
      debugPrint('PRODUCT REPO: fetchProductsFlat -> grouped data keys=${data.keys.toList()}');
      data.forEach((key, val) {
        if (val == null) return;
        if (val is List) {
          for (final item in val) {
            _tryParseItem(item, 'group:$key');
          }
        } else if (val is Map) {
          // some groups might be a single object instead of list — attempt parse
          _tryParseItem(val, 'group:$key');
        } else {
          debugPrint('PRODUCT REPO: ignoring non-list/non-map group value for key=$key -> ${val.runtimeType}');
        }
      });
    }
    // If server returned a flat list of products
    else if (data is List) {
      debugPrint('PRODUCT REPO: fetchProductsFlat -> list length=${data.length}');
      for (final item in data) {
        _tryParseItem(item, 'list');
      }
    } else {
      debugPrint('PRODUCT REPO: fetchProductsFlat -> unexpected data type ${data.runtimeType}');
    }

    debugPrint('PRODUCT REPO: fetchProductsFlat -> parsed ${out.length} products');
    return out;
  }

  // lib/features/product/data/repository/product_repository.dart

  Future<List<ProductModel>> fetchProductsList({
    String? categoryId,
    double? latitude,
    double? longitude,
    String? search,
    int perPage = 15,
    int page = 1,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    bool? hemenYaninda,
    bool? sonSans,
    bool? yeni,
    bool? bugun,
    bool? yarin,
  }) async {
    // ✅ DİKKAT: dio baseUrl zaten .../api/v1 olduğu için burada /api/v1 YAZMIYORUZ
    // ✅ SENDE ÇALIŞAN ENDPOINT: /products/category
    const path = '/products/category';

    final qp = <String, dynamic>{
      if (categoryId != null && categoryId.isNotEmpty) 'category_id': categoryId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (search != null && search.trim().isNotEmpty) 'name': search.trim(),

      'per_page': perPage,
      'page': page,
      'sort_by': sortBy,
      'sort_order': sortOrder,

      // ✅ Flag’ler: SADECE true ise gönder
      if (hemenYaninda == true) 'hemen_yaninda': true,
      if (sonSans == true) 'son_sans': true,
      if (yeni == true) 'yeni': true,
      if (bugun == true) 'bugun': true,
      if (yarin == true) 'yarin': true,
    };

    debugPrint('📡 [REPO_LIST] GET $path');
    debugPrint('   qp=$qp');

    final res = await _dio.get(path, queryParameters: qp);

    debugPrint('📥 [REPO_LIST] status=${res.statusCode}');
    debugPrint('📥 [REPO_LIST] rawType=${res.data.runtimeType}');
    if (res.data is Map) {
      debugPrint('📥 [REPO_LIST] rawKeys=${(res.data as Map).keys.toList()}');
    }

    final raw = res.data;

    // Bazı backendlere göre "success:false" ama 200 de dönebiliyor
    if (raw is Map && raw['success'] == false) {
      debugPrint('❌ [REPO_LIST] success=false message=${raw['message']} code=${raw['error_code']}');
      return [];
    }

    // ⚠️ /products/category endpoint'i bazen grouped döner:
    // data: { son_sans: [...], hemen_yaninda: [...], ... }
    final data = (raw is Map) ? raw['data'] : null;

    if (data == null) {
      debugPrint('❌ [REPO_LIST] data=null raw=$raw');
      return [];
    }

    // ✅ Eğer backend düz liste döndürüyorsa:
    if (data is List) {
      debugPrint('📥 [REPO_LIST] data(List) items=${data.length}');
      return data.map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }

    // ✅ Eğer grouped döndürüyorsa, flag'e göre doğru listeyi seç
    if (data is Map) {
      final String? groupKey = sonSans == true
          ? 'son_sans'
          : hemenYaninda == true
          ? 'hemen_yaninda'
          : yeni == true
          ? 'yeni'
          : bugun == true
          ? 'bugun'
          : yarin == true
          ? 'yarin'
          : null;

      debugPrint('🧩 [REPO_LIST] grouped response, groupKey=$groupKey, keys=${data.keys.toList()}');

      final List<dynamic> list = groupKey != null && data[groupKey] is List
          ? (data[groupKey] as List)
          : (data['items'] is List ? (data['items'] as List) : <dynamic>[]);

      debugPrint('📥 [REPO_LIST] grouped items=${list.length}');

      final out = <ProductModel>[];
      for (final e in list) {
        try {
          if (e is Map<String, dynamic>) {
            out.add(ProductModel.fromJson(e));
          } else if (e is Map) {
            out.add(ProductModel.fromJson(Map<String, dynamic>.from(e)));
          } else {
            debugPrint('⚠️ [REPO_LIST] skip non-map item type=${e.runtimeType}');
          }
        } catch (err, st) {
          debugPrint('🔥 [REPO_LIST] parse fail err=$err\n$st\nitem=$e');
        }
      }

      debugPrint('✅ [REPO_LIST] parsed(grouped)=${out.length}');
      return out;
    }

    debugPrint('❌ [REPO_LIST] data unexpected type=${data.runtimeType} data=$data');
    return [];
  }




  Future<ProductModel> getProductDetail(String id) async {
    final res = await _dio.get('/products/$id');

    // BURAYA EKLE: Ham veriyi ve tipini görelim
    debugPrint('🚨 RAW DETAIL DATA: ${res.data['data']}');
    debugPrint('🚨 RAW DETAIL TYPE: ${res.data['data'].runtimeType}');

    final data = res.data['data'];
    debugPrint('📦 REPO DEBUG: data type = ${data.runtimeType}');

    if (data is List && data.isNotEmpty) {
      debugPrint('ℹ️ INFO: Veri liste olarak geldi, ilki alınıyor.');
      debugPrint('⚠️ UYARI: Detay verisi List geldi, ilk eleman zorlanıyor.');
      return ProductModel.fromJsonMap(data.first);
    }

    if (data == null) {
      debugPrint('❌ ERROR: Data null geldi!');
      throw FormatException('Product detail data is null for id=$id');
    }

    return ProductModel.fromJsonMap(data);
  }

  Future<Map<HomeSection, List<ProductModel>>> fetchHomeSections({
    required double latitude,
    required double longitude,
  }) async {
    debugPrint('🟢 HOME FETCH → lat=$latitude lng=$longitude');

    final res = await _dio.get(
      '/products/category',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    final data = res.data['data'] as Map<String, dynamic>;

    return {
      HomeSection.hemenYaninda: ProductListResponse.fromRawList(data['hemen_yaninda']),
      HomeSection.sonSans: ProductListResponse.fromRawList(data['son_sans']),
      HomeSection.yeni: ProductListResponse.fromRawList(data['yeni']),
      HomeSection.bugun: ProductListResponse.fromRawList(data['bugun']),
      HomeSection.yarin: ProductListResponse.fromRawList(data['yarin']),
    };
  }
}

 */

// lib/features/product/data/repository/product_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dio_provider.dart';
import '../../../home/presentation/data/models/home_state.dart';
import '../models/product_model.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(dioProvider));
});

class ProductRepository {
  final Dio _dio;
  ProductRepository(this._dio);

  static const String _categoryPath = '/products/category';

  // backend dokümanına göre group key’ler
  static const _groupKeys = <String>{
    'hemen_yaninda',
    'son_sans',
    'yeni',
    'bugun',
    'yarin',
  };

  // -----------------------------
  // Param builder (tek yer)
  // -----------------------------
  Map<String, dynamic> _buildQp({
    String? categoryId,
    String? storeId,
    double? latitude,
    double? longitude,
    String? name,
    int perPage = 15,
    int page = 1,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    bool? hemenYaninda,
    bool? sonSans,
    bool? yeni,
    bool? bugun,
    bool? yarin,
  }) {
    final qp = <String, dynamic>{
      if (categoryId != null && categoryId.trim().isNotEmpty) 'categoryId': categoryId,
      if (storeId != null && storeId.trim().isNotEmpty) 'storeId': storeId, // eğer backend storeId destekliyorsa
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      'per_page': perPage,
      'page': page,
      'sort_by': sortBy,
      'sort_order': sortOrder,

      // Dokümanda false da örneklenmiş ama biz SADECE true gönderiyoruz (temiz)
      if (hemenYaninda == true) 'hemen_yaninda': true,
      if (sonSans == true) 'son_sans': true,
      if (yeni == true) 'yeni': true,
      if (bugun == true) 'bugun': true,
      if (yarin == true) 'yarin': true,
    };

    return qp;
  }

  // -----------------------------
  // Raw GET + Debug
  // -----------------------------
  Future<Map<String, dynamic>> _getCategoryRaw(Map<String, dynamic> qp) async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📡 [REPO] GET $_categoryPath');
    debugPrint('📡 [REPO] qp=$qp');

    final res = await _dio.get(_categoryPath, queryParameters: qp);

    debugPrint('📥 [REPO] status=${res.statusCode}');
    debugPrint('📥 [REPO] type=${res.data.runtimeType}');

    if (res.data is! Map) {
      debugPrint('❌ [REPO] Unexpected response (not Map) -> ${res.data}');
      throw FormatException('Unexpected response type: ${res.data.runtimeType}');
    }

    final root = Map<String, dynamic>.from(res.data as Map);
    debugPrint('📥 [REPO] rootKeys=${root.keys.toList()}');

    // Bazı backendler hata durumunda {success:false,...} dönebilir
    if (root['success'] == false) {
      debugPrint('❌ [REPO] success=false message=${root['message']}');
      return <String, dynamic>{};
    }

    // ✅ Normalize: grup verisi root'ta mı, data içinde mi?
    Map<String, dynamic> normalized;

    final hasGroupsAtRoot = _groupKeys.any((k) => root.containsKey(k));
    final data = root['data'];

    if (hasGroupsAtRoot) {
      normalized = root;
      debugPrint('✅ [REPO] grouped data ROOT seviyesinde');
    } else if (data is Map) {
      final dataMap = Map<String, dynamic>.from(data);
      final hasGroupsInData = _groupKeys.any((k) => dataMap.containsKey(k));

      if (hasGroupsInData) {
        normalized = dataMap;
        debugPrint('✅ [REPO] grouped data root["data"] içinde');
        // pagination root'ta geldiyse dataMap'e taşı
        if (!normalized.containsKey('pagination') && root['pagination'] is Map) {
          normalized['pagination'] = root['pagination'];
        }
      } else {
        debugPrint('❌ [REPO] data var ama grouped keys yok. dataKeys=${dataMap.keys.toList()}');
        return <String, dynamic>{};
      }
    } else {
      debugPrint('❌ [REPO] ne root ne data grouped. rootKeys=${root.keys.toList()}');
      return <String, dynamic>{};
    }

    // Pagination debug (varsa)
    final pagAny = normalized['pagination'] ?? root['pagination'];
    if (pagAny is Map) {
      final pag = Map<String, dynamic>.from(pagAny);
      debugPrint('📄 [REPO] pagination keys=${pag.keys.toList()}');
      for (final k in pag.keys) {
        final v = pag[k];
        if (v is Map) {
          final m = Map<String, dynamic>.from(v);
          debugPrint('📄 [REPO] pag[$k] total=${m['total']} page=${m['current_page']}/${m['last_page']} per=${m['per_page']}');
        }
      }
      // normalized içine set et (kodun başka yerleri normalized['pagination'] görebilsin)
      normalized['pagination'] = pag;
    }

    debugPrint('📦 [REPO] normalizedKeys=${normalized.keys.toList()}');
    for (final k in _groupKeys) {
      final v = normalized[k];
      debugPrint('📦 [REPO] group[$k] type=${v.runtimeType} len=${v is List ? v.length : '-'}');
    }

    return normalized;
  }


  // -----------------------------
  // Parse helper: list parse
  // -----------------------------
  List<ProductModel> _parseList(dynamic listRaw, {required String ctx}) {
    final out = <ProductModel>[];
    if (listRaw is! List) {
      debugPrint('⚠️ [PARSE] $ctx not a List -> ${listRaw.runtimeType}');
      return out;
    }

    for (final item in listRaw) {
      try {
        if (item is Map) {
          out.add(ProductModel.fromJsonMap(Map<String, dynamic>.from(item)));
        } else {
          debugPrint('⚠️ [PARSE] $ctx skip non-map item type=${item.runtimeType}');
        }
      } catch (e, st) {
        debugPrint('🔥 [PARSE] $ctx item parse fail: $e');
        debugPrint(st.toString());
        debugPrint('🔥 [PARSE] bad item=$item');
      }
    }
    return out;
  }

  // groupKey seçimi: feed filtresi varsa sadece o grup
  String? _groupKeyFromFlags({
    bool? hemenYaninda,
    bool? sonSans,
    bool? yeni,
    bool? bugun,
    bool? yarin,
  }) {
    if (hemenYaninda == true) return 'hemen_yaninda';
    if (sonSans == true) return 'son_sans';
    if (yeni == true) return 'yeni';
    if (bugun == true) return 'bugun';
    if (yarin == true) return 'yarin';
    return null;
  }

  // ------------------------------------------------------------
  // ✅ Explore list için: flag varsa o grubu döndür, yoksa "flatten"
  // ------------------------------------------------------------
  Future<List<ProductModel>> fetchProductsList({
    String? categoryId,
    String? storeId,
    double? latitude,
    double? longitude,
    String? search,
    int perPage = 15,
    int page = 1,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    bool? hemenYaninda,
    bool? sonSans,
    bool? yeni,
    bool? bugun,
    bool? yarin,
  }) async {
    final qp = _buildQp(
      categoryId: categoryId,
      storeId: storeId,
      latitude: latitude,
      longitude: longitude,
      name: search,
      perPage: perPage,
      page: page,
      sortBy: sortBy,
      sortOrder: sortOrder,
      hemenYaninda: hemenYaninda,
      sonSans: sonSans,
      yeni: yeni,
      bugun: bugun,
      yarin: yarin,
    );

    debugPrint("🧭 [REPO_CALL] fetchProductsList groupKey=${_groupKeyFromFlags(hemenYaninda: hemenYaninda, sonSans: sonSans, yeni: yeni, bugun: bugun, yarin: yarin)} qp=$qp");

    final raw = await _getCategoryRaw(qp);

    if (raw.isEmpty) return [];

    final groupKey = _groupKeyFromFlags(
      hemenYaninda: hemenYaninda,
      sonSans: sonSans,
      yeni: yeni,
      bugun: bugun,
      yarin: yarin,
    );

    // ✅ flag varsa sadece o grup
    if (groupKey != null) {
      final list = _parseList(raw[groupKey], ctx: 'group:$groupKey');
      debugPrint('✅ [REPO_LIST] group=$groupKey parsed=${list.length}');
      return list;
    }

    // ✅ flag yoksa: tüm grupları birleştir (flatten)
    final out = <ProductModel>[];
    int rawTotal = 0;

    for (final k in _groupKeys) {
      final v = raw[k];
      if (v is List) {
        debugPrint("🟦 [BACKEND_GROUP:$k] count=${v.length}");

        // ✅ Baklava araması (debug)
        for (final item in v) {
          if (item is Map) {
            final name = (item['name'] ?? '').toString().toLowerCase();
            if (name.contains('baklava')) {
              debugPrint("🍰 [BACKEND_HAS_BAKLAVA] group=$k name=${item['name']} id=${item['id']} store=${(item['store'] is Map) ? (item['store']['name']) : '-'}");
            }
          }
        }

        rawTotal += v.length;
        out.addAll(_parseList(v, ctx: 'flat:$k'));
      } else {
        debugPrint("🟦 [BACKEND_GROUP:$k] type=${v.runtimeType} (not List)");
      }
    }


    debugPrint('✅ [REPO_LIST] flatten rawTotal=$rawTotal parsed=${out.length}');
    return out;
  }

  // ------------------------------------------------------------
  // ✅ Map sheet gibi yerler için: her zaman flatten
  // ------------------------------------------------------------
  Future<List<ProductModel>> fetchProductsFlat({
    String? storeId,
    String? categoryId,
    double? latitude,
    double? longitude,
    String? search,
    int perPage = 20,
    int page = 1,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    final qp = _buildQp(
      storeId: storeId,
      categoryId: categoryId,
      latitude: latitude,
      longitude: longitude,
      name: search,
      perPage: perPage,
      page: page,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );

    final raw = await _getCategoryRaw(qp);
    if (raw.isEmpty) return [];

    final out = <ProductModel>[];
    int rawTotal = 0;

    for (final k in _groupKeys) {
      final v = raw[k];
      if (v is List) {
        debugPrint("🟦 [BACKEND_GROUP:$k] count=${v.length}");

        rawTotal += v.length;
        out.addAll(_parseList(v, ctx: 'flat:$k'));
      }
    }

    debugPrint('✅ [REPO_FLAT] rawTotal=$rawTotal parsed=${out.length}');
    return out;
  }

  // ------------------------------------------------------------
  // ✅ Home sections (grouped)
  // ------------------------------------------------------------
  Future<Map<HomeSection, List<ProductModel>>> fetchHomeSections({
    required double latitude,
    required double longitude,
  }) async {
    final qp = _buildQp(
      latitude: latitude,
      longitude: longitude,
      perPage: 15,
      page: 1,
    );

    final raw = await _getCategoryRaw(qp);
    if (raw.isEmpty) {
      return {
        HomeSection.hemenYaninda: [],
        HomeSection.sonSans: [],
        HomeSection.yeni: [],
        HomeSection.bugun: [],
        HomeSection.yarin: [],
      };
    }

    return {
      HomeSection.hemenYaninda: _parseList(raw['hemen_yaninda'], ctx: 'home:hemen_yaninda'),
      HomeSection.sonSans: _parseList(raw['son_sans'], ctx: 'home:son_sans'),
      HomeSection.yeni: _parseList(raw['yeni'], ctx: 'home:yeni'),
      HomeSection.bugun: _parseList(raw['bugun'], ctx: 'home:bugun'),
      HomeSection.yarin: _parseList(raw['yarin'], ctx: 'home:yarin'),
    };
  }

  // ------------------------------------------------------------
  // ✅ Detail
  // ------------------------------------------------------------
  Future<ProductModel> getProductDetail(String id) async {
    debugPrint('📡 [REPO_DETAIL] GET /products/$id');
    final res = await _dio.get('/products/$id');

    if (res.data is! Map) {
      throw FormatException('Detail response not Map: ${res.data.runtimeType}');
    }

    final raw = Map<String, dynamic>.from(res.data as Map);

    if (raw['success'] == false) {
      throw Exception(raw['message'] ?? 'Product detail error');
    }

    final data = raw['data'];
    debugPrint('📥 [REPO_DETAIL] dataType=${data.runtimeType}');

    if (data is Map) {
      return ProductModel.fromJsonMap(Map<String, dynamic>.from(data));
    }

    throw FormatException('Invalid detail data type: ${data.runtimeType}');
  }
}
