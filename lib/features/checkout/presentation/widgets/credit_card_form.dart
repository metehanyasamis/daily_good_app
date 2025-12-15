import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'credit_card_helpers.dart';

class CreditCardForm extends StatelessWidget {
  final TextEditingController holder;
  final TextEditingController number;
  final TextEditingController expiry;
  final TextEditingController cvv;
  final VoidCallback onChanged;

  const CreditCardForm({
    super.key,
    required this.holder,
    required this.number,
    required this.expiry,
    required this.cvv,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _field(
          controller: holder,
          label: 'Kart Sahibi',
          onChanged: (_) => onChanged(),
          validator: (v) =>
          (v ?? '').trim().isEmpty ? 'Kart sahibini girin' : null,
        ),
        const SizedBox(height: 12),
        _field(
          controller: number,
          label: 'Kart Numarası',
          hint: '0000 0000 0000 0000',
          keyboard: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            cardNumberFormatter(number),
          ],
          onChanged: (_) => onChanged(),
          validator: (v) =>
          v!.replaceAll(' ', '').length == 16 ? null : '16 haneli olmalı',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _field(
                controller: expiry,
                label: 'Son Kullanım',
                hint: 'MM/YY',
                keyboard: TextInputType.number,
                inputFormatters: [expiryFormatter(expiry)],
                onChanged: (_) => onChanged(),
                validator: (v) =>
                RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(v ?? '')
                    ? null
                    : 'MM/YY',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _field(
                controller: cvv,
                label: 'CVV',
                keyboard: TextInputType.number,
                obscure: true,
                validator: (v) =>
                (v ?? '').length >= 3 ? null : 'En az 3 hane',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboard,
    List<TextInputFormatter>? inputFormatters,
    bool obscure = false,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      inputFormatters: inputFormatters,
      obscureText: obscure,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
