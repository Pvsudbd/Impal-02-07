import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/features/auth/login_page.dart';
import 'presentation/features/dashboard/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
  final savedUser = prefs.getString('auth_user') ?? 'Jarvis';

  // Also check URL hash fragment (e.g. #/home)
  final fragment = Uri.base.fragment;
  final shouldOpenHome = isLoggedIn || fragment.contains('home');

  runApp(MyApp(
    initialHome: shouldOpenHome ? HomePage(userName: savedUser) : const Login(),
  ));
}

class MyApp extends StatelessWidget {
  final Widget initialHome;

  const MyApp({super.key, required this.initialHome});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IMPAL To-Do List',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF282D37),
        fontFamily: 'Inter',
      ),
      home: initialHome,
    );
  }
}

