import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../../core/theme/app_theme.dart';

class OtpBottomSheet extends StatefulWidget {
  final String phoneNumber;

  const OtpBottomSheet({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends State<OtpBottomSheet> with CodeAutoFill {
  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = 120;
  bool _isButtonEnabled = false;
  bool _isError = false;
  bool _isResending = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => listenForCode());
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _remainingSeconds = 120);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void codeUpdated() {
    final newCode = code ?? '';
    setState(() {
      _otpController.text = newCode;
      _isButtonEnabled = (newCode.length == 5);
    });
  }

  void _onVerify() {
    if (_otpController.text == '12345') {
      context.pop();
      Future.microtask(() => context.go('/profileDetail'));
    } else {
      setState(() => _isError = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isError = false);
      });
    }
  }

  Future<void> _onResend() async {
    setState(() => _isResending = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isResending = false);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');

    final maskedPhone = widget.phoneNumber.replaceRange(
      3,
      widget.phoneNumber.length - 3,
      '*' * (widget.phoneNumber.length - 6),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag bar
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.gray.withValues(alpha: 10),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Text(
                  'SMS Onay',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  'Lütfen $maskedPhone numarasına gönderilen doğrulama kodunu girin',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
                const SizedBox(height: 28),

                // OTP Input
                PinFieldAutoFill(
                  focusNode: _focusNode,
                  controller: _otpController,
                  codeLength: 5,
                  keyboardType: TextInputType.number,
                  currentCode: _otpController.text,
                  decoration: UnderlineDecoration(
                    textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 4),
                    colorBuilder: FixedColorBuilder(
                      _isError ? AppColors.error : AppColors.primaryDarkGreen,
                    ),
                    gapSpace: 14,
                  ),
                  onCodeChanged: (code) {
                    setState(() => _isButtonEnabled = (code?.length == 5));
                  },
                ),

                const SizedBox(height: 28),

                // Timer & Resend
                Row(
                  children: [
                    Icon(Icons.timer_outlined, color: _isError ? AppColors.error : AppColors.primaryDarkGreen),
                    const SizedBox(width: 6),
                    Text(
                      "$minutes:$seconds sn",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: _isError ? AppColors.error : AppColors.primaryDarkGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: (_remainingSeconds == 0 && !_isResending) ? _onResend : null,
                      child: _isResending
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryDarkGreen,
                        ),
                      )
                          : Text(
                        "Yeniden Gönder",
                        style: TextStyle(
                          color: (_remainingSeconds == 0)
                              ? AppColors.primaryDarkGreen
                              : AppColors.gray,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Submit Button
                GestureDetector(
                  onTap: _isButtonEnabled ? _onVerify : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      gradient: LinearGradient(
                        colors: _isError
                            ? [AppColors.error.withValues(alpha: 200), AppColors.error]
                            : _isButtonEnabled
                            ? [AppColors.primaryDarkGreen, AppColors.primaryLightGreen]
                            : [AppColors.gray.withValues(alpha: 150), AppColors.gray.withValues(alpha: 100)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Text(
                      _isError ? "Hatalı Kod" : "Doğrula",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _isButtonEnabled || _isError ? AppColors.surface : AppColors.surface,
                      ),
                    ),
                  ),
                ),

                if (_isError)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        "Girilen kod hatalı, lütfen tekrar deneyin.",
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
