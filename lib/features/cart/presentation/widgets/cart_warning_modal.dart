import 'package:flutter/material.dart';

Future<bool?> showCartConflictModal(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sepet Uyuşmazlığı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sepetinde farklı bir işletmeden ürün var. Mevcut ürünleri silip bu yeni ürünü eklemek istiyor musun?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Vazgeç'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Devam Et'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
