import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../location/domain/address_state.dart';
import '../../../stores/data/model/store_summary.dart';
import '../map/store_marker_click_listener.dart';

class StoreMarkerLayer extends StatefulWidget {
  final AddressState address;
  final List<StoreSummary> stores;

  final void Function(StoreSummary store) onStoreSelected;
  final VoidCallback onMapTap;

  const StoreMarkerLayer({
    super.key,
    required this.address,
    required this.stores,
    required this.onStoreSelected,
    required this.onMapTap,
  });

  @override
  State<StoreMarkerLayer> createState() => _StoreMarkerLayerState();
}

class _StoreMarkerLayerState extends State<StoreMarkerLayer> {
  MapboxMap? _map;
  PointAnnotationManager? _manager;

  /// markerId -> store
  final Map<String, StoreSummary> _annotationStoreMap = {};

  @override
  void dispose() {
    _manager?.deleteAll();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StoreMarkerLayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    final addressChanged =
        oldWidget.address.lat != widget.address.lat ||
            oldWidget.address.lng != widget.address.lng;

    final storesChanged = oldWidget.stores.length != widget.stores.length;

    if (_map != null && (addressChanged || storesChanged)) {
      _moveCameraToSelectedAddress();
      _refreshMarkers();
    }
  }

  Future<void> _moveCameraToSelectedAddress() async {
    if (_map == null) return;

    await _map!.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(widget.address.lng, widget.address.lat),
        ),
        zoom: 14,
      ),
    );
  }

  Future<void> _ensureManager() async {
    if (_map == null) return;
    _manager ??= await _map!.annotations.createPointAnnotationManager();

    _manager!.addOnPointAnnotationClickListener(
      StoreMarkerClickListener(
        onMarkerTap: widget.onStoreSelected,
        annotationStoreMap: _annotationStoreMap,
      ),
    );
  }

  Future<void> _refreshMarkers() async {
    if (_map == null) return;

    await _ensureManager();
    if (_manager == null) return;

    _annotationStoreMap.clear();
    await _manager!.deleteAll();

    for (final store in widget.stores) {
      if (store.latitude == null || store.longitude == null) continue;

      final annotation = await _manager!.create(
        PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(store.longitude!, store.latitude!),
          ),
          iconImage: "marker-15",
          iconSize: 1.4,
        ),
      );

      _annotationStoreMap[annotation.id] = store;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: MapWidget(
        styleUri: MapboxStyles.MAPBOX_STREETS,
        cameraOptions: CameraOptions(
          center: Point(
            coordinates: Position(widget.address.lng, widget.address.lat),
          ),
          zoom: 14,
        ),
        onMapCreated: (map) async {
          _map = map;
          await _ensureManager();
          await _refreshMarkers();
        },
        onTapListener: (_) => widget.onMapTap(),
      ),
    );
  }
}
