import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthService _authService = AuthService();
  bool _isVerifying = false;
  bool _emailVerified = false;

  @override
  void initState() {
    super.initState();
    _checkEmailVerified();
  }

  Future<void> _checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {
      _emailVerified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    });

    if (_emailVerified && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo verificado correctamente ✅')),
      );
      Navigator.pushReplacementNamed(context, '/verify-phone');
    }
  }

  Future<void> _sendVerificationEmail() async {
    setState(() => _isVerifying = true);
    try {
      await _authService.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correo de verificación enviado. Revisa tu bandeja.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final azulPrincipal = const Color(0xFF1976D2);
    final fondoOscuro = const Color(0xFF0A0E21);

    return Scaffold(
      backgroundColor: fondoOscuro,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_read, color: Colors.white, size: 100),
              const SizedBox(height: 30),
              const Text(
                'Verificación de correo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Te enviamos un correo con un enlace de verificación.\n'
                'Haz clic en el enlace y luego presiona "Ya verifiqué".',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _isVerifying
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: _sendVerificationEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: azulPrincipal,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: const Text(
                            'Reenviar correo',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: _checkEmailVerified,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: const Text(
                            'Ya verifiqué',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
