import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/cart_item.dart';

final cartProvider = StateNotifierProvider<CartController, List<CartItem>>(
      (ref) => CartController(),
);

class CartController extends StateNotifier<List<CartItem>> {
  CartController() : super([]);

  void addItem(CartItem newItem) {
    // Aynı işletmeden mi?
    final isSameShop = state.isEmpty || state.first.shopId == newItem.shopId;

    if (isSameShop) {
      state = [...state, newItem];
    }
  }

  void replaceWithNewItem(CartItem newItem) {
    state = [newItem];
  }

  String? currentShopId() {
    return state.isEmpty ? null : state.first.shopId;
  }

  void clearCart() {
    state = [];
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}
