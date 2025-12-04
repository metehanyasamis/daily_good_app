// lib/features/product/domain/providers/product_detail_provider.dart

import 'package:daily_good/features/product/domain/providers/product_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';

final productDetailProvider =
FutureProvider.family<ProductModel, String>((ref, id) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProductDetail(id);
});
