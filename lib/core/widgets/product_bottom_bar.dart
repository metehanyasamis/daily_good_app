import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../features/cart/presentation/widgets/success_dialog.dart';

class ProductBottomBar extends StatelessWidget {
  final int qty;
  final double price;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final Future<bool> Function() onSubmit;
  final bool isDisabled;

  const ProductBottomBar({
    super.key,
    required this.qty,
    required this.price,
    required this.onAdd,
    required this.onRemove,
    required this.onSubmit,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 14, offset: const Offset(0, -2))],
          ),
          child: Row(
            children: [
              _circleBtn(icon: Icons.remove, onTap: onRemove),
              const SizedBox(width: 12),
              Text('$qty', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen)),
              const SizedBox(width: 12),
              _circleBtn(icon: Icons.add, onTap: onAdd),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isDisabled ? null : () async {
                      final ok = await onSubmit();

                      if (ok && context.mounted) {
                        showSuccessDialog(context, '$qty adet ürün sepete eklendi 💚');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      backgroundColor: isDisabled
                          ? Colors.grey.shade400
                          : AppColors.primaryDarkGreen,
                      elevation: isDisabled ? 0 : 6,
                    ),
                    child: Text(
                      isDisabled
                          ? 'Stok Tükendi'
                          : '$qty adet için ${(qty * price).toStringAsFixed(0)} TL',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _circleBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primaryDarkGreen,
            width: 2,
          ),
        ),
        child: Icon(icon, size: 22, color: AppColors.primaryDarkGreen),
      ),
    );
  }

  /*
  void _showSuccessDialog(BuildContext context, int quantity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.primaryDarkGreen, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Sepete Eklendi!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('$quantity adet ürün başarıyla sepete eklendi 💚'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDarkGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Tamam', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
*/
}

