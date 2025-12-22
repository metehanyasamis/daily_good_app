// lib/features/cart/presentation/screens/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/know_more_full.dart';

import '../../../../core/widgets/navigation_link.dart';
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
  bool _isAgreed = true;

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

    return GestureDetector(
      onTap: () => _focusNode.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primaryDarkGreen,
          title: const Text(
            'Sepetim',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
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
                  await ref.read(cartProvider.notifier).clearCart();
                }
              },
            ),
          ],
        ),
        body: items.isEmpty
            ? const Center(child: Text("Sepetiniz boş"))
            : CustomScrollView(
          slivers: [
            // 🧺 Sepet Kartı (ESKİ UX)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _CartCard(
                  items: items,
                  ref: ref,
                ),
              ),
            ),

            // ℹ️ Bilgilendirme kutusu (Bilmeniz gerekenler)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: KnowMoreFull(forceBoxMode: true),
              ),
            ),

            // 📝 Sipariş notu
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _NoteField(
                  controller: _noteController,
                  focusNode: _focusNode,
                ),
              ),
            ),

            // 💰 Toplam kutusu
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _TotalBox(
                  total: total,
                  items: items,
                ),
              ),
            ),

            // 🔥 SÖZLEŞME ONAY ALANI (Yeni eklendi)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _ContractCheckbox(
                  value: _isAgreed,
                  onChanged: (val) {
                    setState(() {
                      _isAgreed = val ?? false;
                    });
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 50)),
          ],
        ),

        // ✅ Altta sabit CTA (ESKİ UX)
        bottomNavigationBar: items.isEmpty
            ? null
            : Padding(
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            text: "Sepeti Onayla",
            price: total,
            showPrice: true,
            onPressed: () {
              if (!_isAgreed) {
                // 🔔 Kullanıcıya uyarıyı burada çakıyoruz
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Devam etmek için sözleşmeleri onaylamalısınız."),
                    backgroundColor: Colors.redAccent,
                    duration: Duration(seconds: 2),
                  ),
                );
                return; // Fonksiyondan çık, ödeme sayfasına gitme
              }

              // Tik varsa ödemeye devam et
              context.push('/payment', extra: total);
            },
          ),
        ),
      ),
    );
  }
}


// ---------------------------------------------------------------------------
// 🧺 Sözleşme Onay Kutusu
// ---------------------------------------------------------------------------

class _ContractCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _ContractCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryDarkGreen, // Seçiliyken iç dolgu rengi
            checkColor: Colors.white, // İçindeki tik işareti rengi

            // 🔥 Siyah çerçeveyi kaldıran/hafifleten kısım:
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              // Buraya URL açma mantığı gelecek (şimdilik debugPrint)
              debugPrint("Sözleşme detayları açılacak...");
            },
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                children: [
                  TextSpan(
                    text: "Ön Bilgilendirme Formu ",
                    style: TextStyle(color: AppColors.primaryDarkGreen, fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: "ve "),
                  TextSpan(
                    text: "Mesafeli Satış Sözleşmesi",
                    style: TextStyle(color: AppColors.primaryDarkGreen, fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: "'ni okudum ve kabul ediyorum."),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 🧺 Sepet Kartı (Teslim alma bilgileri + Sepet özeti)
// ---------------------------------------------------------------------------
class _CartCard extends StatelessWidget {
  final List<CartItem> items;
  final WidgetRef ref;

  const _CartCard({
    required this.items,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final storeName = items.first.shopName; // domain’den geliyor (backend store.name)
    final logo = items.first.image; // domain’de brand.logo
    final logoRaw = logo; // items.first.image or wherever logo comes from
    final logoUrl = sanitizeImageUrl(logoRaw);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryDarkGreen.withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Teslim alma bilgileri",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),

          // Mağaza satırı (domain’de address yoksa sadece isim + link text gösteriyoruz)
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
                  child: logoUrl == null
                      ? const Icon(Icons.store, size: 28)
                      : Image.network(
                    logoUrl,
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: SizedBox(width:16, height:16, child: CircularProgressIndicator(strokeWidth:2)));
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.store, size: 28);
                    },
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    NavigationLink(
                  address: items.first.shopAddress,
                  latitude: items.first.shopLatitude,
                  longitude: items.first.shopLongitude,
                  label: items.first.shopName,

                  // 👇 TEXT AYNI KALDI
                  textStyle: const TextStyle(
                    color: AppColors.primaryDarkGreen,
                    decoration: TextDecoration.underline,
                    fontSize: 13,
                  ),
                ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black54),
            ],
          ),

          const Divider(height: 24),

          const Text(
            "Sepet özeti",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          ...items.map((item) => _CartItemRow(item: item)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 🧺 Sepet Satırı
// ---------------------------------------------------------------------------
class _CartItemRow extends ConsumerWidget {
  final CartItem item;
  const _CartItemRow({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(cartProvider.notifier);

    final oldUnit = item.originalPrice;
    final newUnit = item.price;
    final lineTotal = newUnit * item.quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // SOL: Ürün adı + fiyatlar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
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
                    const SizedBox(width: 6),
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

          // ADET kontrol
          _QtyControl(
            quantity: item.quantity,
            onDecrement: () => ctrl.decrement(item),
            onIncrement: () => ctrl.increment(item),
          ),

          // SAĞ: satır toplam
          SizedBox(
            width: 80,
            child: Text(
              "${lineTotal.toStringAsFixed(2)} ₺",
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ➕➖ Adet Kontrol
// ---------------------------------------------------------------------------
class _QtyControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QtyControl({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onDecrement,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.remove, size: 18),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            "$quantity",
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        InkWell(
          onTap: onIncrement,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.add, size: 18),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 📝 Not alanı
// ---------------------------------------------------------------------------
class _NoteField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const _NoteField({
    required this.controller,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: 3,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Sipariş notu (opsiyonel)",
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 💰 Toplam kutusu
// ---------------------------------------------------------------------------
class _TotalBox extends StatelessWidget {
  final double total;
  final List<CartItem> items;

  const _TotalBox({
    required this.total,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final originalSum = items.fold<double>(
      0,
          (sum, e) => sum + (e.originalPrice * e.quantity),
    );
    final savings = (originalSum - total).clamp(0, double.infinity);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _row("Ara toplam", "${originalSum.toStringAsFixed(2)} ₺",
              valueStyle: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          _row("Tasarruf", "-${savings.toStringAsFixed(2)} ₺",
              valueStyle: const TextStyle(
                color: AppColors.primaryDarkGreen,
                fontWeight: FontWeight.w700,
              )),
          const Divider(height: 24),
          _row(
            "Toplam",
            "${total.toStringAsFixed(2)} ₺",
            valueStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        Text(value, style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 🧹 Sepeti temizle onayı
// ---------------------------------------------------------------------------
Future<bool?> _showConfirmDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Sepeti temizle"),
      content: const Text("Sepetindeki tüm ürünleri silmek istiyor musun?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Vazgeç"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Sil"),
        ),
      ],
    ),
  );
}
