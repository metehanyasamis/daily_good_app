import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../cart/domain/providers/cart_provider.dart';
import '../../../cart/domain/models/cart_item.dart'; // varsa, yoksa doğru yolu kullan
import '../../../orders/data/models/create_order_request.dart';
import '../../../orders/data/models/order_details_response.dart';
import '../../../orders/data/repository/order_repository.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  // UI için sahte kart alanları (backend'e göndermiyoruz şimdilik)
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

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
    final cartItems = ref.watch(cartProvider); // List<CartItem>

    if (cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryDarkGreen,
          title: const Text(
            'Ödeme',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text('Sepetiniz boş.'),
        ),
      );
    }

    final totalAmount = _calculateTotal(cartItems);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDarkGreen,
        title: const Text(
          'Ödeme',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryCard(totalAmount),
            const SizedBox(height: 16),
            _buildCardPreview(),
            const SizedBox(height: 12),
            _buildFormFields(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : () => _onPayPressed(context, cartItems, totalAmount),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDarkGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator.adaptive(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text(
                  'Ödemeyi Tamamla (${totalAmount.toStringAsFixed(2)} ₺)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
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

  Future<void> _onPayPressed(
      BuildContext context,
      List<CartItem> cartItems,
      double totalAmount,
      ) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final repo = ref.read(orderRepositoryProvider);

      // Varsayım: tüm sepet aynı store’dan geliyor → ilk item üzerinden alıyoruz.
      final first = cartItems.first;

      final request = CreateOrderRequest(
        storeId: first.shopId,
        totalAmount: totalAmount,
        paymentMethod: 'credit_card',
        paymentData: {
          // Şimdilik dummy; backend gerek duyana göre doldurulur
          'card_holder': _cardNameController.text,
          'card_last4': _cardNumberController.text.length >= 4
              ? _cardNumberController.text
              .replaceAll(' ', '')
              .substring(_cardNumberController.text.length - 4)
              : '',
        },
        items: cartItems
            .map(
              (c) => CreateOrderItemRequest(
            productId: c.id,
            quantity: c.quantity,
            unitPrice: c.price,
            totalPrice: c.price * c.quantity,
          ),
        )
            .toList(),
      );

      final OrderDetailResponse createdOrder =
      await repo.createOrder(request);

      // İstersen burada OrdersNotifier'a local olarak da ekleyebilirsin,
      // ama ana truth backend olduğu için şart değil.

      if (!mounted) return;

      // Başarılı → animasyonlu ekrana gidiyoruz.
      // Route'unda order id kullanmak istersen extra ile gönderebilirsin.
      context.go('/order-success', extra: createdOrder.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ödeme sırasında bir hata oluştu:\n$e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Widget _buildSummaryCard(double totalAmount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Toplam Tutar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${totalAmount.toStringAsFixed(2)} ₺',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDarkGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDarkGreen, AppColors.primaryDarkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkGreen.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Good Kartı',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 18),
          Text(
            _cardNumberController.text.isEmpty
                ? '**** **** **** ****'
                : _cardNumberController.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _cardNameController.text.isEmpty
                    ? 'KART SAHİBİ'
                    : _cardNameController.text,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              Text(
                _expiryController.text.isEmpty
                    ? 'AA/YY'
                    : _expiryController.text,
                style: const TextStyle(color: Colors.white, fontSize: 13),
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
      child: Column(
        children: [
          TextFormField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Kart Numarası',
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.replaceAll(' ', '').length < 12) {
                return 'Geçerli bir kart numarası girin';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cardNameController,
            decoration: const InputDecoration(
              labelText: 'Kart Üzerindeki İsim',
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Kart sahibinin adını girin';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  decoration: const InputDecoration(
                    labelText: 'Son Kullanma (AA/YY)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Zorunlu';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 3) {
                      return 'En az 3 hane';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
