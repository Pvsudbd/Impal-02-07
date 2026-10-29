import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../core/utils/top_toast.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import '../dashboard/home_page.dart';
import 'forgot_password_page.dart';
import 'regist_page.dart';
import 'widgets/auth_brand_header.dart';
import 'widgets/auth_card_wrapper.dart';
import 'widgets/auth_text_field.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  bool _rememberMe = false;
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

  void _handleSignIn() {
    if (_isLoading) return;
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    String? userErr;
    String? pwdErr;

    if (username.isEmpty) {
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

    if (userErr != null || pwdErr != null) {
      return;
    }

    setState(() => _isLoading = true);
    PopUpPemberitahuan.loginSuccess(
      context,
      username: username,
    );

    final finalUser = username.isNotEmpty ? username : 'Jarvis';
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('is_logged_in', true);
      prefs.setString('auth_user', finalUser);
    });

    Navigator.pushReplacement(
      context,
      AuthFadeRoute(
        page: HomePage(
          userName: finalUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthCardWrapper(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Signature Brand Header
          const AuthBrandHeader(),

          // 2. Credentials Form
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthTextField(
                label: 'Username or Email',
                controller: _usernameController,
                hintText: 'Enter your student ID or email',
                prefixIcon: Icons.person_outline_rounded,
                errorText: _usernameError,
                onTap: TopToast.dismiss,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: 'Password',
                controller: _passwordController,
                hintText: 'Enter your password',
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
                errorText: _passwordError,
                inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                onTap: TopToast.dismiss,
              ),
              const SizedBox(height: 16),

              // 3. Remember Me & Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => setState(() => _rememberMe = !_rememberMe),
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
                                  ? const Icon(Icons.check, size: 13, color: Colors.white)
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

              // 4. Interactive Sign In Button (anti-double submit & loading label retention)
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
                          ? const Color(0xFFFA6144).withValues(alpha: 0.7)
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isLoading) ...[
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        const Text(
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
                        if (!_isLoading) ...[
                          const SizedBox(width: 8),
                          const Text(
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
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 5. Register Link
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
    );
  }
}
