import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../orders/data/mock_orders.dart';
import '../../../orders/providers/order_provider.dart';
import '../../domain/models/paymet_request.dart';
import '../../domain/providers/payment_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final double amount;
  const PaymentScreen({super.key, required this.amount});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _holderCtrl = TextEditingController();
  final TextEditingController _numberCtrl = TextEditingController();
  final TextEditingController _expiryCtrl = TextEditingController();
  final TextEditingController _cvvCtrl = TextEditingController();

  @override
  void dispose() {
    _holderCtrl.dispose();
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose(); // ✅ sadece bu kalsın
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final request = PaymentRequest(
      holderName: _holderCtrl.text,
      cardNumber: _numberCtrl.text,
      expiry: _expiryCtrl.text,
      cvv: _cvvCtrl.text,
      amount: widget.amount,
    );

    final notifier = ref.read(paymentProvider.notifier);
    await notifier.makePayment(
      holder: request.holderName,
      number: request.cardNumber,
      expiry: request.expiry,
      cvv: request.cvv,
      amount: request.amount,
    );

    // ✅ ödeme başarılı → siparişleri oluştur ve provider’a ekle
    final ordersNotifier = ref.read(ordersProvider.notifier);
    for (final order in mockOrders) {
      ordersNotifier.addOrder(order);
    }

    // ✅ animasyonlu geçiş ekranına yönlendir
    if (mounted) {
      context.go('/order-success');
    }
  }


  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final isLoading = paymentState is AsyncLoading;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        appBar: AppBar(
          backgroundColor: AppColors.primaryDarkGreen,
          centerTitle: true,
          title: const Text('Ödeme', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () async {
              // 🔹 herhangi bir alanda veri girilmiş mi kontrol et
              final hasInput = _holderCtrl.text.isNotEmpty ||
                  _numberCtrl.text.isNotEmpty ||
                  _expiryCtrl.text.isNotEmpty ||
                  _cvvCtrl.text.isNotEmpty;

              if (!hasInput) {
                // hiç veri girilmemişse direkt geri dön
                Navigator.pop(context);
                return;
              }

              // 🔹 veri varsa uyarı göster
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('İşlemi iptal etmek istiyor musunuz?'),
                  content: const Text('Girdiğiniz kart bilgileri kaybolacak.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Vazgeç')),
                    ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Evet')),
                  ],
                ),
              );
              if (ok == true) Navigator.pop(context);
            },
          ),
        ),


        // 🔹 body: sadece form
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildCardPreview(),
                    const SizedBox(height: 20),
                    _buildFormFields(),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 🔹 alt kısımda sabit buton
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: CustomButton(
            text: isLoading ? 'İşlem yapılıyor...' : 'Ödemeyi Tamamla',
            price: widget.amount,
            onPressed: isLoading ? () {} : _submit,
            showPrice: true,
          ),
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryLightGreen, AppColors.primaryDarkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // dikey ortalama
        crossAxisAlignment: CrossAxisAlignment.start, // yatay ortalama
        children: [
          Text(
            _numberCtrl.text.isEmpty
                ? '••••   ••••   ••••   ••••'
                : formatCardNumberForPreview(_numberCtrl.text),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _holderCtrl.text.isEmpty
                    ? 'CARD HOLDER'
                    : _holderCtrl.text.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                _expiryCtrl.text.isEmpty ? 'MM/YY' : _expiryCtrl.text,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        TextFormField(
          controller: _holderCtrl,
          decoration: const InputDecoration(labelText: 'Kart Sahibi', filled: true, fillColor: Colors.white),
          validator: (s) => (s ?? '').trim().isEmpty ? 'Kart sahibini girin' : null,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _numberCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            // ✅ Sadece rakam ve boşluk girilebilir
            FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
            // ✅ Maksimum uzunluk: 16 rakam + 3 boşluk
            LengthLimitingTextInputFormatter(19),
          ],
          decoration: const InputDecoration(
            labelText: 'Kart Numarası',
            hintText: '0000 0000 0000 0000',
            counterText: '',
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (s) {
            final v = (s ?? '').replaceAll(' ', '');
            if (v.length != 16) return 'Kart numarası 16 haneli olmalı';
            return null;
          },
          onChanged: (s) {
            final digits = s.replaceAll(' ', '');
            // ✅ Fazla girilirse otomatik kes
            final limited = digits.length > 16 ? digits.substring(0, 16) : digits;
            final newText = _groupIntoChunks(limited, 4).join(' ');
            if (newText != s) {
              _numberCtrl.value = TextEditingValue(
                text: newText,
                selection: TextSelection.collapsed(offset: newText.length),
              );
            }
            setState(() {});
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 6,
              child: TextFormField(
                controller: _expiryCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')), // sadece rakam ve / işareti
                  LengthLimitingTextInputFormatter(5), // MM/YY toplam 5 karakter
                ],
                decoration: const InputDecoration(
                  labelText: 'Son Kullanım Tarihi',
                  hintText: 'MM/YY',
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (s) {
                  final value = s ?? '';
                  if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(value)) {
                    return 'Geçerli tarih girin (AA/YY)';
                  }
                  return null;
                },
                onChanged: (s) {
                  final digits = s.replaceAll('/', '');
                  if (digits.length > 2) {
                    final formatted = digits.substring(0, 2) + '/' + digits.substring(2, digits.length.clamp(2, 4));
                    if (formatted != s) {
                      _expiryCtrl.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  }
                  setState(() {});
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: TextFormField(
                controller: _cvvCtrl,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'CVV/CVC', filled: true, fillColor: Colors.white),
                validator: (s) => (s ?? '').length < 3 ? 'CVV girin' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// helpers
String formatCardNumberForPreview(String raw) {
  final digits = raw.replaceAll(' ', '');
  if (digits.length <= 4) return digits;
  final last4 = digits.substring(digits.length - 4);
  return '•••• •••• •••• $last4';
}

List<String> _groupIntoChunks(String s, int chunk) {
  final List<String> out = [];
  for (var i = 0; i < s.length; i += chunk) {
    out.add(s.substring(i, i + chunk > s.length ? s.length : i + chunk));
  }
  return out;
}
