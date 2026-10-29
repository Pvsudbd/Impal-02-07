import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../core/utils/top_toast.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import 'login_page.dart';
import 'terms_privacy_page.dart';
import 'widgets/auth_card_wrapper.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/password_strength_card.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _agreeTerms = false;
  bool _isLoading = false;

  String? _nameError;
  String? _emailError;
  String? _pwdError;
  String? _confirmError;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(() {
      if (_nameError != null) setState(() => _nameError = null);
    });
    _emailCtrl.addListener(() {
      if (_emailError != null) setState(() => _emailError = null);
    });
    _pwdCtrl.addListener(() {
      if (_pwdError != null) setState(() => _pwdError = null);
      setState(() {});
    });
    _confirmCtrl.addListener(() {
      if (_confirmError != null) setState(() => _confirmError = null);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _hasNoSpace => !_pwdCtrl.text.contains(' ');
  bool get _hasMinLength => _pwdCtrl.text.length >= 8;
  bool get _hasUpperLower =>
      RegExp(r'[a-z]').hasMatch(_pwdCtrl.text) && RegExp(r'[A-Z]').hasMatch(_pwdCtrl.text);
  bool get _hasNumSymbol =>
      RegExp(r'[0-9]').hasMatch(_pwdCtrl.text) &&
      RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(_pwdCtrl.text);

  bool get _isMatch =>
      _confirmCtrl.text.isNotEmpty && _pwdCtrl.text == _confirmCtrl.text;

  void _handleRegister() {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    String? nameErr;
    String? emailErr;
    String? pwdErr;
    String? confirmErr;

    if (name.isEmpty) {
      nameErr = 'Full name is required';
    }

    if (email.isEmpty) {
      emailErr = 'Email address is required';
    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      emailErr = 'Invalid email address format';
    }

    if (_pwdCtrl.text.isEmpty) {
      pwdErr = 'Password is required';
    } else if (!_hasNoSpace) {
      pwdErr = 'Password cannot contain spaces';
    } else if (!_hasMinLength || !_hasUpperLower || !_hasNumSymbol) {
      pwdErr = 'Password does not meet all security criteria';
    }

    if (_confirmCtrl.text.isEmpty) {
      confirmErr = 'Please confirm your password';
    } else if (_confirmCtrl.text.contains(' ')) {
      confirmErr = 'Password confirmation cannot contain spaces';
    } else if (_pwdCtrl.text != _confirmCtrl.text) {
      confirmErr = 'Password confirmation does not match';
    }

    setState(() {
      _nameError = nameErr;
      _emailError = emailErr;
      _pwdError = pwdErr;
      _confirmError = confirmErr;
    });

    if (nameErr != null || emailErr != null || pwdErr != null || confirmErr != null) {
      return;
    }

    if (!_agreeTerms) {
      TopToast.show(
        context,
        type: ToastType.error,
        message: 'Please review and accept our Terms of Service & Privacy Policy.',
      );
      return;
    }

    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 600), () async {
      if (!mounted) return;
      setState(() => _isLoading = false);

      PopUpPemberitahuan.accountCreated(context, name: name);
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      Navigator.pushReplacement(context, AuthFadeRoute(page: const Login()));
    });
  }

  void _navigateBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(context, AuthFadeRoute(page: const Login()));
    }
  }

  Future<void> _openTermsPrivacy() async {
    final agreed = await Navigator.push<bool>(
      context,
      AuthFadeRoute(page: const TermsPrivacyPage(isFromRegister: true)),
    );
    if (agreed == true && mounted) {
      setState(() => _agreeTerms = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topNavBar = Row(
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
                color: const Color(0xFF323846),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
            ),
          ),
        ),
        const Text(
          'Step 1 of 1',
          style: TextStyle(
            color: Color(0xFF8E95A5),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );

    return AuthCardWrapper(
      topNavBar: topNavBar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Create Account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              fontFamily: 'Inter',
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Register your student identity for smart academic prioritization.',
            style: TextStyle(
              color: Color(0xFF8E95A5),
              fontSize: 13,
              fontFamily: 'Inter',
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),

          // Inputs
          AuthTextField(
            label: 'Full Name',
            controller: _nameCtrl,
            hintText: 'Enter your full name',
            prefixIcon: Icons.person_outline_rounded,
            errorText: _nameError,
            onTap: TopToast.dismiss,
          ),
          const SizedBox(height: 16),

          AuthTextField(
            label: 'Email',
            controller: _emailCtrl,
            hintText: 'Enter your email address',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
            onTap: TopToast.dismiss,
          ),
          const SizedBox(height: 16),

          AuthTextField(
            label: 'Password',
            controller: _pwdCtrl,
            hintText: 'Enter new password',
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            errorText: _pwdError,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
            onTap: TopToast.dismiss,
          ),
          const SizedBox(height: 8),

          // Password Strength Card
          PasswordStrengthCard(password: _pwdCtrl.text),
          const SizedBox(height: 16),

          // Confirm Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Confirm Password',
                style: TextStyle(
                  color: Color(0xFFD1D5DB),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              if (_confirmCtrl.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _isMatch ? const Color(0x2D10B981) : const Color(0x2DEF4444),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _isMatch ? const Color(0x5910B981) : const Color(0x59EF4444),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isMatch ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        size: 11,
                        color: _isMatch ? const Color(0xFF6EE7B7) : const Color(0xFFF87171),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isMatch ? 'Match' : 'Mismatch',
                        style: TextStyle(
                          color: _isMatch ? const Color(0xFF6EE7B7) : const Color(0xFFF87171),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          AuthTextField(
            controller: _confirmCtrl,
            hintText: 'Confirm your password',
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            errorText: _confirmError,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
            onTap: TopToast.dismiss,
          ),
          const SizedBox(height: 16),

          // Terms Checkbox
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () {
              if (!_agreeTerms) {
                _openTermsPrivacy();
              } else {
                setState(() => _agreeTerms = false);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _agreeTerms ? const Color(0xFFFA6144) : const Color(0xFF323846),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: _agreeTerms ? const Color(0xFFFA6144) : const Color(0xFF4B5563),
                        width: 1.5,
                      ),
                    ),
                    child: _agreeTerms
                        ? const Icon(Icons.check, size: 13, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          color: Color(0xFF8E95A5),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          height: 1.35,
                        ),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: InkWell(
                              onTap: _openTermsPrivacy,
                              child: const Text(
                                'Terms of Service',
                                style: TextStyle(
                                  color: Color(0xFFFF7D65),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(text: ' and acknowledge the '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: InkWell(
                              onTap: _openTermsPrivacy,
                              child: const Text(
                                'Privacy Policy.',
                                style: TextStyle(
                                  color: Color(0xFFFF7D65),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _isLoading ? null : _handleRegister,
              child: Ink(
                width: double.infinity,
                height: 48,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoading) ...[
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      const Text(
                        'Create Student Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.15,
                          fontFamily: 'Inter',
                        ),
                      ),
                      if (!_isLoading) ...[
                        const SizedBox(width: 8),
                        const Text(
                          '➔',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Already have an account? Sign In Link
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                const Text(
                  'Already have an account? ',
                  style: TextStyle(
                    color: Color(0xFF8E95A5),
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
                InkWell(
                  onTap: _navigateBack,
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      color: Color(0xFFFF7D65),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
