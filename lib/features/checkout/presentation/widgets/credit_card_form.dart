import 'package:flutter/material.dart';

class CreditCardForm extends StatelessWidget {
  final TextEditingController holderController;
  final TextEditingController numberController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;
  final VoidCallback onChanged;

  const CreditCardForm({
    super.key,
    required this.holderController,
    required this.numberController,
    required this.expiryController,
    required this.cvvController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: holderController,
          decoration: const InputDecoration(
            labelText: 'Kart Sahibi',
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (v) => (v ?? '').isEmpty ? 'Kart sahibini girin' : null,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: numberController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Kart Numarası',
            hintText: '0000 0000 0000 0000',
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (v) {
            final d = (v ?? '').replaceAll(' ', '');
            if (d.length < 13) return 'Geçerli kart numarası girin';
            return null;
          },
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: expiryController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Son Kullanım',
                  hintText: 'AA/YY',
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) => (v ?? '').length < 4 ? 'AA/YY girin' : null,
                onChanged: (_) => onChanged(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: cvvController,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) => (v ?? '').length < 3 ? 'CVV girin' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
