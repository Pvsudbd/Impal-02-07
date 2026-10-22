import 'package:flutter/material.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../core/utils/top_toast.dart';
import 'login_page.dart';
import 'verification_code_page.dart';

enum RecoveryMethod { email, sms }

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  late final TextEditingController _emailController;
  RecoveryMethod _selectedMethod = RecoveryMethod.email;
  bool _isLoading = false;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: 'YogaPerkakas@gmail.com');
    _emailController.addListener(() {
      if (_emailError != null) {
        setState(() => _emailError = null);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String _maskEmail(String email) {
    final trimmed = email.trim();
    final atIndex = trimmed.indexOf('@');
    if (atIndex <= 1) {
      return trimmed;
    }
    final prefix = trimmed.substring(0, atIndex > 3 ? 3 : 1);
    final domain = trimmed.substring(atIndex);
    return '$prefix••••••••$domain';
  }

  void _navigateBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        AuthFadeRoute(page: const Login()),
      );
    }
  }

  void _showHelpInfo() {
    showTopToast(
      context,
      'Need assistance? Contact Telkom University IT Support at it-helpdesk@telkomuniversity.ac.id',
      type: ToastType.info,
    );
  }

  Future<void> _handleSendRecovery() async {
    final email = _emailController.text.trim();

    String? error;
    if (email.isEmpty) {
      error = 'Email or Student ID is required';
    } else if (!email.contains('@') && !RegExp(r'^[0-9]+$').hasMatch(email)) {
      error = 'Please enter a valid campus email or Student ID';
    } else if (email.contains('@') &&
        !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      error = 'Invalid email address format';
    }

    if (error != null) {
      setState(() => _emailError = error);
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    setState(() => _isLoading = false);

    final destination = _selectedMethod == RecoveryMethod.email
        ? email
        : '+62 812-****-8904';

    showTopToast(
      context,
      'Recovery instructions sent to $destination!',
      type: ToastType.success,
    );

    Navigator.push(
      context,
      AuthFadeRoute(
        page: VerificationCodePage(destination: destination),
      ),
    );
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
                  vertical: isMobile ? 0 : 32,
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
                            blurRadius: 20,
                            offset: Offset(0, 10),
                            spreadRadius: -2,
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
                          'Password Recovery',
                          style: TextStyle(
                            color: Color(0xFF8E95A5),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        // Help Chip Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: _showHelpInfo,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0x19FA6144),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Help ?',
                                style: TextStyle(
                                  color: Color(0xFFFF7D65),
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Hero Section: Icon, Title, Subtitle
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
                          const SizedBox(height: 16),
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
                              'Enter your registered Student ID or campus email to receive password reset instructions.',
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

                    // Input Label
                    const Text(
                      'Email or Student ID',
                      style: TextStyle(
                        color: Color(0xFFD1D5DB),
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Input Field with Red Inline Validation Error
                    _buildEmailInput(),

                    const SizedBox(height: 16),

                    // Recovery Method Radio Cards
                    _buildMethodCard(
                      method: RecoveryMethod.email,
                      title: 'Send to Email',
                      subtitle: 'Link dispatched to ${_emailController.text.isNotEmpty ? _maskEmail(_emailController.text) : 'your campus email'}',
                      icon: Icons.mail_outline_rounded,
                    ),
                    const SizedBox(height: 10),
                    _buildMethodCard(
                      method: RecoveryMethod.sms,
                      title: 'Send 6-Digit Code via SMS',
                      subtitle: 'Dispatched to +62 812••••••••8904',
                      icon: Icons.chat_bubble_outline_rounded,
                    ),

                    const SizedBox(height: 16),

                    // Important Notice Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF323846),
                        borderRadius: BorderRadius.circular(10),
                        border: const Border(
                          left: BorderSide(
                            color: Color(0xFFFA6144),
                            width: 3.5,
                          ),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: Color(0xFFFA6144),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Important: ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      height: 1.4,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Recovery links remain valid for ',
                                    style: TextStyle(
                                      color: Color(0xFFD1D5DB),
                                      fontSize: 11.5,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.4,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '5 minutes',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      height: 1.4,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '. If you cannot locate the message, check your Junk/Spam folder.',
                                    style: TextStyle(
                                      color: Color(0xFFD1D5DB),
                                      fontSize: 11.5,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

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
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _selectedMethod == RecoveryMethod.email
                                            ? 'Send Recovery Code'
                                            : 'Send 6-Digit Code',
                                        style: const TextStyle(
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

                    const SizedBox(height: 18),

                    // Remembered your password? Sign In
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
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          InkWell(
                            onTap: _navigateBack,
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

                    const SizedBox(height: 24),

                    // Footer
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

  Widget _buildEmailInput() {
    final hasError = _emailError != null && _emailError!.isNotEmpty;

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
                Icons.mail_outline_rounded,
                size: 20,
                color: hasError ? const Color(0xFFEF4444) : const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                  cursorColor: const Color(0xFFFA6144),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Enter registered email or Student ID',
                    hintStyle: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13.5,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
              if (_emailController.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _emailController.clear();
                    setState(() {});
                  },
                  child: const Icon(
                    Icons.clear_rounded,
                    size: 16,
                    color: Color(0xFF9CA3AF),
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
                const Icon(
                  Icons.error_outline_rounded,
                  size: 13,
                  color: Color(0xFFEF4444),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    _emailError!,
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

  Widget _buildMethodCard({
    required RecoveryMethod method,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedMethod == method;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _selectedMethod = method),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF323846),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFFA6144) : const Color(0xFF3B4150),
              width: isSelected ? 1.4 : 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Custom Radio Dot
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFA6144) : const Color(0xFF6B7280),
                    width: 1.5,
                  ),
                  color: isSelected ? const Color(0x24FA6144) : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: isSelected
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFA6144),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFFE5E7EB),
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF8E95A5),
                        fontSize: 11,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                icon,
                size: 20,
                color: isSelected ? const Color(0xFFFF7D65) : const Color(0xFF6B7280),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Convenient alias
typedef ForgotPasswordPage = ForgotPassword;