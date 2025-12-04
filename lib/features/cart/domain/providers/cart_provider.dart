import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../businessShop/data/model/businessShop_model.dart';
import '../../../businessShop/data/mock/mock_businessShop_model.dart';
import '../../../product/data/models/product_model.dart';
import '../../data/repository/cart_repository.dart';
import '../models/cart_item.dart';

// --- API KATMANI PROVIDER'LARI ---

/// 🔹 Dio bağımlılığını enjekte eden Repository Provider
final cartRepositoryProvider = Provider((ref) {
  return CartRepository(ref.watch(dioProvider));
});


// --- STATE NOTIFIER VE BUSINESS LOGIC ---

/// 🔹 Sepet kontrolcüsü
class CartController extends StateNotifier<List<CartItem>> {
  final CartRepository _repository;

  // 🔥 Yeni Eklendi: Sepetle ilişkili işletme bilgisi (API'den gelmeli ama şimdilik state'te tutuluyor)
  String? _currentShopId;
  String? _currentShopName;
  String? _currentShopImage;

  CartController(this._repository) : super(const []) {
    debugPrint('🔄 CartController başlatılıyor. Sepet yükleniyor...');
    fetchCartItems();
  }

  /// 🌐 API'den sepet içeriğini çeker (GET /customer/cart)
  Future<void> fetchCartItems() async {
    try {
      final items = await _repository.getCartItems();
      state = items;
      debugPrint('✅ Sepet State\'i güncellendi. Toplam ${items.length} ürün.');

      // 🔥 Eğer sepet boş değilse, ilk üründen işletme bilgisini çek.
      if (items.isNotEmpty) {
        _currentShopId = items.first.shopId;
        _currentShopName = items.first.shopName;
        // 🚨 Not: API'den cart item çekerken shop image gelmiyorsa bu alan null kalacaktır.
        // Bu bilginin API'den gelmesi idealdir. Şimdilik mockBusinessList'i kullanmaya devam ediyoruz.
        if (_currentShopImage == null) {
          final business = findBusinessById(_currentShopId!);
          _currentShopImage = business?.businessShopLogoImage;
        }
      } else {
        _currentShopId = null;
        _currentShopName = null;
        _currentShopImage = null;
      }

    } catch (e) {
      debugPrint("❌ CartController: Sepet yüklenirken kritik hata oluştu: $e");
    }
  }

  /// Aktif işletme kimliği
  String? currentShopId() => _currentShopId;

  /// Aktif işletme modeli (Mock'tan çekmeye devam)
  BusinessModel? get currentBusiness {
    return _currentShopId == null ? null : findBusinessById(_currentShopId!);
  }

  /// 🔥 Yeni Eklendi: İşletme bilgilerini state'te tutar.
  void _saveShopInfo(String shopId, String shopName, String? shopImage) {
    _currentShopId = shopId;
    _currentShopName = shopName;
    // Nullable olanı doğrudan atıyoruz, hata çözüldü.
    _currentShopImage = shopImage;
    debugPrint('ℹ️ İşletme Bilgisi Kaydedildi: ID $shopId, Adı $shopName');
  }


  /// Toplam tutar
  double get total =>
      state.fold(0, (sum, e) => sum + (e.price * e.quantity));

  /// Ürünün sepetteki miktarını döner
  int quantityOf(String id) {
    final ix = state.indexWhere((e) => e.id == id);
    return ix == -1 ? 0 : state[ix].quantity;
  }

