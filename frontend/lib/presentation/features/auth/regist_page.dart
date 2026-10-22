import 'package:flutter/material.dart';
import '../../../core/utils/page_transitions.dart';
import 'login_page.dart';

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

  @override
  void initState() {
    super.initState();
    _pwdCtrl.addListener(() => setState(() {}));
    _confirmCtrl.addListener(() => setState(() {}));
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
  bool get _hasMinLength => _pwdCtrl.text.length >= 8;
  bool get _hasUpperLower =>
      RegExp(r'[a-z]').hasMatch(_pwdCtrl.text) && RegExp(r'[A-Z]').hasMatch(_pwdCtrl.text);
  bool get _hasNumSymbol =>
      RegExp(r'[0-9]').hasMatch(_pwdCtrl.text) &&
      RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(_pwdCtrl.text);

  int get _pwdScore {
    final p = _pwdCtrl.text;
    if (p.isEmpty) return 0;
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

    if (name.isEmpty) return _showToast('Nama lengkap tidak boleh kosong!', isError: true);
    if (email.isEmpty || !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      return _showToast('Format email tidak valid!', isError: true);
    }
    if (!_hasMinLength || !_hasUpperLower || !_hasNumSymbol) {
      return _showToast('Password belum memenuhi seluruh kriteria keamanan!', isError: true);
    }
    if (_pwdCtrl.text != _confirmCtrl.text) {
      return _showToast('Konfirmasi password tidak cocok!', isError: true);
    }
    if (!_agreeTerms) {
      return _showToast('Harap setujui Ketentuan Layanan & Kebijakan Privasi!', isError: true);
    }

    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showToast('Pendaftaran akun $name berhasil! Silakan Sign In.');
      Navigator.pushReplacement(context, AuthFadeRoute(page: const Login()));
    });
  }

  void _showToast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Inter', color: Colors.white)),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFFFA6144),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _navigateBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(context, AuthFadeRoute(page: const Login()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: isMobile ? const Color(0xFF282D37) : const Color(0xFF1E222B),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 16, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 28, vertical: isMobile ? 0 : 36),
                decoration: isMobile
                    ? null
                    : BoxDecoration(
                        color: const Color(0xFF282D37),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(color: Color(0x66000000), blurRadius: 40, offset: Offset(0, 20), spreadRadius: -4),
                        ],
                      ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Navigation
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
                    ),
                    const SizedBox(height: 18),

                    // Title & Description
                    const Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, fontFamily: 'Inter', letterSpacing: -0.5)),
                    const SizedBox(height: 6),
                    const Text('Register your student identity for smart academic prioritization.', style: TextStyle(color: Color(0xFF8E95A5), fontSize: 13, fontFamily: 'Inter', height: 1.45)),
                    const SizedBox(height: 22),

                    // Inputs
                    _label('Full Name'),
                    const SizedBox(height: 6),
                    _input(ctrl: _nameCtrl, hint: 'Enter full name (e.g. Yoga Perkakas)', icon: Icons.person_outline_rounded),
                    const SizedBox(height: 16),

                    _label('Email'),
                    const SizedBox(height: 6),
                    _input(ctrl: _emailCtrl, hint: 'Enter email (e.g. yoga@student.telkomuniversity.ac.id)', icon: Icons.mail_outline_rounded, type: TextInputType.emailAddress),
                    const SizedBox(height: 16),

                    _label('Password'),
                    const SizedBox(height: 6),
                    _input(
                      ctrl: _pwdCtrl,
                      hint: 'Enter new password',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscurePwd,
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
                      borderColor: _confirmCtrl.text.isNotEmpty ? (_isMatch ? const Color(0x6610B981) : const Color(0x66EF4444)) : null,
                      suffix: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF9CA3AF), size: 20),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Terms Checkbox
                    InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => setState(() => _agreeTerms = !_agreeTerms),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                color: _agreeTerms ? const Color(0xFFFA6144) : const Color(0xFF323846),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: _agreeTerms ? const Color(0xFFFA6144) : const Color(0xFF4B5563), width: 1.5),
                              ),
                              child: _agreeTerms ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text('I agree to the ', style: TextStyle(color: Color(0xFF8E95A5), fontSize: 12, fontFamily: 'Inter')),
                                  InkWell(
                                    onTap: () => _showToast('Ketentuan Layanan Smart Task Manager'),
                                    child: const Text('Terms of Service', style: TextStyle(color: Color(0xFFFF7D65), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                                  ),
                                  const Text(' and acknowledge the ', style: TextStyle(color: Color(0xFF8E95A5), fontSize: 12, fontFamily: 'Inter')),
                                  InkWell(
                                    onTap: () => _showToast('Kebijakan Privasi Smart Task Manager'),
                                    child: const Text('Privacy Policy.', style: TextStyle(color: Color(0xFFFF7D65), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                                  ),
                                ],
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
                        borderRadius: BorderRadius.circular(14),
                        onTap: _isLoading ? null : _handleRegister,
                        child: Ink(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFA6144),
                            borderRadius: BorderRadius.circular(14),
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
                    const SizedBox(height: 24),

                    // Footer
                    const Center(
                      child: Text('IMPAL Group 7 • Telkom University © 2026', style: TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontFamily: 'Inter')),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF323846),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor ?? const Color(0xFF3B4150)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: ctrl,
              obscureText: obscure,
              keyboardType: type,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Inter'),
              cursorColor: const Color(0xFFFA6144),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13.5, fontFamily: 'Inter'),
              ),
            ),
          ),
          if (suffix != null) suffix,
        ],
      ),
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
        ],
      ),
    );
  }

  Widget _reqItem({required bool isMet, required String label}) {
    return Row(
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: isMet ? const Color(0x3310B981) : const Color(0xFF383F4D),
            shape: BoxShape.circle,
            border: Border.all(color: isMet ? const Color(0x6610B981) : const Color(0xFF4B5563)),
          ),
          alignment: Alignment.center,
          child: Icon(isMet ? Icons.check : Icons.circle, size: isMet ? 10 : 3.5, color: isMet ? const Color(0xFF10B981) : const Color(0xFF6B7280)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: TextStyle(color: isMet ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280), fontSize: 11, fontFamily: 'Inter'))),
      ],
    );
  }
}