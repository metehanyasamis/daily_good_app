import 'package:flutter/material.dart';
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

  /// 🛡️ İşlem devam ederken (temizleme/ekleme) mükerrer istekleri engellemek için kilit
  bool _isProcessing = false;

  Future<void> loadCart() async {
    try {
      final items = await _repo.getCart();
      state = items;
      currentShopId = items.isNotEmpty ? items.first.shopId : null;
    } catch (e) {
      debugPrint("🛒 CartController Load Error: $e");
    }
  }

  bool isSameStore(String shopId) {
    return currentShopId == null || currentShopId == shopId;
  }

  Future<bool> addProduct(ProductModel product, int qty) async {
    if (_isProcessing) return false;
    _isProcessing = true;

    try {
      // 1. Ürün zaten sepette var mı diye bak (null dönebilir)
      CartItem? existingItem;
      try {
        existingItem = state.firstWhere((item) => item.productId == product.id);
      } catch (_) {
        existingItem = null; // Ürün bulunamadıysa hata fırlatır, catch ile null yapıyoruz
      }

      bool ok;
      if (existingItem != null) {
        // 2. ✅ ÜRÜN VARSA: Miktarı güncelle
        ok = await _repo.updateQuantity(
          cartItemId: existingItem.cartItemId,
          productId: product.id,
          quantity: existingItem.quantity + qty,
        );
      } else {
        // 3. 🆕 ÜRÜN YOKSA: Yeni ekle
        ok = await _repo.add(
          productId: product.id,
          quantity: qty,
        );
      }

      if (!ok) return false;

      await loadCart();
      return true;
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> increment(CartItem item) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      await _repo.updateQuantity(
        cartItemId: item.cartItemId,
        productId: item.productId,
        quantity: item.quantity + 1,
      );
      await loadCart();
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> decrement(CartItem item) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
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
    } finally {
      _isProcessing = false;
    }
  }

  /// ✅ Sıralı temizleme yaparak 404 hatalarını engeller
  Future<void> clearCart() async {
    if (_isProcessing || state.isEmpty) return;
    _isProcessing = true;

    try {
      // Önce mevcut öğelerin bir kopyasını alalım
      final itemsToRemove = List<CartItem>.from(state);

      // Local state'i anında temizleyip UI'ı rahatlatalım
      state = [];
      currentShopId = null;

      // Loglardaki çakışmayı önlemek için her silme işlemini sırayla await ediyoruz
      for (final item in itemsToRemove) {
        await _repo.remove(item.cartItemId);
      }
    } catch (e) {
      debugPrint("🛒 Cart Clear Error: $e");
    } finally {
      _isProcessing = false;
      await loadCart(); // Backend ile son kez senkronize ol
    }
  }

  /// ❌ Farklı işletme → sepeti temizle ve yeni ürünü ekle
  Future<bool> replaceWith(ProductModel product, int qty) async {
    if (_isProcessing) return false;

    // Önce backend sepetini güvenli şekilde temizle
    await clearCart();

    // Sonra yeni ürünü ekle (addProduct kendi içinde kilidini açıp kapatacak)
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