import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/providers/auth_notifier.dart';
import '../../domain/states/auth_state.dart';

class OtpBottomSheet extends ConsumerStatefulWidget {
  final String phoneNumber;
  final bool isLogin;

  const OtpBottomSheet({
    super.key,
    required this.phoneNumber,
    required this.isLogin,
  });

  @override
  ConsumerState<OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends ConsumerState<OtpBottomSheet>
    with CodeAutoFill {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _timer;
  int _remainingSeconds = 120;

  bool _isButtonEnabled = false;
  bool _isError = false;
  bool _isVerifying = false;
  bool _isResending = false;

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

  Future<void> _onVerify() async {
    final otp = _otpController.text.trim();

    final auth = ref.read(authNotifierProvider.notifier);
    await auth.verifyOtp(widget.phoneNumber, otp);

    final state = ref.read(authNotifierProvider);

    if (state.status == AuthStatus.invalidOtp) {
      _showErrorTemporarily();
      return;
    }

    // Doğru kod → bottomsheet kapanacak
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
    _focusNode.dispose();
    super.dispose();
  }

  // --------------------------------------------------------
  //  LISTENER → OTP sonucuna göre UI güncellenir
  // --------------------------------------------------------
  void _listenAuthState() {
    ref.listen(authNotifierProvider, (prev, next) {
      if (!mounted) return;

      if (next.status == AuthStatus.invalidOtp) {
        // ❌ Hatalı OTP → UI KIRMIZI olsun
        setState(() => _isError = true);
        HapticFeedback.mediumImpact();
        return; // sheet kapanmasın!
      }

      if (next.status == AuthStatus.authenticated) {
        // ✔ Doğru OTP → sheet kapanır
        Navigator.of(context).pop();
      }
    });
  }

  void _showErrorTemporarily() {
    setState(() => _isError = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      setState(() {
        _isError = false;
        _otpController.clear();
        _isButtonEnabled = false;
        _focusNode.requestFocus(); // tekrar yazabilsin
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    _listenAuthState();

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
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                _buildDescription(maskedPhone),
                const SizedBox(height: 28),
                _buildOtpField(),
                const SizedBox(height: 28),
                _buildTimerRow(minutes, seconds),
                const SizedBox(height: 28),
                _buildVerifyButton(),
                if (_isError) _buildErrorText(),
              ],
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------------
  //  UI HELPERS
  // --------------------------------------------------------

  Widget _buildTopBar() {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.gray.withOpacity(0.1),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Widget _buildDescription(String maskedPhone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SMS Onay',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(
          'Lütfen $maskedPhone numarasına gönderilen doğrulama kodunu girin',
          style:
          Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
        ),
      ],
    );
  }

  Widget _buildOtpField() {
    return PinFieldAutoFill(
      focusNode: _focusNode,
      controller: _otpController,
      codeLength: 5,
      keyboardType: TextInputType.number,
      currentCode: _otpController.text,
      decoration: UnderlineDecoration(
        textStyle: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(letterSpacing: 4),
        colorBuilder: FixedColorBuilder(
          _isError ? AppColors.error : AppColors.primaryDarkGreen,
        ),
        gapSpace: 14,
      ),
      onCodeChanged: (code) async {
        if (_isError) {
          setState(() => _isError = false);
        }

        setState(() => _isButtonEnabled = (code?.length == 5));

        if (code != null && code.length == 5) {
          await Future.delayed(const Duration(milliseconds: 250));
          _onVerify();
        }
      },
    );
  }

  Widget _buildTimerRow(String minutes, String seconds) {
    return Row(
      children: [
        Icon(
          Icons.timer_outlined,
          color: _isError ? AppColors.error : AppColors.primaryDarkGreen,
        ),
        const SizedBox(width: 6),
        Text(
          "$minutes:$seconds sn",
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color:
            _isError ? AppColors.error : AppColors.primaryDarkGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed:
          (_remainingSeconds == 0 && !_isResending) ? _onResend : null,
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
    );
  }

  Widget _buildVerifyButton() {
    return GestureDetector(
      onTap: _isButtonEnabled && !_isVerifying ? _onVerify : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: LinearGradient(
            colors: _isError
                ? [AppColors.error, AppColors.error]
                : _isVerifying
                ? [
              AppColors.gray.withOpacity(0.4),
              AppColors.gray.withOpacity(0.3)
            ]
                : _isButtonEnabled
                ? [
              AppColors.primaryDarkGreen,
              AppColors.primaryLightGreen
            ]
                : [
              AppColors.gray.withOpacity(0.3),
              AppColors.gray.withOpacity(0.2)
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: _isVerifying
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.surface,
          ),
        )
            : Text(
          _isError ? "Hatalı Kod" : "Doğrula",
          style: const TextStyle(
              color: AppColors.surface,
              fontWeight: FontWeight.w600,
              fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildErrorText() {
    return const Padding(
      padding: EdgeInsets.only(top: 12),
      child: Center(
        child: Text(
          "Girilen kod hatalı, tekrar deneyin.",
          style: TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
