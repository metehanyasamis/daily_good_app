import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_home_app_bar.dart';
import '../../../businessShop/data/mock/mock_businessShop_model.dart';
import '../../../businessShop/data/model/businessShop_model.dart';
import '../../../businessShop/presentation/widgets/businessShop_details_content.dart';

class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {

  final List<BusinessModel> _sampleBusinessShop = mockBusinessList;
  String? _selectedShopId;

  // Seçilen işletmeyi ID'sine göre BusinessModel listesinden bulur.
  BusinessModel? get _selectedShop {
    if (_selectedShopId == null) return null;

    try {
      // Doğrudan BusinessModel'in id alanını kullanarak arama yapılır.
      return _sampleBusinessShop.firstWhere((s) => s.id == _selectedShopId);
    } catch (e) {
      // Eğer ID bulunamazsa (güvenlik için) null döndürülür.
      return null;
    }
  }

  void _onPinTap(String shopId) {
    setState(() {
      _selectedShopId = shopId;
    });
  }

  void _onCardTap() {
    final business = _selectedShop;

    if (business != null) {
      // Seçilen BusinessModel objesi zaten tüm ürün verilerini içeriyor.

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.55,
          maxChildSize: 0.95,
          minChildSize: 0.3,
          expand: false,
          builder: (_, controller) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              controller: controller,
              // BusinessDetailContent widget'ına BusinessModel objesi doğrudan iletilir.
              child: BusinessDetailContent(businessShop: business),
            ),
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: CustomHomeAppBar(
          address: 'Nail Bey Sok.',
          onLocationTap: () {
            // Lokasyon seçimi
          },
          onNotificationsTap: () {
            // Bildirim ekranı
          },
        ),
      ),
      body: Stack(
        children: [
          // Harita yerine mock görsel
          Positioned.fill(
            child: Image.asset(
              'assets/images/sample_map.png',
              fit: BoxFit.cover,
            ),
          ),

          // Mock pinler (id'lerin mockBusinessList'teki id'ler ile eşleştiğinden emin olun)
          Positioned(
            left: 60,
            top: 220,
            child: GestureDetector(
              onTap: () => _onPinTap('1'), // 'Altın Fırın' id'si
              child: Icon(Icons.location_on, color: AppColors.primaryDarkGreen, size: 36),
            ),
          ),
          Positioned(
            left: 180,
            top: 350,
            child: GestureDetector(
              onTap: () => _onPinTap('2'), // 'VGreen Dükkan' id'si
              child: Icon(Icons.location_on, color: AppColors.primaryDarkGreen, size: 36),
            ),
          ),

          // Arama kutusu
          Positioned(
            top: 8,
            left: 16,
            right: 16,
            child: SafeArea(
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Restoran, paket veya mekan ara',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // Alt kart: pin seçildiğinde göster
          if (_selectedShop != null)
            Positioned(
              bottom: kBottomNavigationBarHeight + 80,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: _onCardTap,
                // BusinessModel objesini _BusinessCard widget'ına iletiyoruz.
                child: _BusinessCard(business: _selectedShop!),
              ),
            ),

          // Liste butonu
          Positioned(
            right: 0,
            bottom: (MediaQuery.of(context).padding.bottom > 0
                ? MediaQuery.of(context).padding.bottom
                : 20) + 80,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDarkGreen,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    topRight: Radius.zero,
                    bottomRight: Radius.zero,
                  ),
                ),
              ),
              onPressed: () {
                // 'go_router' ile listeleme ekranına yönlendirme
                context.push('/explore-list');
              },
              icon: const Icon(Icons.list, color: Colors.white),
              label: const Text(
                'Liste',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Alt kart widget'ı (BusinessModel objesi kullanır)
class _BusinessCard extends StatelessWidget {
  final BusinessModel business;
  const _BusinessCard({required this.business});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // İşletme görseli (image alanı, bu kart için logo yerine kullanıldı)
            CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage(business.businessShopLogoImage),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sınıf üyelerine nokta operatörü ile erişim
                  Text(business.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  // Sınıf üyelerine nokta operatörü ile erişim
                  Text(
                    'Bugün teslim al ${business.workingHours}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 28),
          ],
        ),
      ),
    );
  }
}