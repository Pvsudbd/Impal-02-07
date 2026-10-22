import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../core/utils/top_toast.dart';
import 'login_page.dart';
import 'reset_password_page.dart';
import 'pop_up_recovery_code.dart';

class VerificationCodePage extends StatefulWidget {
  final String destination;

  const VerificationCodePage({
    super.key,
    this.destination = 'yogaperkakas@gmail.com',
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
    RecoveryCodeSentDialog.show(
      context,
      destination: widget.destination,
      autoCloseSeconds: 2,
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

    showTopToast(
      context,
      'Code verified successfully!',
      type: ToastType.success,
    );

    Navigator.push(
      context,
      AuthFadeRoute(
        page: ResetPasswordPage(email: widget.destination),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final topNavBar = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Back Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _navigateBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF323846),
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

        // Title
        const Text(
          'Verify Code',
          style: TextStyle(
            color: Color(0xFF8E95A5),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),

        // Spacer to balance back button
        const SizedBox(width: 36),
      ],
    );

    final contentColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMobile) ...[
          topNavBar,
          const SizedBox(height: 28),
        ],

                    // Hero Section: Icon, Title, Subtitle
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFA6144),
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
                                      color: Color(0xFF8E95A5),
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

                    const SizedBox(height: 28),

                    // OTP Section Label
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

                    // 6 OTP Digit Boxes
                    _buildOtpInputs(),

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
                            Expanded(
                              child: Text(
                                _otpError!,
                                style: const TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 11.5,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Timer & Resend Code Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Expires in: ',
                                style: TextStyle(
                                  color: Color(0xFF8E95A5),
                                  fontSize: 11,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: _formattedTimer,
                                style: const TextStyle(
                                  color: Color(0xFFFF7D65),
                                  fontSize: 11,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: _resendCode,
                          child: const Text(
                            'Resend Code',
                            style: TextStyle(
                              color: Color(0xFFFF7D65),
                              fontSize: 11,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Verify Code & Continue Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _isLoading ? null : _handleVerifyCode,
                        child: Ink(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFA6144),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x59EF4444),
                                blurRadius: 18,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Verify Code',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
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
                              color: Color(0xFF8E95A5),
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
                                color: Color(0xFFFF7D65),
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Telkom University Footer
                    const Center(
                      child: Text(
                        'IMPAL Group 7 • Telkom University © 2026',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 11,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                );

    return Scaffold(
      backgroundColor: isMobile ? const Color(0xFF282D37) : const Color(0xFF1E222B),
      body: SafeArea(
        child: isMobile
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: topNavBar,
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: contentColumn,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                      decoration: ShapeDecoration(
                        color: const Color(0xFF282D37),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x66000000),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                            spreadRadius: -2,
                          )
                        ],
                      ),
                      child: contentColumn,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildOtpInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        final isFocused = _otpFocusNodes[index].hasFocus;
        final hasError = _otpError != null && _otpError!.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 46,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF323846),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasError
                  ? const Color(0xFFEF4444)
                  : isFocused
                      ? const Color(0xFFFA6144)
                      : const Color(0xFF3B4150),
              width: (isFocused || hasError) ? 1.5 : 1.0,
            ),
            boxShadow: isFocused
                ? const [
                    BoxShadow(
                      color: Color(0x33EF4444),
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _otpFocusNodes[index],
            onTap: TopToast.dismiss,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
            cursorColor: const Color(0xFFFA6144),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                _otpFocusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _otpFocusNodes[index - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }
}

// Aliases for compatibility
typedef EnterVerificationCode = VerificationCodePage;