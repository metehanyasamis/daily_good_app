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

  String? currentShopId;

  Future<void> loadCart() async {
    final items = await _repo.getCart();
    state = items;
    currentShopId = items.isNotEmpty ? items.first.shopId : null;
  }

  bool isSameStore(String shopId) {
    return currentShopId == null || currentShopId == shopId;
  }

  Future<bool> addProduct(ProductModel product, int qty) async {
    final ok = await _repo.add(
      productId: product.id,
      quantity: qty,
    );

    if (!ok) return false;

    await loadCart();
    return true;
  }

  Future<void> increment(CartItem item) async {
    await _repo.updateQuantity(
      cartItemId: item.cartItemId,
      productId: item.productId,
      quantity: item.quantity + 1,
    );
    await loadCart();
  }

  Future<void> decrement(CartItem item) async {
    if (item.quantity - 1 <= 0) {
      await _repo.remove(item.cartItemId);
    } else {
      await _repo.updateQuantity(
        cartItemId: item.cartItemId,
        productId: item.productId,
        quantity: item.quantity - 1,
      );
    }
    await loadCart();
  }

  Future<void> clearCart() async {
    for (final item in state) {
      await _repo.remove(item.cartItemId);
    }
    state = [];
    currentShopId = null;
  }

  /// ❌ Farklı işletme → sepeti temizle ve yeni ürünü ekle
  Future<bool> replaceWith(ProductModel product, int qty) async {
    // 🔥 backend sepeti temizlemeden önce local state temizle
    state = [];
    currentShopId = null;

    // sonra yeni ürünü ekle
    return await addProduct(product, qty);
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
