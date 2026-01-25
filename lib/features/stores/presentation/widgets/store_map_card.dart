import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';

class StoreMapCard extends StatefulWidget {
  final String storeId;
  final double latitude;
  final double longitude;
  final String address;

  const StoreMapCard({
    super.key,
    required this.storeId,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  State<StoreMapCard> createState() => _StoreMapCardState();
}

class _StoreMapCardState extends State<StoreMapCard> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    if (widget.latitude == 0 || widget.longitude == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Konum",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 220,
              child: MapWidget(
                key: ValueKey(
                  "store-map-${widget.storeId}-${widget.latitude}-${widget.longitude}",
                ),

                // 🔥 Dünya haritasını ÖNLEYEN KISIM
                cameraOptions: CameraOptions(
                  center: Point(
                    coordinates: Position(
                      widget.longitude,
                      widget.latitude,
                    ),
                  ),
                  zoom: 15,
                ),

                onMapCreated: (mapboxMap) async {
                  if (_initialized) return;
                  _initialized = true;

                  debugPrint(
                    "🗺️ MAP INIT → "
                        "store=${widget.storeId} "
                        "lat=${widget.latitude} "
                        "lng=${widget.longitude}",
                  );

                  await mapboxMap.loadStyleURI(
                    MapboxStyles.MAPBOX_STREETS,
                  );

                  final manager = await mapboxMap.annotations
                      .createPointAnnotationManager();
                  await manager.deleteAll();

                  final data = await rootBundle
                      .load('assets/icons/store_marker.png');
                  final bytes = data.buffer.asUint8List();

                  await manager.create(
                    PointAnnotationOptions(
                      geometry: Point(
                        coordinates: Position(
                          widget.longitude,
                          widget.latitude,
                        ),
                      ),
                      image: bytes,
                      iconSize: 0.22,
                      iconAnchor: IconAnchor.CENTER,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.primaryDarkGreen,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.address,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
