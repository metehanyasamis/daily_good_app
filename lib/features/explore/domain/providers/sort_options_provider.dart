// sort_options_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/widgets/explore_filter_sheet.dart';


// Default mapping between UI filter enum and backend sort_by keys.
// Use null if backend doesn't support that particular sort (client-side fallback).
final sortByMapProvider = Provider<Map<ExploreFilterOption, String?>>((ref) {
  return {
    ExploreFilterOption.recommended: 'created_at',
    ExploreFilterOption.price: 'sale_price',
    ExploreFilterOption.distance: null, // backend may not support; client-side fallback
    ExploreFilterOption.rating: 'store_rating',
  };
});

// NOTE:
// - To make this fully dynamic, implement a StateNotifierProvider that fetches
//   available sort options from backend (e.g. /api/v1/products/sort-options) and
//   updates this map at runtime. For now this provider gives safe defaults.