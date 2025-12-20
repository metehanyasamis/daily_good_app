import 'package:dio/dio.dart';

import '../models/category_model.dart';

class CategoryRepository {
  final Dio _dio;

  CategoryRepository(this._dio);

  Future<List<CategoryModel>> fetchCategories() async {
    final res = await _dio.get('/categories');

    if (res.data['success'] != true) {
      throw Exception(res.data['message']);
    }

    final list = res.data['data'] as List;
    return list.map((e) => CategoryModel.fromJson(e)).toList();
  }

  Future<CategoryModel> fetchCategoryDetail(int id) async {
    final res = await _dio.get('/categories/$id');

    if (res.data['success'] != true) {
      throw Exception(res.data['message']);
    }

    return CategoryModel.fromJson(res.data['data']);
  }
}