  /// 🟢 Ürün ekle (POST /customer/cart/add)
  void addProductFromApi(ProductModel product, String shopId, String shopName, String? shopImage, {required int qty}) {
    final existingItemIndex = state.indexWhere((item) => item.id == product.id);

    // Yeni CartItem oluştururken API modelinin alanlarını kullan
    final newItem = CartItem(
      id: product.id,
      name: product.name,
      shopId: shopId,
      shopName: shopName,
      image: product.imageUrl,
      price: product.salePrice,
      quantity: qty,
      // 🔥 DÜZELTME: oldPrice yerine CartItem modeline uygun olarak originalPrice kullanıldı.
      originalPrice: product.listPrice,
    );

    if (existingItemIndex >= 0) {
      // Mevcutsa miktarı güncelle
      state = [
        for (final item in state)
          if (item.id == product.id) item.copyWith(quantity: item.quantity + qty) else item,
      ];
    } else {
      // Yeni ürün ekle
      state = [...state, newItem];
    }
    _saveShopInfo(shopId, shopName, shopImage);
  }


// 🔥 YENİ METOT: API'den gelen ProductModel ile sepeti değiştirmek için
  void replaceWithApi(ProductModel product, String shopId, String shopName, String? shopImage, {required int qty}) {
    // Yeni CartItem oluştururken API modelinin alanlarını kullan
    final newItem = CartItem(
      id: product.id,
      name: product.name,
      shopId: shopId,
      shopName: shopName,
      image: product.imageUrl,
      price: product.salePrice,
      quantity: qty,
      // 🔥 DÜZELTME: oldPrice yerine CartItem modeline uygun olarak originalPrice kullanıldı.
      originalPrice: product.listPrice,
    );

    state = [newItem]; // Sepeti yeni ürünle değiştir
    _saveShopInfo(shopId, shopName, shopImage);
  }

  /// Ürün miktarını artır (POST /customer/cart/add)
  Future<void> increment(String id) async {
    final ix = state.indexWhere((e) => e.id == id);
    if (ix == -1) return;

    final current = state[ix];
    final newQty = current.quantity + 1;
    debugPrint('➕ Miktar Artırma: Ürün ID: ${current.id}, Yeni Miktar: $newQty');

    try {
      final success = await _repository.addItemToCart(
        productId: current.id,
        quantity: newQty,
      );
      // Başarılı olursa API'den güncel sepeti çek
      if (success) await fetchCartItems();
    } catch (e) {
      debugPrint("❌ Miktar artırma HATA: $e");
      // UI'a hata bildirimi (Snackbar) burada yapılmalı.
    }
  }

  /// Ürün miktarını azalt (POST /customer/cart/add)
  Future<void> decrement(String id) async {
    final ix = state.indexWhere((e) => e.id == id);
    if (ix == -1) return;
    final current = state[ix];
    final newQty = current.quantity - 1;
    debugPrint('➖ Miktar Azaltma: Ürün ID: ${current.id}, Yeni Miktar: $newQty');


    if (newQty <= 0) {
      debugPrint('🗑️ Miktar 0 olduğu için sepetten kaldırılıyor: ${current.id}');
      // Sepet temizleme API çağrısı yapılmalı
      removeItem(id);
      return;
    }

    try {
      final success = await _repository.addItemToCart(
        productId: current.id,
        quantity: newQty,
      );
      // Başarılı olursa API'den güncel sepeti çek
      if (success) await fetchCartItems();
    } catch (e) {
      debugPrint("❌ Miktar azaltma HATA: $e");
    }
  }

  /// Ürünü sil (Frontend State'i) - API endpoint'i bekleniyor
  void removeItem(String id) {
    state = state.where((e) => e.id != id).toList();
    debugPrint('🗑️ Ürün UI State\'inden silindi: ID $id. Yeni ürün sayısı: ${state.length}');

    // Eğer sepet tamamen boşalırsa, işletme bilgisini de temizle
    if (state.isEmpty) {
      _currentShopId = null;
      _currentShopName = null;
      _currentShopImage = null;
      debugPrint('🧹 Sepet boşaldığı için işletme bilgisi temizlendi.');
    }
  }

  /// Sepeti boşalt (Frontend State'i) - API endpoint'i bekleniyor
  void clearCart() {
    state = const [];
    _currentShopId = null;
    _currentShopName = null;
    _currentShopImage = null;
    debugPrint('🧹 Sepet UI State\'i temizlendi.');
  }
}

/// 🔹 Ana provider
final cartProvider = StateNotifierProvider<CartController, List<CartItem>>(
      (ref) => CartController(ref.watch(cartRepositoryProvider)),
);

/// 🔹 Toplam ürün sayısı
final cartCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold<int>(0, (sum, item) => sum + item.quantity);
});

/// 🔹 Toplam fiyat
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + (item.price * item.quantity));
});

/// 🔹 Aktif işletme
final cartBusinessProvider = Provider<BusinessModel?>((ref) {
  final controller = ref.watch(cartProvider.notifier);
  // controller içindeki _currentShopId'ye göre mock listesinden işletmeyi bulur
  return controller.currentBusiness;
});