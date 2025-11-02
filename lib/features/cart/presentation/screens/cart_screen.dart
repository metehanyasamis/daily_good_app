import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../core/widgets/animated_toast.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/know_more_full.dart';
import '../../../businessShop/data/model/businessShop_model.dart';
import '../../../checkout/presentation/screens/payment_screen.dart';
import '../../../product/data/mock/mock_product_model.dart';
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
      onTap: () {
        if (_focusNode.hasFocus) _focusNode.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primaryDarkGreen,
          title: const Text('Sepetim', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: items.isEmpty
                  ? null
                  : () async {
                final ok = await _showConfirmDialog(context);
                if (ok == true) ref.read(cartProvider.notifier).clearCart();
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
                child: _NoteField(controller: _noteController, focusNode: _focusNode),
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

        // 🔹 CustomConfirmBar yerine artık CustomButton kullanılıyor
        bottomNavigationBar: items.isNotEmpty
            ? Padding(
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            text: "Sepeti Onayla",
            price: total,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ödeme ekranına yönlendiriliyor • ${total.toStringAsFixed(2)} ₺'),
                  duration: const Duration(seconds: 1),
                ),
              );

              Future.delayed(const Duration(milliseconds: 800), () {
                context.push('/payment', extra: total);
              });
            },
          ),
        )
            : null,
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
          const Text(
            "Teslim alma bilgileri",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.primaryDarkGreen, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
                    Text(business.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(business.address, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                    InkWell(
                      onTap: () => openBusinessMap(business),
                      child: const Text(
                        "Navigasyon yönlendirmesi için tıklayınız 📍",
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

          const Divider(height: 24, thickness: 1),

          const Text("Sepet özeti", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
    final product = findProductByName(item.name);
    int maxQty = 99;

    if (product != null) {
      final match = RegExp(r'\d+').firstMatch(product.stockLabel);
      if (match != null) maxQty = int.parse(match.group(0)!);
    }

    final double oldUnitPrice = product?.oldPrice ?? item.price;
    final double newUnitPrice = item.price;
    final double total = newUnitPrice * item.quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      "${oldUnitPrice.toStringAsFixed(2)} ₺",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const Text(" / "),
                    Text(
                      "${newUnitPrice.toStringAsFixed(2)} ₺",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _QtyControl(
            quantity: item.quantity,
            onDecrement: () => ctrl.decrement(item.id),
            onIncrement: () {
              if (item.quantity < maxQty) {
                ctrl.increment(item.id, maxQty: maxQty);
              } else {
                showAnimatedToast(
                  context,
                  'Stokta yalnızca $maxQty adet var ⚠️',
                  backgroundColor: Colors.orange.shade700,
                );
              }
            },
            maxReached: item.quantity >= maxQty,
          ),
          SizedBox(
            width: 70,
            child: Text(
              "${total.toStringAsFixed(2)} ₺",
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
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
        border: Border.all(color: AppColors.primaryDarkGreen, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildIcon(Icons.remove, onDecrement, false),
          Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          _buildIcon(Icons.add, onIncrement, maxReached),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon, VoidCallback onTap, bool disabled) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: disabled ? null : onTap,
      child: Icon(icon, size: 18, color: disabled ? Colors.grey.shade400 : AppColors.primaryDarkGreen),
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
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration: InputDecoration(
        hintText: 'Sipariş notunuzu buraya ekleyebilirsiniz',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
    final double original = items.fold(
      0,
          (sum, e) => sum + ((findProductByName(e.name)?.oldPrice ?? e.price) * e.quantity),
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
            "Toplam (ücretler ve vergi dahil)",
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
                  Text("${total.toStringAsFixed(2)} ₺",
                      style: const TextStyle(
                        color: AppColors.primaryDarkGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )),
                  Text("${original.toStringAsFixed(2)} ₺",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      )),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

Future<bool?> _showConfirmDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Emin misin?'),
      content: const Text(
          'Sepeti boşaltmak üzeresin. Bu seçim, kurtarılabilecek bir yemeğin çöpe gitmesi anlamına gelebilir.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Evet, İptal Et')),
      ],
    ),
  );
}
