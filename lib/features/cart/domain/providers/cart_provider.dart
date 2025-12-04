import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../data/repository/cart_repository.dart';
import '../models/cart_item.dart';
import '../../../product/data/models/product_model.dart';

final cartRepositoryProvider = Provider((ref) {
  return CartRepository(ref.watch(dioProvider));
});

class CartController extends StateNotifier<List<CartItem>> {
  final CartRepository _repo;

  CartController(this._repo) : super(const []) {
    loadCart();
  }

  void clearCart() {
    state = [];
  }

  String? currentShopId;

  Future<void> loadCart() async {
    final items = await _repo.getCart();
    state = items;

    if (items.isNotEmpty) {
      currentShopId = items.first.shopId;
    }
  }



  /// ADIM 1: Aynı işletmeden mi?
  bool isSameStore(String shopId) {
    return currentShopId == null || currentShopId == shopId;
  }

  /// ADIM 2: Sepete ekle (API + UI State)
  Future<bool> addProduct(ProductModel product, int qty) async {
    final shopId = product.store.id;

    // API çağrısı
    final ok = await _repo.addOrUpdate(
      productId: product.id,
      quantity: qty,
    );

    if (!ok) return false;

    // API’den güncel state çek
    await loadCart();
    currentShopId = shopId;
    return true;
  }

  /// ADIM 3: Replace (farklı mağaza)
  Future<bool> replaceWith(ProductModel product, int qty) async {
    state = [];

    final ok = await addProduct(product, qty);
    return ok;
  }

  /// Artır
  Future<void> increment(String id) async {
    final item = state.firstWhere((e) => e.id == id);
    await _repo.addOrUpdate(productId: id, quantity: item.quantity + 1);
    await loadCart();
  }

  /// Azalt
  Future<void> decrement(String id) async {
    final item = state.firstWhere((e) => e.id == id);

    if (item.quantity - 1 <= 0) {
      state = state.where((e) => e.id != id).toList();
      return;
    }

    await _repo.addOrUpdate(productId: id, quantity: item.quantity - 1);
    await loadCart();
  }

  void clear() {
    state = [];
    currentShopId = null;
  }
}

final cartProvider =
StateNotifierProvider<CartController, List<CartItem>>((ref) {
  return CartController(ref.watch(cartRepositoryProvider));
});

final cartTotalProvider = Provider<double>((ref) {
  final list = ref.watch(cartProvider);
  return list.fold(0, (sum, e) => sum + e.quantity * e.price);
});

final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold(0, (sum, e) => sum + e.quantity);
});
