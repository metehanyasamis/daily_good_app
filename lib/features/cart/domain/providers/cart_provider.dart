import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../businessShop/data/model/businessShop_model.dart';
import '../../../businessShop/data/mock/mock_businessShop_model.dart';
import '../../../product/data/models/product_model.dart';
import '../models/cart_item.dart';

/// 🔹 Sepet kontrolcüsü (aynı işletmeden ürün ekleme kuralı)
class CartController extends StateNotifier<List<CartItem>> {
  CartController() : super(const []);

  /// Aktif işletme kimliği
  String? currentShopId() => state.isEmpty ? null : state.first.shopId;

  /// Aktif işletme modeli
  BusinessModel? get currentBusiness =>
      state.isEmpty ? null : findBusinessById(state.first.shopId);

  /// Toplam tutar
  double get total =>
      state.fold(0, (sum, e) => sum + (e.price * e.quantity));

  // sepet ekranındaki + düğmesine de “kalan stok” sınırı
  int quantityOf(String id) {
    final ix = state.indexWhere((e) => e.id == id);
    return ix == -1 ? 0 : state[ix].quantity;
  }

  /// 🟢 Ürün ekle (aynı ürün varsa miktar artır)
  void addProduct(ProductModel p, BusinessModel shop, {int qty = 1, int? maxQty}) {
    final sameShop = state.isEmpty || currentShopId() == shop.id;
    if (!sameShop) return;

    final ix = state.indexWhere((e) => e.id == p.packageName);
    if (ix == -1) {
      // Yeni ürün
      if (maxQty != null && qty > maxQty) return; // Stok aşımı
      state = [
        ...state,
        CartItem(
          id: p.packageName,
          name: p.packageName,
          shopId: shop.id,
          shopName: shop.name,
          image: p.bannerImage,
          price: p.newPrice,
          quantity: qty,
        ),
      ];
    } else {
      // Zaten sepette varsa
      final item = state[ix];
      final newQty = item.quantity + qty;

      if (maxQty != null && newQty > maxQty) return; // toplam stok sınırını geçme

      final updated = item.copyWith(quantity: newQty);
      state = [...state]..[ix] = updated;
    }
  }


  /// 🔁 Farklı işletme senaryosu: sepet sıfırla ve sadece bu ürünü ekle
  void replaceWith(ProductModel p, BusinessModel shop, {int qty = 1}) {
    state = [
      CartItem(
        id: p.packageName,
        name: p.packageName,
        shopId: shop.id,
        shopName: shop.name,
        image: p.bannerImage,
        price: p.newPrice,
        quantity: qty,
      ),
    ];
  }

  /// Ürün miktarını artır
  void increment(String id, {int? maxQty}) {
    final ix = state.indexWhere((e) => e.id == id);
    if (ix == -1) return;

    final current = state[ix];
    if (maxQty != null && current.quantity >= maxQty) {
      // Stok sınırına ulaşıldı, ekleme yapma
      return;
    }

    final updated = current.copyWith(quantity: current.quantity + 1);
    state = [...state]..[ix] = updated;
  }

  /// Ürün miktarını azalt
  void decrement(String id) {
    final ix = state.indexWhere((e) => e.id == id);
    if (ix == -1) return;
    final q = state[ix].quantity - 1;
    if (q <= 0) {
      removeItem(id);
    } else {
      final updated = state[ix].copyWith(quantity: q);
      state = [...state]..[ix] = updated;
    }
  }

  /// Ürünü sil
  void removeItem(String id) =>
      state = state.where((e) => e.id != id).toList();

  /// Sepeti boşalt
  void clearCart() => state = const [];
}

/// 🔹 Ana provider
final cartProvider = StateNotifierProvider<CartController, List<CartItem>>(
      (ref) => CartController(),
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
  final cart = ref.watch(cartProvider.notifier);
  return cart.currentBusiness;
});
