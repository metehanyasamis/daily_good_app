import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OtpBottomSheet extends StatefulWidget {
  final String phoneNumber; // 🔹 Kullanıcının girdiği telefon

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      listenForCode();
    });
    _startTimer();
  }

  /// 🔹 Sayaç başlat / yeniden başlat
  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = 120;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  /// 🔹 SMS Autofill
  @override
  void codeUpdated() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final newCode = code ?? '';
      setState(() {
        _otpController.text = newCode;
        _isButtonEnabled = (newCode.length == 5);
      });
    });
  }

  /// 🔹 Kod doğrulama işlemi
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

  /// 🔹 Yeniden Gönder işlemi
  Future<void> _onResend() async {
    setState(() => _isResending = true);

    // burada backend'e "otp resend" isteği atılabilir
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isResending = false);

    _startTimer(); // sayaç sıfırlanır
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

    // 🔹 Telefonu maskele (5301234434 → 530****434)
    final maskedPhone = widget.phoneNumber.replaceRange(
      3,
      widget.phoneNumber.length - 3,
      '*' * (widget.phoneNumber.length - 6),
    );

    FocusScope.of(context).requestFocus(_focusNode);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const Text(
                  'SMS Onay',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Lütfen $maskedPhone numarasına gönderilen doğrulama kodunu girin',
                  style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                ),
                const SizedBox(height: 28),

                /// 🔹 OTP Input
                PinFieldAutoFill(
                  focusNode: _focusNode,
                  controller: _otpController,
                  codeLength: 5,
                  keyboardType: TextInputType.number,
                  currentCode: _otpController.text,
                  decoration: UnderlineDecoration(
                    textStyle: const TextStyle(fontSize: 24, color: Colors.black),
                    colorBuilder: FixedColorBuilder(
                      _isError ? Colors.red : const Color(0xFF49A05D),
                    ),
                    gapSpace: 14,
                  ),
                  onCodeChanged: (code) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      setState(() => _isButtonEnabled = (code?.length == 5));
                    });
                  },
                ),

                const SizedBox(height: 28),

                /// 🔹 Timer + Resend
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.timer_outlined,
                        color: _isError ? Colors.red : const Color(0xFF49A05D)),
                    const SizedBox(width: 6),
                    Text(
                      "$minutes:$seconds sn",
                      style: TextStyle(
                        color: _isError ? Colors.red : const Color(0xFF49A05D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: (_remainingSeconds == 0 && !_isResending)
                          ? _onResend
                          : null,
                      child: _isResending
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF49A05D),
                        ),
                      )
                          : Text(
                        "Yeniden Gönder",
                        style: TextStyle(
                          color: (_remainingSeconds == 0)
                              ? const Color(0xFF49A05D)
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                /// 🔹 Verify Button
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
                            ? [Colors.red.shade400, Colors.red.shade600]
                            : _isButtonEnabled
                            ? const [Color(0xFF3E8D4E), Color(0xFF7EDC8A)]
                            : [Colors.grey, Colors.grey.shade400],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Text(
                      _isError ? "Hatalı Kod" : "Doğrula",
                      style: TextStyle(
                        color: _isButtonEnabled || _isError
                            ? Colors.white
                            : Colors.grey.shade600,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
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
                          color: Colors.red,
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
