import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../core/utils/top_toast.dart';
import '../../../data/datasources/auth_remote_datasource.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import '../dashboard/home_page.dart';
import 'forgot_password_page.dart';
import 'regist_page.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  String? _usernameError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _usernameController.addListener(() {
      if (_usernameError != null) setState(() => _usernameError = null);
    });
    _passwordController.addListener(() {
      if (_passwordError != null) setState(() => _passwordError = null);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text;

    String? userErr;
    String? pwdErr;

    if (email.isEmpty) {
      userErr = 'Username or email is required';
    }
    if (password.isEmpty) {
      pwdErr = 'Password is required';
    } else if (password.contains(' ')) {
      pwdErr = 'Password cannot contain spaces';
    }

    setState(() {
      _usernameError = userErr;
      _passwordError = pwdErr;
    });

    if (userErr != null || pwdErr != null) return;

    setState(() => _isLoading = true);

    try {
      final result = await AuthRemoteDatasource.login(
        email: email,
        password: password,
      );

      final token = result['token'] as String;
      final user = result['user'] as Map<String, dynamic>;
      final userName = user['name'] as String? ?? email;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('auth_token', token);
      await prefs.setString('auth_user', userName);

      if (!mounted) return;

      PopUpPemberitahuan.loginSuccess(
        context,
        username: userName,
      );

      Navigator.pushReplacement(
        context,
        AuthFadeRoute(page: HomePage(userName: userName)),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      PopUpPemberitahuan.error(
        context,
        title: 'Login Gagal',
        message: msg,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: isMobile ? const Color(0xFF282D37) : const Color(0xFF1E222B),
      body: SafeArea(
        child: LayoutBuilder(
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
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20 : 16,
                      vertical: isMobile ? 20 : 32,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 440,
                        ),
                        child: RepaintBoundary(
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
                                        blurRadius: 18,
                                        offset: Offset(0, 10),
                                        spreadRadius: -2,
                                      )
                                    ],
                                  ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Header & Logo
                    Container(
                      width: 64,
                      height: 64,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFFA6144) /* Primary Accent */,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x59EF4444),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '⚡',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Smart Task Manager',
                      textAlign: TextAlign.center,
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
                      'AI-Driven Academic Task & Schedule\nPrioritization System',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Form Inputs
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username Field
                        const Text(
                          'Username or Email',
                          style: TextStyle(
                            color: Color(0xFFD1D5DB),
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: ShapeDecoration(
                            color: const Color(0xFF323846),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: _usernameError != null ? 1.4 : 1,
                                color: _usernameError != null ? const Color(0xFFEF4444) : const Color(0xFF3B4150),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                color: _usernameError != null ? const Color(0xFFEF4444) : const Color(0xFF9CA3AF),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _usernameController,
                                  onTap: TopToast.dismiss,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  cursorColor: const Color(0xFFFA6144),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    hintText: 'Enter username or email',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 13.5,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_usernameError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, size: 13, color: Color(0xFFEF4444)),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    _usernameError!,
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
                        const SizedBox(height: 16),

                        // Password Field
                        const Text(
                          'Password',
                          style: TextStyle(
                            color: Color(0xFFD1D5DB),
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: ShapeDecoration(
                            color: const Color(0xFF323846),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: _passwordError != null ? 1.4 : 1,
                                color: _passwordError != null ? const Color(0xFFEF4444) : const Color(0xFF3B4150),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                color: _passwordError != null ? const Color(0xFFEF4444) : const Color(0xFF9CA3AF),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  enableInteractiveSelection: false,
                                  contextMenuBuilder: (context, editableTextState) => const SizedBox.shrink(),
                                  onTap: TopToast.dismiss,
                                  inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  cursorColor: const Color(0xFFFA6144),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    hintText: 'Enter your password',
                                    hintStyle: TextStyle(
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
                            ],
                          ),
                        ),
                        if (_passwordError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, size: 13, color: Color(0xFFEF4444)),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    _passwordError!,
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
                        const SizedBox(height: 16),

                        // Checkbox & Forgot Password Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Clickable Remember Me Checkbox
                            Flexible(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: () {
                                  setState(() {
                                    _rememberMe = !_rememberMe;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: _rememberMe
                                              ? const Color(0xFFFA6144)
                                              : const Color(0xFF323846),
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                            color: _rememberMe
                                              ? const Color(0xFFFA6144)
                                              : const Color(0xFF4B5563),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: _rememberMe
                                            ? const Icon(
                                                Icons.check,
                                                size: 13,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 8),
                                      const Flexible(
                                        child: Text(
                                          'Remember me',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Color(0xFFD1D5DB),
                                            fontSize: 12,
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
                            const SizedBox(width: 8),

                            // Forgot Password Link
                            InkWell(
                              borderRadius: BorderRadius.circular(4),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  AuthFadeRoute(page: const ForgotPassword()),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    color: Color(0xFFFF7D65),
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Interactive Sign In Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _isLoading ? null : _handleSignIn,
                            child: Ink(
                              width: double.infinity,
                              height: 48,
                              decoration: ShapeDecoration(
                                color: _isLoading
                                    ? const Color(0x99FA6144)
                                    : const Color(0xFFFA6144),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
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
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Sign In to Dashboard',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.15,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '➔',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),

                        // Register Link
                        SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              const Text(
                                'Don’t have an account? ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF8E95A5),
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    AuthFadeRoute(
                                      page: const Register(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Register Now',
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      const Spacer(),
      const Padding(
        padding: EdgeInsets.only(bottom: 24, top: 12),
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
);
},
),
),
);
}
}