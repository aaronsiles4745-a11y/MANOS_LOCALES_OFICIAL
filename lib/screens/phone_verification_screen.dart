import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/phone_verification_service.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _codeController = TextEditingController();
  final _phoneService = PhoneVerificationService();
  String? _userId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final sp = await SharedPreferences.getInstance();
    setState(() => _userId = sp.getString('userId'));
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.isEmpty || _userId == null) return;

    setState(() => _loading = true);
    try {
      final success = await _phoneService.verifyCode(
        userId: _userId!,
        code: _codeController.text.trim(),
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Teléfono verificado correctamente ✅')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código incorrecto ❌')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.toString()), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _loading = false);
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
              const Icon(Icons.sms, color: Colors.white, size: 100),
              const SizedBox(height: 30),
              const Text(
                'Verificación de teléfono',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _codeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Código SMS',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : ElevatedButton(
                      onPressed: _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: azulPrincipal,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Verificar código',
                          style: TextStyle(color: Colors.white)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
