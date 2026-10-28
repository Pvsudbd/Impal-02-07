import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../core/utils/top_toast.dart';
import 'login_page.dart';
import 'verification_code_page.dart';
import 'widgets/auth_card_wrapper.dart';
import 'widgets/auth_notice_banner.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/recovery_method_card.dart';

enum RecoveryMethod { email, sms }

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  RecoveryMethod _selectedMethod = RecoveryMethod.email;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _countryCode = '+62';
  bool _isLoading = false;

  String? _emailError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      if (_emailError != null) setState(() => _emailError = null);
    });
    _phoneController.addListener(() {
      if (_phoneError != null) setState(() => _phoneError = null);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _navigateBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(context, AuthFadeRoute(page: const Login()));
    }
  }

  void _navigateToSignIn() {
    Navigator.pushReplacement(context, AuthFadeRoute(page: const Login()));
  }

  void _showHelpInfo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF282D37),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.help_outline_rounded, color: Color(0xFFFA6144), size: 22),
            SizedBox(width: 8),
            Text(
              'Need Help?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: const Text(
          'If you no longer have access to your registered student email or phone number, please contact your Telkom University campus academic administrator.',
          style: TextStyle(
            color: Color(0xFFD1D5DB),
            fontSize: 13,
            fontFamily: 'Inter',
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Dismiss', style: TextStyle(color: Color(0xFFFA6144), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSendRecovery() async {
    if (_isLoading) return;

    if (_selectedMethod == RecoveryMethod.email) {
      final text = _emailController.text.trim();
      if (text.isEmpty) {
        setState(() => _emailError = 'Please enter your email or Student ID');
        return;
      }
      final isEmailFormat = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(text);
      final isStudentIdFormat = RegExp(r'^\d{8,14}$').hasMatch(text);

      if (!isEmailFormat && !isStudentIdFormat) {
        setState(() => _emailError = 'Enter a valid email address or 8-14 digit Student ID');
        return;
      }
    } else {
      final phone = _phoneController.text.trim();
      if (phone.isEmpty) {
        setState(() => _phoneError = 'Please enter your phone number');
        return;
      }
      if (phone.length < 8 || phone.length > 14) {
        setState(() => _phoneError = 'Phone number must be between 8 and 14 digits');
        return;
      }
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isLoading = false);

    final targetDestination = _selectedMethod == RecoveryMethod.email
        ? _emailController.text.trim()
        : '$_countryCode ${_phoneController.text.trim()}';

    Navigator.push(
      context,
      AuthFadeRoute(
        page: VerificationCodePage(
          destination: targetDestination,
          isPhone: _selectedMethod == RecoveryMethod.sms,
        ),
      ),
    );
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
        InkWell(
          onTap: _showHelpInfo,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'Help?',
              style: TextStyle(
                color: Color(0xFFFA6144),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
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
          // Hero Icon, Title, Subtitle
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
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
                  'Forgot Password?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const SizedBox(
                  width: 320,
                  child: Text(
                    'Choose where you would like to receive password recovery instructions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF8E95A5),
                      fontSize: 13,
                      fontFamily: 'Inter',
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recovery Method Selectors
          RecoveryMethodCard(
            isSelected: _selectedMethod == RecoveryMethod.email,
            title: 'Send Link via Email',
            subtitle: 'Recovery link sent to your registered academic email',
            icon: Icons.mail_outline_rounded,
            onTap: () => setState(() {
              _selectedMethod = RecoveryMethod.email;
              _emailError = null;
              _phoneError = null;
            }),
          ),
          const SizedBox(height: 10),
          RecoveryMethodCard(
            isSelected: _selectedMethod == RecoveryMethod.sms,
            title: 'Send 6-Digit Code via SMS',
            subtitle: 'Receive confirmation code on your mobile phone',
            icon: Icons.chat_bubble_outline_rounded,
            onTap: () => setState(() {
              _selectedMethod = RecoveryMethod.sms;
              _emailError = null;
              _phoneError = null;
            }),
          ),
          const SizedBox(height: 16),

          // Dynamic Form Input
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _selectedMethod == RecoveryMethod.email
                ? AuthTextField(
                    key: const ValueKey('email_form'),
                    label: 'Email or Student ID',
                    controller: _emailController,
                    hintText: 'Enter registered email or Student ID',
                    prefixIcon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                    onTap: TopToast.dismiss,
                  )
                : _buildPhoneForm(),
          ),
          const SizedBox(height: 16),

          // Notice Banner
          AuthNoticeBanner(
            title: 'Important',
            message: _selectedMethod == RecoveryMethod.email
                ? 'Recovery links remain valid for 5 minutes. If you cannot locate the message, check your Junk/Spam folder.'
                : 'SMS verification codes remain valid for 5 minutes. Make sure your device has active cellular reception.',
          ),
          const SizedBox(height: 24),

          // Submit Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _isLoading ? null : _handleSendRecovery,
              child: Ink(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFA6144),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Color(0x59EF4444), blurRadius: 18, offset: Offset(0, 8)),
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
                      Text(
                        _selectedMethod == RecoveryMethod.email
                            ? 'Send Recovery Code'
                            : 'Send 6-Digit Code',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.15,
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

          // Remembered password? Sign In Link
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                const Text(
                  'Remembered your password? ',
                  style: TextStyle(
                    color: Color(0xFF8E95A5),
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
                InkWell(
                  onTap: _navigateToSignIn,
                  child: const Text(
                    'Sign In',
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
        ],
      ),
    );
  }

  Widget _buildPhoneForm() {
    final hasError = _phoneError != null && _phoneError!.isNotEmpty;

    return Column(
      key: const ValueKey('phone_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Phone Number',
          style: TextStyle(
            color: Color(0xFFD1D5DB),
            fontSize: 13,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF323846),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? const Color(0xFFEF4444) : const Color(0xFF3B4150),
              width: hasError ? 1.4 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                height: double.infinity,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Color(0xFF3B4150))),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _countryCode,
                    dropdownColor: const Color(0xFF282D37),
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Inter'),
                    items: const [
                      DropdownMenuItem(value: '+62', child: Text('🇮🇩 +62')),
                      DropdownMenuItem(value: '+60', child: Text('🇲🇾 +60')),
                      DropdownMenuItem(value: '+65', child: Text('🇸🇬 +65')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _countryCode = val);
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Inter'),
                    cursorColor: const Color(0xFFFA6144),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '812-3456-7890',
                      hintStyle: TextStyle(color: Color(0xFF6B7280), fontSize: 13.5, fontFamily: 'Inter'),
                      isDense: true,
                    ),
                  ),
                ),
              ),
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
                    _phoneError!,
                    style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11.5, fontFamily: 'Inter'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
