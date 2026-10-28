import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/unfocus_on_tap.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import 'login_page.dart';
import 'reset_password_page.dart';
import 'widgets/auth_card_wrapper.dart';
import 'widgets/otp_boxes.dart';

class VerificationCodePage extends StatefulWidget {
  final String destination;
  final bool isPhone;

  const VerificationCodePage({
    super.key,
    this.destination = 'yogaperkakas@gmail.com',
    this.isPhone = false,
  });

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  late final List<TextEditingController> _otpControllers;
  late final List<FocusNode> _otpFocusNodes;

  bool _isLoading = false;
  String? _otpError;

  Timer? _timer;
  int _secondsRemaining = 285; // 04:45

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(6, (index) => TextEditingController());
    _otpFocusNodes = List.generate(6, (index) => FocusNode());

    for (int i = 0; i < 6; i++) {
      _otpControllers[i].addListener(() {
        if (_otpError != null) {
          setState(() => _otpError = null);
        }
      });
      _otpFocusNodes[i].addListener(() {
        setState(() {});
      });
    }

    _startCountdownTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdownTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _formattedTimer {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _resendCode() {
    setState(() {
      _secondsRemaining = 300;
      _otpError = null;
    });
    _startCountdownTimer();
    PopUpPemberitahuan.recoveryCodeSent(
      context,
      destination: widget.destination,
    );
  }

  void _navigateBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      _navigateToSignIn();
    }
  }

  void _navigateToSignIn() {
    Navigator.pushAndRemoveUntil(
      context,
      AuthFadeRoute(page: const Login()),
      (route) => false,
    );
  }

  Future<void> _handleVerifyCode() async {
    final otp = _otpControllers.map((c) => c.text.trim()).join();

    if (otp.length < 6) {
      setState(() {
        _otpError = 'Please enter the complete 6-digit verification code';
      });
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;
    setState(() => _isLoading = false);

    PopUpPemberitahuan.codeVerified(context);

    Navigator.push(
      context,
      AuthFadeRoute(
        page: ResetPasswordPage(email: widget.destination),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: UnfocusOnTap(
        child: AuthCardWrapper(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Back Navigation Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: _navigateBack,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Verify Code',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),

              const SizedBox(height: 24),

              // Hero Shield Icon & Title
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x59EF4444),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.verified_user_rounded,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Enter Verification Code',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 320,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: "We've dispatched a 6-digit confirmation code to: \n",
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.45,
                              ),
                            ),
                            TextSpan(
                              text: widget.destination,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Center(
                child: Text(
                  '6-Digit OTP Verification Code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFD1D5DB),
                    fontSize: 12.5,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // OTP Digit Boxes
              OtpBoxes(
                controllers: _otpControllers,
                focusNodes: _otpFocusNodes,
                errorMessage: _otpError,
                onCompleted: _handleVerifyCode,
              ),

              if (_otpError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 13,
                        color: Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _otpError!,
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 11.5,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Timer & Resend Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Expires in $_formattedTimer',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: _secondsRemaining == 0 ? _resendCode : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'Resend Code',
                        style: TextStyle(
                          color: _secondsRemaining == 0
                              ? AppColors.primaryAccent
                              : const Color(0xFF555D6E),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Verify Code Button
              AppButton(
                text: 'Verify Code',
                isLoading: _isLoading,
                suffixIcon: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                onPressed: _handleVerifyCode,
              ),

              const SizedBox(height: 18),

              // Back to Sign In Link
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    const Text(
                      'Remember your previous password? ',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    InkWell(
                      onTap: _navigateToSignIn,
                      child: const Text(
                        'Back to Sign In',
                        style: TextStyle(
                          color: AppColors.primaryAccent,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Aliases for compatibility
typedef EnterVerificationCode = VerificationCodePage;
