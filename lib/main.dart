import 'package:flutter/material.dart';

import 'package:manos_locales/services/auth_service.dart';
import 'package:manos_locales/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

void main() {
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
        '/login': (context) => const LoginScreen(),
        '/onboarding2': (context) => const Onboarding2Screen(),
        '/onboarding3': (context) => const Onboarding3Screen(),
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
      subtitle: 'Visualizá perfiles, valoraciones y experiencia para elegir mejor.',
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
      subtitle: 'Registrate o iniciá sesión para acceder a todos los beneficios.',
      activeIndex: 2,
      onNext: () => Navigator.pushReplacementNamed(context, '/login'), // Ir al login
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
                    errorBuilder: (_, __, ___) => const Icon(Icons.store, size: 60),
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
                              color: i == activeIndex ? const Color(0xFF5B6BFF) : Colors.white24,
                            ),
                          );
                        }),
                      ),
                      _circleButton(
                          activeIndex == 2 ? Icons.check : Icons.arrow_forward, onNext!),
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
/ --- LOGIN ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final UserModel? userModel = await _authService.signIn(
        email: _email.text.trim(),
        password: _pass.text.trim(),
      );

      if (userModel == null) throw 'Error al iniciar sesión';

      final sp = await SharedPreferences.getInstance();
      await sp.setBool('loggedIn', true);
      await sp.setString('userId', userModel.userId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bienvenido, ${userModel.name}!')),
      );

      // Aquí vamos al HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar sesión: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const azulPrincipal = Color(0xFF1976D2);
    const azulClaro = Color(0xFF64B5F6);
    const fondoOscuro = Color(0xFF0A0E21);

    return Scaffold(
      backgroundColor: fondoOscuro,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 100,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.store, size: 80),
                    ),
                  ),
                  const Text(
                    'INICIAR SESIÓN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Inicie sesión para continuar',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 28),

                  _buildInput(
                    _email,
                    'Correo electrónico',
                    inputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  _buildInput(_pass, 'Contraseña', obscure: true),
                  const SizedBox(height: 24),

                  _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: azulPrincipal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _login,
                      child: const Text(
                        'Acceder',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: azulClaro, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/register'),
                      child: const Text(
                        'Crear cuenta',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
      TextEditingController controller,
      String label, {
        bool obscure = false,
        TextInputType inputType = TextInputType.text,
      }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: inputType,
      validator: (v) {
        if (v == null || v.isEmpty) return 'Campo obligatorio';
        if (label.toLowerCase().contains('correo') &&
            !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
          return 'Email inválido';
        }
        return null;
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white),
        ),
        filled: true,
        fillColor: Colors.white10,
      ),
    );
  }
}

// 🔹 HomeScreen integrado
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF00122B),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_rounded), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF001E4E), Color(0xFF001030)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '¡Hola Roman!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      radius: 22,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSectionCard(
                  title: "Mis servicios",
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ServiceButton(title: "Lavado de auto", onTap: () {}),
                      ServiceButton(title: "Busco personal", onTap: () {}),
                      ServiceButton(title: "Reparación de PC", onTap: () {}),
                      ServiceButton(title: "Busco niñera", onTap: () {}),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSectionCard(
                        title: "Últimos mensajes",
                        child: Column(
                          children: const [
                            MessagePreview(name: "Lucía", message: "Hola, ¿sigue disponible?"),
                            MessagePreview(name: "Mario", message: "Te envié mis datos."),
                            MessagePreview(name: "Jorge", message: "Podría empezar el lunes."),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSectionCard(
                        title: "Próximos trabajos",
                        child: Column(
                          children: const [
                            MessagePreview(name: "Niñera", message: "Mañana 10:00 AM"),
                            MessagePreview(name: "Lavado", message: "Viernes 14:00"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: "Cerca de tu zona",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hay nuevas búsquedas activas cerca de tu zona. ¡Anímate a postularte o publicar tu servicio!",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Hacer publicación",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF002C73).withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class ServiceButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const ServiceButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class MessagePreview extends StatelessWidget {
  final String name;
  final String message;

  const MessagePreview({
    super.key,
    required this.name,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.shade900.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            message,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
