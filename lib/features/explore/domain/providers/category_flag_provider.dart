import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/widgets/explore_filter_sheet.dart';

final categoryFlagMapProvider = Provider<Map<ExploreFilterOption, String?>>((ref) {
  return {
    ExploreFilterOption.hemenYaninda: 'hemen_yaninda',
    ExploreFilterOption.sonSans: 'son_sans',
    ExploreFilterOption.yeni: 'yeni',
    ExploreFilterOption.bugun: 'bugun',
    ExploreFilterOption.yarin: 'yarin',

    // Sort olanlar flag değildir:
    ExploreFilterOption.recommended: null,
    ExploreFilterOption.price: null,
    ExploreFilterOption.rating: null,
    ExploreFilterOption.distance: null,
  };
});
