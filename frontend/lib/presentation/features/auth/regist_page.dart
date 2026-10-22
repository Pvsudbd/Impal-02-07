import 'package:flutter/material.dart';
import '../../../core/utils/page_transitions.dart';
import 'login_page.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onConfirmPasswordChanged);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.removeListener(_onPasswordChanged);
    _passwordController.dispose();
    _confirmPasswordController.removeListener(_onConfirmPasswordChanged);
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    setState(() {});
  }

  void _onConfirmPasswordChanged() {
    setState(() {});
  }

  // Password validation checks
  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasUpperAndLower =>
      RegExp(r'[a-z]').hasMatch(_passwordController.text) &&
      RegExp(r'[A-Z]').hasMatch(_passwordController.text);
  bool get _hasNumberAndSpecial =>
      RegExp(r'[0-9]').hasMatch(_passwordController.text) &&
      RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(_passwordController.text);

  int get _passwordStrengthScore {
    final password = _passwordController.text;
    if (password.isEmpty) return 0;
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasUpperAndLower) score++;
    if (_hasNumberAndSpecial) score++;
    if (password.length >= 12 && score == 3) score = 4;
    return score;
  }

  String get _passwordStrengthLabel {
    final score = _passwordStrengthScore;
    if (_passwordController.text.isEmpty) return 'Too Weak (0%)';
    switch (score) {
      case 1:
        return 'Weak (33%)';
      case 2:
        return 'Medium (66%)';
      case 3:
      case 4:
        return 'Strong (92%)';
      default:
        return 'Too Weak (0%)';
    }
  }

  Color get _passwordStrengthColor {
    final score = _passwordStrengthScore;
    if (_passwordController.text.isEmpty) return const Color(0xFF6B7280);
    switch (score) {
      case 1:
        return const Color(0xFFEF4444);
      case 2:
        return const Color(0xFFF59E0B);
      case 3:
      case 4:
        return const Color(0xFF6EE7B7);
      default:
        return const Color(0xFF6B7280);
    }
  }

  bool get _isPasswordMatch {
    if (_confirmPasswordController.text.isEmpty) return false;
    return _passwordController.text == _confirmPasswordController.text;
  }

  void _handleRegister() {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (fullName.isEmpty) {
      _showToast('Nama lengkap tidak boleh kosong!', isError: true);
      return;
    }

    if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showToast('Silakan masukkan format email yang valid!', isError: true);
      return;
    }

    if (password.isEmpty || !_hasMinLength) {
      _showToast('Password harus minimal 8 karakter!', isError: true);
      return;
    }

    if (!_hasUpperAndLower || !_hasNumberAndSpecial) {
      _showToast('Password belum memenuhi seluruh kriteria keamanan!', isError: true);
      return;
    }

    if (password != confirmPassword) {
      _showToast('Konfirmasi password tidak cocok!', isError: true);
      return;
    }

    if (!_agreeToTerms) {
      _showToast('Anda harus menyetujui Ketentuan Layanan & Kebijakan Privasi!', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      _showToast('Pendaftaran akun $fullName berhasil! Silakan Sign In.');

      Navigator.pushReplacement(
        context,
        AuthSlideFadeRoute(
          page: const Login(),
          fromRight: false,
        ),
      );
    });
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFFFA6144),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _navigateBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        AuthSlideFadeRoute(
          page: const Login(),
          fromRight: false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: isMobile ? const Color(0xFF282D37) : const Color(0xFF1E222B),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 16,
              vertical: isMobile ? 20 : 32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 440,
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 0 : 28,
                  vertical: isMobile ? 0 : 36,
                ),
                decoration: isMobile
                    ? null
                    : ShapeDecoration(
                        color: const Color(0xFF282D37),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x66000000),
                            blurRadius: 40,
                            offset: Offset(0, 20),
                            spreadRadius: -4,
                          )
                        ],
                      ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Navigation Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: _navigateBack,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: ShapeDecoration(
                                color: const Color(0xFF323846),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          'Step 1 of 1',
                          style: TextStyle(
                            color: Color(0xFF8E95A5),
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Title & Description
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.50,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Register your student identity for smart academic prioritization.',
                      style: TextStyle(
                        color: Color(0xFF8E95A5),
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Full Name Field
                    _buildFieldLabel('Full Name'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _fullNameController,
                      hintText: 'Enter full name (e.g. Yoga Perkakas)',
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 18),

                    // Email Field
                    _buildFieldLabel('Email'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'Enter email (e.g. yoga@student.telkomuniversity.ac.id)',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),

                    // Password Field
                    _buildFieldLabel('Password'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: 'Enter new password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        splashRadius: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFF9CA3AF),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Password Strength Indicator Card
                    _buildPasswordStrengthCard(),
                    const SizedBox(height: 18),

                    // Confirm Password Field
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFieldLabel('CONFIRM NEW PASSWORD'),
                        if (_confirmPasswordController.text.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: ShapeDecoration(
                              color: _isPasswordMatch
                                  ? const Color(0x2D10B981)
                                  : const Color(0x2DEF4444),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: _isPasswordMatch
                                      ? const Color(0x5910B981)
                                      : const Color(0x59EF4444),
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isPasswordMatch ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                  size: 11,
                                  color: _isPasswordMatch
                                      ? const Color(0xFF6EE7B7)
                                      : const Color(0xFFF87171),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isPasswordMatch ? 'Match' : 'Mismatch',
                                  style: TextStyle(
                                    color: _isPasswordMatch
                                        ? const Color(0xFF6EE7B7)
                                        : const Color(0xFFF87171),
                                    fontSize: 10,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm your password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscureConfirmPassword,
                      borderColor: _confirmPasswordController.text.isNotEmpty
                          ? (_isPasswordMatch
                              ? const Color(0x6610B981)
                              : const Color(0x66EF4444))
                          : null,
                      suffixIcon: IconButton(
                        splashRadius: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFF9CA3AF),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Terms and Conditions Checkbox Row
                    InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        setState(() {
                          _agreeToTerms = !_agreeToTerms;
                        });
                      },
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
                                color: _agreeToTerms
                                    ? const Color(0xFFFA6144)
                                    : const Color(0xFF323846),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: _agreeToTerms
                                      ? const Color(0xFFFA6144)
                                      : const Color(0xFF4B5563),
                                  width: 1.5,
                                ),
                              ),
                              child: _agreeToTerms
                                  ? const Icon(
                                      Icons.check,
                                      size: 13,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    'I agree to the ',
                                    style: TextStyle(
                                      color: Color(0xFF8E95A5),
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.4,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      _showToast('Terms of Service: Kebijakan penggunaan Smart Task Manager.');
                                    },
                                    child: const Text(
                                      'Terms of Service',
                                      style: TextStyle(
                                        color: Color(0xFFFF7D65),
                                        fontSize: 12,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    ' and acknowledge the ',
                                    style: TextStyle(
                                      color: Color(0xFF8E95A5),
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.4,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      _showToast('Privacy Policy: Data identitas mahasiswa dilindungi.');
                                    },
                                    child: const Text(
                                      'Privacy Policy.',
                                      style: TextStyle(
                                        color: Color(0xFFFF7D65),
                                        fontSize: 12,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
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
                    const SizedBox(height: 24),

                    // Submit Register Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: _isLoading ? null : _handleRegister,
                        child: Ink(
                          width: double.infinity,
                          height: 52,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFFA6144),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x59EF4444),
                                blurRadius: 18,
                                offset: Offset(0, 8),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Create Student Account',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '➔',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Already have an account? Sign In Link
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          const Text(
                            'Already have an account? ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF8E95A5),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          InkWell(
                            onTap: _navigateBack,
                            child: const Text(
                              'Sign In',
                              textAlign: TextAlign.center,
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
                    const SizedBox(height: 28),

                    // Footer Copyright
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFFD1D5DB),
        fontSize: 12.5,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    Color? borderColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: ShapeDecoration(
        color: const Color(0xFF323846),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: borderColor ?? const Color(0xFF3B4150),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            prefixIcon,
            color: const Color(0xFF9CA3AF),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
              cursorColor: const Color(0xFFFA6144),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13.5,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
          if (suffixIcon != null) suffixIcon,
        ],
      ),
    );
  }

  Widget _buildPasswordStrengthCard() {
    final score = _passwordStrengthScore;
    final color = _passwordStrengthColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: ShapeDecoration(
        color: const Color(0xFF2D333F),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFF3B4150),
          ),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PASSWORD STRENGTH',
                style: TextStyle(
                  color: Color(0xFF8E95A5),
                  fontSize: 11,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                _passwordStrengthLabel,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 4-segment strength bar
          Row(
            children: List.generate(4, (index) {
              final isFilled = (index + 1) <= score;
              return Expanded(
                child: Container(
                  height: 4.5,
                  margin: EdgeInsets.only(
                    right: index < 3 ? 4 : 0,
                  ),
                  decoration: ShapeDecoration(
                    color: isFilled ? color : const Color(0xFF3F4756),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          // Requirements List
          _buildRequirementItem(
            isMet: _hasMinLength,
            label: 'At least 8 characters long (recommended 12+)',
          ),
          const SizedBox(height: 6),
          _buildRequirementItem(
            isMet: _hasUpperAndLower,
            label: 'Includes uppercase & lowercase letters',
          ),
          const SizedBox(height: 6),
          _buildRequirementItem(
            isMet: _hasNumberAndSpecial,
            label: 'Includes at least one number and special symbol (#, !, @)',
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem({required bool isMet, required String label}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: ShapeDecoration(
            color: isMet ? const Color(0x3310B981) : const Color(0xFF383F4D),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: isMet ? const Color(0x6610B981) : const Color(0xFF4B5563),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            isMet ? Icons.check : Icons.circle,
            size: isMet ? 11 : 4,
            color: isMet ? const Color(0xFF10B981) : const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isMet ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280),
              fontSize: 11,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}