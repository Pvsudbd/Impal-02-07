import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/unfocus_on_tap.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import 'login_page.dart';
import 'widgets/auth_card_wrapper.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/password_strength_card.dart';

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

    PopUpPemberitahuan.passwordUpdated(context);
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      AuthFadeRoute(page: const Login()),
      (route) => false,
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
                    'Create New Password',
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

              // Hero Lock Icon & Title
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
                          color: AppColors.textMuted,
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

              // New Password Field
              AuthTextField(
                label: 'New Password',
                hintText: 'Enter your new password',
                prefixIcon: Icons.lock_outline_rounded,
                controller: _newPasswordController,
                isPassword: true,
                errorText: _newPasswordError,
              ),

              const SizedBox(height: 16),

              // Confirm New Password Field
              AuthTextField(
                label: 'Confirm New Password',
                hintText: 'Re-enter your new password',
                prefixIcon: Icons.lock_outline_rounded,
                controller: _confirmPasswordController,
                isPassword: true,
                errorText: _confirmPasswordError,
              ),

              const SizedBox(height: 16),

              // Password Strength & Criteria Checklist
              PasswordStrengthCard(password: _newPasswordController.text),

              const SizedBox(height: 24),

              // Save Password Button
              AppButton(
                text: 'Save Password & Sign In',
                isLoading: _isLoading,
                suffixIcon: const Text(
                  '➔',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: _handleSavePassword,
              ),

              const SizedBox(height: 20),

              // Remember your previous password? Back to Sign In
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
