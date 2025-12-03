// lib/features/cart/presentation/screens/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/know_more_full.dart';

import '../../../businessShop/data/model/businessShop_model.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/providers/cart_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _noteController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final business = ref.watch(cartBusinessProvider);

    return GestureDetector(
      onTap: () => _focusNode.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,

        appBar: AppBar(
          backgroundColor: AppColors.primaryDarkGreen,
          title: const Text('Sepetim', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: items.isEmpty
                  ? null
                  : () async {
                final ok = await _showConfirmDialog(context);
                if (ok == true) {
                  // Sepet silme API endpoint'i bekleniyor. Şimdilik sadece UI State'ini temizliyoruz.
                  ref.read(cartProvider.notifier).clearCart();
                }
              },
            ),
          ],
        ),

        body: items.isEmpty
            ? const Center(child: Text("Sepetiniz boş"))
            : CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _CartCard(business: business!, items: items, ref: ref),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: KnowMoreFull(forceBoxMode: true),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _NoteField(
                  controller: _noteController,
                  focusNode: _focusNode,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _TotalBox(total: total, items: items),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),

        bottomNavigationBar: items.isEmpty
            ? null
            : Padding(
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            text: "Sepeti Onayla",
            price: total,
            showPrice: true,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Ödeme ekranına yönlendiriliyor • ${total.toStringAsFixed(2)} ₺',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );

              Future.delayed(const Duration(milliseconds: 800), () {
                context.push('/payment', extra: total);
              });
            },
          ),
        ),
      ),
    );
  }
}

class _CartCard extends StatelessWidget {
  final BusinessModel business;
  final List<CartItem> items;
  final WidgetRef ref;

  const _CartCard({
    required this.business,
    required this.items,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryDarkGreen.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Teslim alma bilgileri",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),

          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryDarkGreen),
                ),
                child: ClipOval(
                  child: Image.asset(
                    business.businessShopLogoImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(business.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(business.address,
                        style: const TextStyle(fontSize: 13)),
                    InkWell(
                      onTap: () => openBusinessMap(business),
                      child: const Text(
                        "Navigasyon için tıklayın 📍",
                        style: TextStyle(
                          color: AppColors.primaryDarkGreen,
                          decoration: TextDecoration.underline,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 24),
          const Text("Sepet özeti",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),

          ...items.map((item) => _CartItemRow(item: item)),
        ],
      ),
    );
  }
}

class _CartItemRow extends ConsumerWidget {
  final CartItem item;
  const _CartItemRow({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(cartProvider.notifier);

    // Stok/Fiyat kontrolü artık Backend'e bırakıldı.
    const maxReached = false;

    final oldUnit = item.originalPrice;
    final newUnit = item.price;
    final double total = newUnit * item.quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // -------------------------
          // SOL TARAF — Ürün adı + fiyatlar
          // -------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      "${oldUnit.toStringAsFixed(2)} ₺",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const Text("  "),
                    Text(
                      "${newUnit.toStringAsFixed(2)} ₺",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // -------------------------
          // ADET KONTROLÜ
          // -------------------------
          _QtyControl(
            quantity: item.quantity,
            maxReached: maxReached,
            onDecrement: () => ctrl.decrement(item.id),
            onIncrement: () => ctrl.increment(item.id),
          ),

          // -------------------------
          // TOPLAM TUTAR
          // -------------------------
          SizedBox(
            width: 70,
            child: Text(
              "${total.toStringAsFixed(2)} ₺",
              textAlign: TextAlign.end,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool maxReached;

  const _QtyControl({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.maxReached,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primaryDarkGreen),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _icon(Icons.remove, onDecrement, false),
          Text('$quantity',
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          _icon(Icons.add, onIncrement, maxReached),
        ],
      ),
    );
  }

  Widget _icon(IconData icon, VoidCallback onTap, bool disabled) {
    return InkWell(
      onTap: disabled ? null : onTap,
      child: Icon(icon,
          size: 18,
          color:
          disabled ? Colors.grey.shade400 : AppColors.primaryDarkGreen),
    );
  }
}

class _NoteField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const _NoteField({required this.controller, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: null,
      decoration: InputDecoration(
        hintText: 'Sipariş notunuzu buraya yazabilirsiniz…',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }
}

class _TotalBox extends StatelessWidget {
  final double total;
  final List<CartItem> items;

  const _TotalBox({required this.total, required this.items});

  @override
  Widget build(BuildContext context) {
    // Toplam orijinal fiyatı hesaplamak için CartItem modelinden gelen veriyi kullanıyoruz.
    final double original = items.fold(
      0,
          (sum, e) => sum + (e.originalPrice * e.quantity),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(14),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Toplam (vergiler dahil)",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const Divider(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Toplam"),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${total.toStringAsFixed(2)} ₺",
                    style: const TextStyle(
                        color: AppColors.primaryDarkGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  Text(
                    "${original.toStringAsFixed(2)} ₺",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

Future<bool?> _showConfirmDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Emin misiniz?"),
      content: const Text(
        "Sepeti boşaltmak üzeresiniz. Bu seçim kurtarılabilecek bir yemeğin çöpe gitmesi anlamına gelebilir.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Vazgeç"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Evet, boşalt"),
        ),
      ],
    ),
  );
}

// openBusinessMap metodu, muhtemelen core/utils/navigation_utils.dart dosyasından gelmektedir.