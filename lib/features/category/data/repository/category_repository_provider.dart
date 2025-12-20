import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dio_provider.dart';
import 'category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dio = ref.read(dioProvider); // 🔥 interceptor’lı Dio
  return CategoryRepository(dio);
});
