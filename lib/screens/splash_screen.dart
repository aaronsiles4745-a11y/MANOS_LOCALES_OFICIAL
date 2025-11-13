// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startApp();
    });
  }

  Future<void> _startApp() async {
    await Future.delayed(const Duration(seconds: 2));

    final sp = await SharedPreferences.getInstance();
    final bool seenOnboarding = sp.getBool('seenOnboarding') ?? false;
    final bool acceptedTerms = sp.getBool('acceptedTerms') ?? false;

    // Preferimos la fuente de verdad: FirebaseAuth (vía AuthService.currentUser)
    final isLogged =
        _authService.currentUser != null || (sp.getBool('loggedIn') ?? false);

    String nextRoute;
    if (!seenOnboarding) {
      nextRoute = '/onboarding1';
    } else if (!acceptedTerms) {
      nextRoute = '/terms';
    } else if (!isLogged) {
      nextRoute = '/login';
    } else {
      nextRoute = '/home';
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1220),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 250,
              height: 250,
              errorBuilder: (_, __, ___) => const Icon(Icons.store, size: 100),
            ),
            const SizedBox(height: 20),
            const Text(
              'Manos Locales',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: Color(0xFF5B6BFF)),
          ],
        ),
      ),
    );
  }
}
