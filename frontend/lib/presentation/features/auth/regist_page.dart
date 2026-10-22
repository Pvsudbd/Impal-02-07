import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../core/utils/top_toast.dart';
import 'login_page.dart';
import 'terms_privacy_page.dart';
import 'pop_up_account_created.dart';

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

  bool _obscurePwd = true;
  bool _obscureConfirm = true;
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

  // Password Validation Checkers
  bool get _hasNoSpace => !_pwdCtrl.text.contains(' ');
  bool get _hasMinLength => _pwdCtrl.text.length >= 8;
  bool get _hasUpperLower =>
      RegExp(r'[a-z]').hasMatch(_pwdCtrl.text) && RegExp(r'[A-Z]').hasMatch(_pwdCtrl.text);
  bool get _hasNumSymbol =>
      RegExp(r'[0-9]').hasMatch(_pwdCtrl.text) &&
      RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(_pwdCtrl.text);

  int get _pwdScore {
    final p = _pwdCtrl.text;
    if (p.isEmpty) return 0;
    if (!_hasNoSpace) return 1;
    int s = (_hasMinLength ? 1 : 0) + (_hasUpperLower ? 1 : 0) + (_hasNumSymbol ? 1 : 0);
    return (p.length >= 12 && s == 3) ? 4 : s;
  }

  String get _pwdLabel => switch (_pwdScore) {
        1 => 'Weak (33%)',
        2 => 'Medium (66%)',
        3 || 4 => 'Strong (92%)',
        _ => 'Too Weak (0%)',
      };

  Color get _pwdColor => switch (_pwdScore) {
        1 => const Color(0xFFEF4444),
        2 => const Color(0xFFF59E0B),
        3 || 4 => const Color(0xFF6EE7B7),
        _ => const Color(0xFF6B7280),
      };

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
      _showToast('Please read and agree to the Terms of Service & Privacy Policy first!', isError: true);
      _openTermsPrivacy();
      return;
    }

    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 700), () async {
      if (!mounted) return;
      setState(() => _isLoading = false);

      await AccountCreatedDialog.show(
        context,
        name: name,
        email: email,
        autoCloseSeconds: 2,
      );

      if (!mounted) return;
      Navigator.pushReplacement(context, AuthFadeRoute(page: const Login()));
    });
  }

  void _showToast(String msg, {bool isError = false}) {
    showTopToast(
      context,
      msg,
      type: isError ? ToastType.error : ToastType.success,
    );
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
      AuthFadeRoute(page: const TermsPrivacyPage()),
    );
    if (agreed == true && mounted) {
      setState(() => _agreeTerms = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

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
        const Text('Step 1 of 1', style: TextStyle(color: Color(0xFF8E95A5), fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
      ],
    );

    final contentColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMobile) ...[
          topNavBar,
          const SizedBox(height: 18),
        ],

                    // Title & Description
                    const Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, fontFamily: 'Inter', letterSpacing: -0.5)),
                    const SizedBox(height: 6),
                    const Text('Register your student identity for smart academic prioritization.', style: TextStyle(color: Color(0xFF8E95A5), fontSize: 13, fontFamily: 'Inter', height: 1.45)),
                    const SizedBox(height: 22),

                    // Inputs
                    _label('Full Name'),
                    const SizedBox(height: 6),
                    _input(
                      ctrl: _nameCtrl,
                      hint: 'Enter your full name',
                      icon: Icons.person_outline_rounded,
                      errorText: _nameError,
                    ),
                    const SizedBox(height: 16),

                    _label('Email'),
                    const SizedBox(height: 6),
                    _input(
                      ctrl: _emailCtrl,
                      hint: 'Enter your email address',
                      icon: Icons.mail_outline_rounded,
                      type: TextInputType.emailAddress,
                      errorText: _emailError,
                    ),
                    const SizedBox(height: 16),

                    _label('Password'),
                    const SizedBox(height: 6),
                    _input(
                      ctrl: _pwdCtrl,
                      hint: 'Enter new password',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscurePwd,
                      errorText: _pwdError,
                      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                      suffix: IconButton(
                        icon: Icon(_obscurePwd ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF9CA3AF), size: 20),
                        onPressed: () => setState(() => _obscurePwd = !_obscurePwd),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Password Strength Card
                    _strengthCard(),
                    const SizedBox(height: 16),

                    // Confirm Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _label('Confirm Password'),
                        if (_confirmCtrl.text.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _isMatch ? const Color(0x2D10B981) : const Color(0x2DEF4444),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _isMatch ? const Color(0x5910B981) : const Color(0x59EF4444)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_isMatch ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 11, color: _isMatch ? const Color(0xFF6EE7B7) : const Color(0xFFF87171)),
                                const SizedBox(width: 4),
                                Text(_isMatch ? 'Match' : 'Mismatch', style: TextStyle(color: _isMatch ? const Color(0xFF6EE7B7) : const Color(0xFFF87171), fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _input(
                      ctrl: _confirmCtrl,
                      hint: 'Confirm your password',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscureConfirm,
                      errorText: _confirmError,
                      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                      borderColor: _confirmCtrl.text.isNotEmpty ? (_isMatch ? const Color(0x6610B981) : const Color(0x66EF4444)) : null,
                      suffix: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF9CA3AF), size: 20),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Terms Checkbox (Requires reading Terms & Privacy first)
                    InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        if (!_agreeTerms) {
                          // Redirect user to Terms & Privacy page to read to the bottom!
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
                                border: Border.all(color: _agreeTerms ? const Color(0xFFFA6144) : const Color(0xFF4B5563), width: 1.5),
                              ),
                              child: _agreeTerms ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  style: const TextStyle(color: Color(0xFF8E95A5), fontSize: 12, fontFamily: 'Inter', height: 1.35),
                                  children: [
                                    const TextSpan(text: 'I agree to the '),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: InkWell(
                                        onTap: _openTermsPrivacy,
                                        child: const Text('Terms of Service', style: TextStyle(color: Color(0xFFFF7D65), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                                      ),
                                    ),
                                    const TextSpan(text: ' and acknowledge the '),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: InkWell(
                                        onTap: _openTermsPrivacy,
                                        child: const Text('Privacy Policy.', style: TextStyle(color: Color(0xFFFF7D65), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
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
                    const SizedBox(height: 22),

                    // Submit Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _isLoading ? null : _handleRegister,
                        child: Ink(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFA6144),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Color(0x59EF4444), blurRadius: 18, offset: Offset(0, 8)),
                            ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)))
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Create Student Account', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                                      SizedBox(width: 8),
                                      Text('➔', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Already have an account? Sign In Link
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          const Text('Already have an account? ', style: TextStyle(color: Color(0xFF8E95A5), fontSize: 12, fontFamily: 'Inter')),
                          InkWell(
                            onTap: _navigateBack,
                            child: const Text('Sign In', style: TextStyle(color: Color(0xFFFF7D65), fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                          ),
                        ],
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
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                              maxWidth: 440,
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  contentColumn,
                                  const Spacer(),
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 24, top: 16),
                                    child: Center(
                                      child: Text(
                                        'IMPAL Group 7 • Telkom University © 2026',
                                        style: TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 11,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 440),
                                  child: RepaintBoundary(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF282D37),
                                        borderRadius: BorderRadius.circular(28),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x66000000),
                                            blurRadius: 18,
                                            offset: Offset(0, 10),
                                            spreadRadius: -2,
                                          ),
                                        ],
                                      ),
                                      child: contentColumn,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 24, top: 12),
                              child: Center(
                                child: Text(
                                  'IMPAL Group 7 • Telkom University © 2026',
                                  style: TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 11,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 12.5, fontWeight: FontWeight.w600, fontFamily: 'Inter'));

  Widget _input({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    Color? borderColor,
    TextInputType type = TextInputType.text,
    String? errorText,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;
    final isPasswordField = obscure || ctrl == _pwdCtrl || ctrl == _confirmCtrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF323846),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError
                  ? const Color(0xFFEF4444)
                  : (borderColor ?? const Color(0xFF3B4150)),
              width: hasError ? 1.4 : 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: hasError ? const Color(0xFFEF4444) : const Color(0xFF9CA3AF),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: ctrl,
                  obscureText: obscure,
                  enableInteractiveSelection: !isPasswordField,
                  contextMenuBuilder: isPasswordField
                      ? (context, editableTextState) => const SizedBox.shrink()
                      : null,
                  onTap: TopToast.dismiss,
                  keyboardType: type,
                  inputFormatters: inputFormatters,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Inter'),
                  cursorColor: const Color(0xFFFA6144),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13.5, fontFamily: 'Inter'),
                  ),
                ),
              ),
              if (suffix != null) suffix,
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, size: 13, color: Color(0xFFEF4444)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    errorText,
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _strengthCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D333F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF3B4150)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('PASSWORD STRENGTH', style: TextStyle(color: Color(0xFF8E95A5), fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Inter', letterSpacing: 0.3)),
              Text(_pwdLabel, style: TextStyle(color: _pwdColor, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(4, (i) => Expanded(
              child: Container(
                height: 4.5,
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  color: (i + 1) <= _pwdScore ? _pwdColor : const Color(0xFF3F4756),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            )),
          ),
          const SizedBox(height: 10),
          _reqItem(isMet: _hasMinLength, label: 'At least 8 characters long (recommended 12+)'),
          const SizedBox(height: 5),
          _reqItem(isMet: _hasUpperLower, label: 'Includes uppercase & lowercase letters'),
          const SizedBox(height: 5),
          _reqItem(isMet: _hasNumSymbol, label: 'Includes at least one number and special symbol (#, !, @)'),
          const SizedBox(height: 5),
          _reqItem(isMet: _hasNoSpace && _pwdCtrl.text.isNotEmpty, label: 'Cannot contain spaces'),
        ],
      ),
    );
  }

  Widget _reqItem({required bool isMet, required String label}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isMet ? const Color(0x3310B981) : const Color(0xFF383F4D),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isMet ? const Color(0x6610B981) : const Color(0xFF4B5563)),
          ),
          alignment: Alignment.center,
          child: isMet
              ? const Icon(Icons.check, size: 10, color: Color(0xFF10B981))
              : Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B7280),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: TextStyle(color: isMet ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280), fontSize: 11, fontFamily: 'Inter'))),
      ],
    );
  }
}