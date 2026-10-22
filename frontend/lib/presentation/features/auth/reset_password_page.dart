import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../core/utils/top_toast.dart';
import 'login_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({
    super.key,
    this.email = 'yogaperkakas@gmail.com',
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _newPasswordController.addListener(() {
      if (_newPasswordError != null) {
        setState(() => _newPasswordError = null);
      } else {
        setState(() {});
      }
    });

    _confirmPasswordController.addListener(() {
      if (_confirmPasswordError != null) {
        setState(() => _confirmPasswordError = null);
      }
    });
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Password criteria getters
  bool get _hasNoSpace => !_newPasswordController.text.contains(' ');
  bool get _hasMinLength => _newPasswordController.text.length >= 8;
  bool get _hasUpperLower =>
      RegExp(r'[a-z]').hasMatch(_newPasswordController.text) &&
      RegExp(r'[A-Z]').hasMatch(_newPasswordController.text);
  bool get _hasNumSymbol =>
      RegExp(r'[0-9]').hasMatch(_newPasswordController.text) &&
      RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(_newPasswordController.text);

  bool get _isPasswordValid =>
      _hasNoSpace && _hasMinLength && _hasUpperLower && _hasNumSymbol;

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

  Future<void> _handleSavePassword() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    String? newPassErr;
    String? confirmPassErr;

    if (newPassword.isEmpty) {
      newPassErr = 'New password is required';
    } else if (!_hasNoSpace) {
      newPassErr = 'Password cannot contain spaces';
    } else if (!_isPasswordValid) {
      newPassErr = 'Password does not meet all security criteria';
    }

    if (confirmPassword.isEmpty) {
      confirmPassErr = 'Please confirm your new password';
    } else if (newPassword != confirmPassword) {
      confirmPassErr = 'Passwords do not match';
    }

    setState(() {
      _newPasswordError = newPassErr;
      _confirmPasswordError = confirmPassErr;
    });

    if (newPassErr != null || confirmPassErr != null) {
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    setState(() => _isLoading = false);

    showTopToast(
      context,
      'Password successfully reset! You can now sign in.',
      type: ToastType.success,
    );

    Navigator.pushAndRemoveUntil(
      context,
      AuthFadeRoute(page: const Login()),
      (route) => false,
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
          'Create New Password',
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
          const SizedBox(height: 24),
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
                              Icons.lock_reset_rounded,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Reset Your Password',
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
                          const SizedBox(
                            width: 320,
                            child: Text(
                              'Please create a new password. Make sure it satisfies all security criteria below.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF8E95A5),
                                fontSize: 12.5,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // New Password Label & Input
                    const Text(
                      'New Password',
                      style: TextStyle(
                        color: Color(0xFFD1D5DB),
                        fontSize: 12.5,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildPasswordField(
                      controller: _newPasswordController,
                      hint: 'Enter your new password',
                      obscureText: _obscureNewPassword,
                      errorText: _newPasswordError,
                      onToggleObscure: () {
                        setState(() => _obscureNewPassword = !_obscureNewPassword);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Confirm New Password Label & Input
                    const Text(
                      'Confirm New Password',
                      style: TextStyle(
                        color: Color(0xFFD1D5DB),
                        fontSize: 12.5,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      hint: 'Re-enter your new password',
                      obscureText: _obscureConfirmPassword,
                      errorText: _confirmPasswordError,
                      onToggleObscure: () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password Criteria Checklist Box
                    _buildPasswordChecklist(),

                    const SizedBox(height: 24),

                    // Save Password & Sign In Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _isLoading ? null : _handleSavePassword,
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
                                : const Text(
                                    'Save Password & Sign In',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Remember your previous password? Back to Sign In
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

                    const SizedBox(height: 24),

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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleObscure,
    String? errorText,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;

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
              color: hasError ? const Color(0xFFEF4444) : const Color(0xFF3B4150),
              width: hasError ? 1.4 : 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 20,
                color: hasError ? const Color(0xFFEF4444) : const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  enableInteractiveSelection: false,
                  contextMenuBuilder: (context, editableTextState) => const SizedBox.shrink(),
                  onTap: TopToast.dismiss,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                  cursorColor: const Color(0xFFFA6144),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13.5,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
              IconButton(
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                icon: Icon(
                  obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: const Color(0xFF9CA3AF),
                ),
                onPressed: onToggleObscure,
              ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
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
                    errorText,
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
      ],
    );
  }

  Widget _buildPasswordChecklist() {
    final hasInput = _newPasswordController.text.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF374151),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _checklistRow(
            label: 'Minimum 8 characters',
            isSatisfied: hasInput && _hasMinLength,
          ),
          const SizedBox(height: 4),
          _checklistRow(
            label: 'Contains uppercase & lowercase letters',
            isSatisfied: hasInput && _hasUpperLower,
          ),
          const SizedBox(height: 4),
          _checklistRow(
            label: 'Contains at least one number & special symbol',
            isSatisfied: hasInput && _hasNumSymbol,
          ),
          const SizedBox(height: 4),
          _checklistRow(
            label: 'No spaces allowed',
            isSatisfied: hasInput && _hasNoSpace,
          ),
        ],
      ),
    );
  }

  Widget _checklistRow({required String label, required bool isSatisfied}) {
    return Row(
      children: [
        Text(
          isSatisfied ? '✓ ' : '• ',
          style: TextStyle(
            color: isSatisfied ? const Color(0xFF6EE7B7) : const Color(0xFF6B7280),
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isSatisfied ? const Color(0xFF6EE7B7) : const Color(0xFF8E95A5),
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
