
// -----------------------------------------------------------------------------
// E-POSTA DEĞİŞTİRME BOTTOM SHEET BİLEŞENİ
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/providers/user_notifier.dart';

class EmailChangeBottomSheet extends ConsumerStatefulWidget {
  final String currentEmail;
  const EmailChangeBottomSheet({required this.currentEmail});

  @override
  ConsumerState<EmailChangeBottomSheet> createState() => EmailChangeBottomSheetState();
}

class EmailChangeBottomSheetState extends ConsumerState<EmailChangeBottomSheet> {
  final _newEmailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isLoading = false;

  Future<void> _handleAction() async {
    setState(() => _isLoading = true);
    final repo = ref.read(userRepositoryProvider);

    try {
      if (!_isOtpSent) {
        // 1. Adım: OTP Gönder
        await repo.sendEmailChangeOtp(_newEmailController.text.trim());
        setState(() => _isOtpSent = true);
      } else {
        // 2. Adım: OTP Doğrula ve Güncelle
        final updatedUser = await repo.verifyEmailChangeOtp(
          _newEmailController.text.trim(),
          _otpController.text.trim(),
        );
        ref.read(userNotifierProvider.notifier).loadUser(); // State'i tazele
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 24),
          Text(_isOtpSent ? "Kodu Doğrula" : "E-posta Değiştir", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            _isOtpSent ? "${_newEmailController.text} adresine gelen kodu girin." : "Yeni e-posta adresinize bir doğrulama kodu göndereceğiz.",
            textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          if (!_isOtpSent)
            TextField(
              controller: _newEmailController,
              decoration: InputDecoration(
                hintText: "Yeni e-posta adresi",
                prefixIcon: const Icon(Icons.mail_outline),
                filled: true, fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            )
          else
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: InputDecoration(
                hintText: "000000",
                filled: true, fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleAction,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDarkGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(_isOtpSent ? "Onayla" : "Kod Gönder", style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}