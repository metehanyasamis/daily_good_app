// lib/features/product/domain/providers/product_list_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../data/models/product_model.dart';
import '../../data/repository/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(dioProvider));
});

final productListProvider =
FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);

  final list = await repo.fetchProducts(); // ← getProducts yerine fetchProducts
  return list.products; // çünkü fetchProducts ProductListResponse döndürüyor
});
