import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_toast.dart';
import '../../../../core/widgets/know_more_full.dart';
import '../../../product/data/mock/mock_product_model.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/providers/cart_provider.dart';


class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider); // 🔹 her değişiklikte otomatik güncellenir
    final business = ref.watch(cartBusinessProvider);

    return Scaffold(
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
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (business != null) _DeliveryCard(business: business),
            const SizedBox(height: 16),

            const Text("Sepet Özeti",
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // 🔹 Ürün Listesi
            ...items.map((item) => _CartItemTile(item: item)),

            const SizedBox(height: 16),
            const KnowMoreFull(),
            const SizedBox(height: 16),
            _NoteField(),
            const SizedBox(height: 16),

            // 🔹 Güncel toplam (dinamik)
            _TotalBox(total: total),
          ],
        ),
      ),

      // 🔹 Alt buton (toplam fiyatla senkron)
      bottomNavigationBar: items.isNotEmpty
          ? _BottomBar(
        total: total,
        onSubmit: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Ödeme ekranına yönlendirilecek • Toplam: ${total.toStringAsFixed(2)} ₺'),
            ),
          );
        },
      )
          : null,
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final dynamic business;
  const _DeliveryCard({required this.business});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              business.businessShopLogoImage,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(business.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(business.address,
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(cartProvider.notifier);

    // 🔹 stok limitini bul ("Son 3" -> 3)
    final product = findProductByName(item.name);
    int maxQty = 99;
    if (product != null) {
      final match = RegExp(r'\d+').firstMatch(product.stockLabel);
      if (match != null) maxQty = int.parse(match.group(0)!);
    }

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => ctrl.removeItem(item.id),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => ctrl.decrement(item.id),
                  icon: const Icon(Icons.remove_circle_outline),
                ),

                Text(
                  '${item.quantity}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                IconButton(
                  onPressed: () {
                    if (item.quantity < maxQty) {
                      ctrl.increment(item.id, maxQty: maxQty);
                    } else {
                      // 🔔 stok limiti uyarısı
                      showAnimatedToast(
                        context,
                        'Stokta yalnızca $maxQty adet var ⚠️',
                        backgroundColor: Colors.orange.shade700,
                      );
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  color: item.quantity < maxQty
                      ? Colors.black
                      : Colors.grey.shade400,
                ),
              ],
            ),
            const SizedBox(width: 8),
            Text('${(item.price * item.quantity).toStringAsFixed(2)} ₺'),
          ],
        ),
      ),
    );
  }
}

class _InfoExpandable extends StatefulWidget {
  const _InfoExpandable();
  @override
  State<_InfoExpandable> createState() => _InfoExpandableState();
}

class _InfoExpandableState extends State<_InfoExpandable> {
  bool expanded = false;

  static const _text = '''
🔔 Mobil Alım ve Teslimat Kuralları
📱 Mobil Alım Zorunluluğu: Bu indirimler sadece mobil uygulama üzerinden yapılan alımlarda geçerlidir. Direkt mağazadan alımlarda bu indirim uygulanmamaktadır.
⏰ Teslimat Saat Aralığı: Ürünü, siparişinizde belirtilen saat aralığında mağazadan teslim alabilirsiniz.
↩️ İptal Hakkı: Teslim alma zamanına 3 saate kadar iptal hakkınız bulunmaktadır.
❌ Teslim Almama: Belirtilen zamanda alınmayan ürün iade edilmez.
''';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Stack(
        children: [
          AnimatedCrossFade(
            firstChild: _clip(_text),
            secondChild: Text(_text,
                style: TextStyle(color: Colors.grey.shade800, height: 1.35)),
            crossFadeState:
            expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              onPressed: () => setState(() => expanded = !expanded),
              icon: Icon(
                expanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                color: AppColors.primaryDarkGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _clip(String text) => ShaderMask(
    shaderCallback: (r) => const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.black, Colors.black, Colors.black54, Colors.transparent],
      stops: [0.0, 0.75, 0.9, 1.0],
    ).createShader(r),
    blendMode: BlendMode.dstIn,
    child: Text(text,
        maxLines: 5,
        overflow: TextOverflow.fade,
        style: const TextStyle(height: 1.35)),
  );
}

class _NoteField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Sipariş notunuzu buraya ekleyebilirsiniz',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      maxLines: 3,
    );
  }
}

class _TotalBox extends StatelessWidget {
  final double total;
  const _TotalBox({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Toplam",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(
            "${total.toStringAsFixed(2)} ₺",
            style: const TextStyle(
              color: AppColors.primaryDarkGreen,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final double total;
  final VoidCallback onSubmit;
  const _BottomBar({required this.total, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDarkGreen,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          'Sepeti Onayla  •  ${total.toStringAsFixed(2)} ₺',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
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
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç')),
        ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Evet, İptal Et')),
      ],
    ),
  );
}
