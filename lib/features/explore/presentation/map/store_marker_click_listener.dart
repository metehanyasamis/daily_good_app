import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../stores/data/model/store_summary.dart';

class StoreMarkerClickListener extends OnPointAnnotationClickListener {
  final void Function(StoreSummary store) onMarkerTap;
  final Map<String, StoreSummary> annotationStoreMap;

  StoreMarkerClickListener({
    required this.onMarkerTap,
    required this.annotationStoreMap,
  });

  @override
  bool onPointAnnotationClick(PointAnnotation annotation) {
    final store = annotationStoreMap[annotation.id];
    if (store != null) {
      onMarkerTap(store);
      return true;
    }
    return false;
  }
}
