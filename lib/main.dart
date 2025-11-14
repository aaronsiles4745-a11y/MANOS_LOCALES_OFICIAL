import 'package:flutter/material.dart';
import 'package:manos_locales/screens/home_dashboard_screen.dart';
import 'package:manos_locales/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'app.dart'; // o donde esté tu MaterialApp
import 'package:manos_locales/services/auth_service.dart';
import 'package:manos_locales/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'package:manos_locales/app.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Onboarding Demo',
      theme: ThemeData.dark(),
      home: const Onboarding1Screen(),
      routes: {
        '/onboarding2': (context) => const Onboarding2Screen(),
        '/onboarding3': (context) => const Onboarding3Screen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeDashboardScreen(),
      },
    );
  }
}


// --- ONBOARDING 1 ---
class Onboarding1Screen extends StatelessWidget {
  const Onboarding1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return _OnboardingBase(
      image: 'assets/images/inicio1.png',
      title: 'Resolvé tus necesidades de forma ágil y con bajo costo',
      subtitle:
          'Buscá por categoría, compará opciones y contactá directamente a la persona indicada.',
      activeIndex: 0,
      onNext: () => Navigator.pushNamed(context, '/onboarding2'),
      onBack: null,
    );
  }
}

// --- ONBOARDING 2 ---
class Onboarding2Screen extends StatelessWidget {
  const Onboarding2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return _OnboardingBase(
      image: 'assets/images/inicio2.png',
      title: 'Conectá con servicios confiables cerca tuyo',
      subtitle:
          'Visualizá perfiles, valoraciones y experiencia para elegir mejor.',
      activeIndex: 1,
      onNext: () => Navigator.pushNamed(context, '/onboarding3'),
      onBack: () => Navigator.pop(context),
    );
  }
}

// --- ONBOARDING 3 ---
class Onboarding3Screen extends StatelessWidget {
  const Onboarding3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return _OnboardingBase(
      image: 'assets/images/inicio3.png',
      title: 'Empezá a usar la app y resolvé todo desde un solo lugar',
      subtitle:
          'Registrate o iniciá sesión para acceder a todos los beneficios.',
      activeIndex: 2,
      onNext: () =>
          Navigator.pushReplacementNamed(context, '/login'), // Ir al login
      onBack: () => Navigator.pop(context),
    );
  }
}

// --- PLANTILLA BASE ---
class _OnboardingBase extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final int activeIndex;
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const _OnboardingBase({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.activeIndex,
    this.onNext,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0E1220), Color(0xFF0F1630)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo de la app
                  Image.asset(
                    'assets/images/logo.png',
                    height: 80,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.store, size: 60),
                  ),
                  const SizedBox(height: 24),
                  // Imagen principal
                  Image.asset(image, height: 240),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, height: 1.4),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (onBack != null)
                        _circleButton(Icons.arrow_back, onBack!)
                      else
                        const SizedBox(width: 48),
                      Row(
                        children: List.generate(3, (i) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == activeIndex
                                  ? const Color(0xFF5B6BFF)
                                  : Colors.white24,
                            ),
                          );
                        }),
                      ),
                      _circleButton(
                          activeIndex == 2 ? Icons.check : Icons.arrow_forward,
                          onNext!),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white10,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
