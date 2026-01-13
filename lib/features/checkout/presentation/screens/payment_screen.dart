import 'package:daily_good/core/widgets/dismiss_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/platform/platform_widgets.dart';
import '../../../../core/platform/toasts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../cart/domain/providers/cart_provider.dart';
import '../../../cart/domain/models/cart_item.dart'; // varsa, yoksa doğru yolu kullan
import '../../../orders/data/models/create_order_request.dart';
import '../../../orders/data/repository/order_repository.dart';
import '../widgets/credit_card_form.dart';
import '../widgets/credit_card_helpers.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  bool _isPaymentSuccessful = false;

  // UI için sahte kart alanları (backend'e göndermiyoruz şimdilik)
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  String? orderNote;

  @override
  void initState() {
    super.initState();
    // BuildContext hazır olduğunda extra'yı okuyalım
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      if (extra != null && extra.containsKey('note')) {
        setState(() {
          orderNote = extra['note'];
        });
      }
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);

  // ✅ DÜZELTME: Eğer ödeme başarılıysa, sepet boş olsa bile bu bloğa girme
  if (cartItems.isEmpty && !_isPaymentSuccessful) {
    return Scaffold(
      appBar: AppBar(
        // 🚀 MERKEZİ TEMADAN TÜM AYARLARI ÇEK
        backgroundColor: AppTheme.greenAppBarTheme.backgroundColor,
        foregroundColor: AppTheme.greenAppBarTheme.foregroundColor,
        systemOverlayStyle: AppTheme.greenAppBarTheme.systemOverlayStyle, // Şebeke ve saati beyaz yapar
        iconTheme: AppTheme.greenAppBarTheme.iconTheme, // Geri butonu rengini beyaz yapar
        titleTextStyle: AppTheme.greenAppBarTheme.titleTextStyle, // Başlık fontunu standartlaştırır
        centerTitle: AppTheme.greenAppBarTheme.centerTitle,

        title: const Text('Ödeme'),
      ),
      body: const Center(child: Text('Sepetiniz boş.')),
    );
  }

  // Ödeme başarılıysa ve yönlendirme bekleniyorsa sadece yükleniyor göster
  // veya mevcut ekranın kalmasını sağla
  if (_isPaymentSuccessful) {
    return Scaffold(
      backgroundColor: AppColors.primaryDarkGreen,
      body: Center(
        child: PlatformWidgets.loader(color: Colors.white), // 🚀 'const' kaldırıldı
      ),
    );
  }

    final totalAmount = _calculateTotal(cartItems);

    return DismissKeyboard(
      child: Scaffold(
        appBar: AppBar(
          // 🚀 TÜM AYARLARI MERKEZİ TEMADAN PAKET OLARAK ÇEK
          backgroundColor: AppTheme.greenAppBarTheme.backgroundColor,
          foregroundColor: AppTheme.greenAppBarTheme.foregroundColor,
          systemOverlayStyle: AppTheme.greenAppBarTheme.systemOverlayStyle, // Şebeke, pil ve saati bembeyaz yapar
          iconTheme: AppTheme.greenAppBarTheme.iconTheme, // Geri butonu rengini beyaz yapar
          titleTextStyle: AppTheme.greenAppBarTheme.titleTextStyle, // Font boyutu ve kalınlığını standartlaştırır
          centerTitle: AppTheme.greenAppBarTheme.centerTitle,

          title: const Text('Ödeme'),
        ),
        backgroundColor: Colors.grey.shade100,
      
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            children: [
              // _buildSummaryCard(totalAmount),
              const SizedBox(height: 25),
              _buildCardPreview(),
              const SizedBox(height: 25),
              _buildFormFields(),
            ],
          ),
        ),
      
        // 🔥 ESKİ VE DOĞRU CTA BURAYA
        bottomNavigationBar: SafeArea(
          child: Padding(
            // Sadece yatayda 16, altta 8-12 arası ekstra bir boşluk yeterli olacaktır
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: CustomButton(
              text: _isProcessing ? 'İşlem yapılıyor...' : 'Ödemeyi Tamamla',
              price: totalAmount,
              showPrice: true,
              onPressed: _isProcessing
                  ? () {}
                  : () => _onPayPressed(cartItems, totalAmount),
            ),
          ),
        ),
      
      ),
    );

  }

  double _calculateTotal(List<CartItem> items) {
    return items.fold<double>(
      0,
          (sum, e) => sum + (e.price * e.quantity),
    );
  }


  Future<String?> _createOrderAsync(
      List<CartItem> cartItems,
      double totalAmount,
      ) async {
    final repo = ref.read(orderRepositoryProvider);

    final rawCardNumber = _cardNumberController.text.replaceAll(' ', '');
    final last4 = rawCardNumber.length >= 4
        ? rawCardNumber.substring(rawCardNumber.length - 4)
        : "****";

    final storeId = cartItems.first.shopId;

    final request = CreateOrderRequest(
      storeId: storeId,
      totalAmount: totalAmount,
      paymentMethod: 'credit_card',
      paymentData: {
        "card_last4": last4,
        "card_holder": _cardNameController.text.trim(),
      },
      items: cartItems.map((c) => CreateOrderItemRequest(
        productId: c.productId,
        quantity: c.quantity,
        unitPrice: c.price,
        totalPrice: c.price * c.quantity,
        notes: (orderNote?.trim().isNotEmpty ?? false)
            ? orderNote!.trim()
            : null,
      )).toList(),
    );

    final order = await repo.createOrder(request);
    return order.id.toString();
  }


  Future<void> _onPayPressed(
      List<CartItem> cartItems,
      double totalAmount,
      ) async {
    if (!_formKey.currentState!.validate()) return;

    if (cartItems.isEmpty) {
      Toasts.error(context, 'Sepetiniz boş olduğu için işleme devam edilemez.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _isPaymentSuccessful = true; // 🔥 ÖNCE UI kilitlenir
    });

    try {
      final orderId = await _createOrderAsync(cartItems, totalAmount);
      if (!mounted || orderId == null) return;

      // 🔥 Navigation ÖNCE
      context.go('/order-success?id=$orderId');

      // 🔥 Sepeti SONRA temizle (UI artık bu screen’de değil)
      Future.microtask(() {
        ref.read(cartProvider.notifier).clearCart();
      });

    } catch (e) {
      if (!mounted) return;

      setState(() => _isPaymentSuccessful = false);
      HapticFeedback.heavyImpact();

      Toasts.error(context, 'Ödeme işlemi sırasında bir hata oluştu.');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }






  Widget _buildCardPreview() {
    return Container(
      height: 190,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLightGreen,
            AppColors.primaryDarkGreen
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _cardNumberController.text.isEmpty
                ? '••••   ••••   ••••   ••••'
                : formatCardNumberForPreview(_cardNumberController.text),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _cardNameController.text.isEmpty
                    ? 'CARD HOLDER'
                    : _cardNameController.text.toUpperCase(),
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                _expiryController.text.isEmpty
                    ? 'MM/YY'
                    : _expiryController.text,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Form(
      key: _formKey,
      child: CreditCardForm(
        holder: _cardNameController,
        number: _cardNumberController,
        expiry: _expiryController,
        cvv: _cvvController,
        onChanged: () => setState(() {}),
      ),
    );
  }
}
