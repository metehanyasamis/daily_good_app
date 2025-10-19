import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/explore_filter_sheet.dart';

enum ExploreViewMode { list, map }

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  ExploreViewMode _viewMode = ExploreViewMode.list;
  ExploreFilterOption _selectedFilter = ExploreFilterOption.recommended;

  // MOCK VERİ: Harita yerine şimdilik listede göstereceğimiz örnek ürünler
  final List<Map<String, dynamic>> _sampleList = [
    {
      'title': 'Vegan Sandviç',
      'shop': 'VGreen Dükkan',
      'price': 55,
      'rating': 4.8,
      'distance': 1.2,
      'image': 'assets/images/sample_food2.jpg',
    },
    {
      'title': 'Çikolatalı Kek',
      'shop': 'Pasta House',
      'price': 30,
      'rating': 4.4,
      'distance': 0.7,
      'image': 'assets/images/sample_food3.jpg',
    },
    {
      'title': 'Pizza Menü',
      'shop': 'Italiano',
      'price': 75,
      'rating': 4.9,
      'distance': 2.3,
      'image': 'assets/images/sample_food4.jpg',
    },
  ];

  // Harita ile ilgili state
  late GoogleMapController _mapController;
  LatLng _initialCameraPos = const LatLng(41.0082, 28.9784); // İstanbul merkez
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Örnek marker ekle
    _markers.add(
      const Marker(
        markerId: MarkerId('shop1'),
        position: LatLng(41.009, 28.979),
        infoWindow: InfoWindow(title: 'Restoran A'),
      ),
    );
    _markers.add(
      const Marker(
        markerId: MarkerId('shop2'),
        position: LatLng(41.007, 28.977),
        infoWindow: InfoWindow(title: 'Kafe B'),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMarkerTap(MarkerId markerId) {
    // Marker’a dokununca alt bilgi kartı aç
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _buildBottomInfoCard(markerId);
      },
    );
  }

  Widget _buildBottomInfoCard(MarkerId markerId) {
    // Örnek statik içerik
    return Container(
      padding: const EdgeInsets.all(16),
      height: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Restoran A', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('2.5 km uzakta'),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('3 paket var', style: TextStyle(color: AppColors.primaryDarkGreen)),
              const Spacer(),
              CustomButton(
                text: 'Görüntüle',
                onPressed: () {
                  // işletme detay sayfasına git
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredList() {
    List<Map<String, dynamic>> sortedList = List.from(_sampleList);

    switch (_selectedFilter) {
      case ExploreFilterOption.recommended:
        sortedList.sort((a, b) => b['rating'].compareTo(a['rating']));
        break;
      case ExploreFilterOption.distance:
        sortedList.sort((a, b) => a['distance'].compareTo(b['distance']));
        break;
      case ExploreFilterOption.price:
        sortedList.sort((a, b) => a['price'].compareTo(b['price']));
        break;
      case ExploreFilterOption.rating:
        sortedList.sort((a, b) => b['rating'].compareTo(a['rating']));
        break;
    }

    return sortedList;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keşfet'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () async {
              final result = await showModalBottomSheet<ExploreFilterOption>(
                context: context,
                isScrollControlled: true,
                builder: (_) => ExploreFilterSheet(
                  selected: _selectedFilter,
                  onApply: (selected) {
                    setState(() {
                      _selectedFilter = selected;
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Toggle View Mode
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Liste'),
                  selected: _viewMode == ExploreViewMode.list,
                  onSelected: (sel) {
                    setState(() {
                      _viewMode = ExploreViewMode.list;
                    });
                  },
                ),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('Harita'),
                  selected: _viewMode == ExploreViewMode.map,
                  onSelected: (sel) {
                    setState(() {
                      _viewMode = ExploreViewMode.map;
                    });
                  },
                ),
              ],
            ),
          ),

          // Sıralama butonları (örneğin row içinde)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Sırala:', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: 'Mesafeye göre',
                  items: <String>['Mesafeye göre', 'Puan', 'Fiyata göre']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    // sıralama değişimi
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // İçerik
          Expanded(
            child: _viewMode == ExploreViewMode.list
                ? _buildListView()
                : _buildMapView(),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    // Örnek statik ürün listesi
    final sampleList = [
      {
        'title': 'Vegan Sandviç',
        'shop': 'VGreen Dükkan',
        'price': '55,00 ₺',
        'distance': '1.2 km',
        'image': 'assets/images/sample_food2.jpg',
      },
      {
        'title': 'Çikolatalı Kek',
        'shop': 'Pasta House',
        'price': '30,00 ₺',
        'distance': '0.7 km',
        'image': 'assets/images/sample_food2.jpg',
      },
    ];

    return ListView.builder(
      itemCount: sampleList.length,
      itemBuilder: (ctx, i) {
        final item = sampleList[i];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(item['image']!, width: 60, height: 60, fit: BoxFit.cover),
          ),
          title: Text(item['title']!),
          subtitle: Text('${item['shop']} • ${item['distance']}'),
          trailing: Text(item['price']!, style: TextStyle(color: AppColors.primaryDarkGreen)),
          onTap: () {
            // detay sayfasına geç
          },
        );
      },
    );
  }

  Widget _buildMapView() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _initialCameraPos,
        zoom: 14,
      ),
      onMapCreated: _onMapCreated,
      markers: _markers.map((m) {
        return m.copyWith(
          onTapParam: () {
            _onMarkerTap(m.markerId);
          },
        );
      }).toSet(),
    );
  }
}
