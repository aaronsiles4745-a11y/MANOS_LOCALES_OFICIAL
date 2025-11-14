import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String? _phoneMasked;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final sp = await SharedPreferences.getInstance();
    final uid = sp.getString('userId');
    setState(() => _userId = uid);

    if (uid != null) {
      try {
        final doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final phone = doc.data()?['phone'] as String?;
        if (phone != null && phone.isNotEmpty) {
          setState(() => _phoneMasked = _maskPhone(phone));
        }
      } catch (_) {}
    }
  }

  String _maskPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 4) {
      final last = digits.substring(digits.length - 4);
      final prefix = phone.replaceAll(last, '');
      return '$prefix••••$last';
    }
    return phone;
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingresa el código recibido')));
      return;
    }

    setState(() => _loading = true);

    try {
      final ok = await _phoneService.verifyCode(_codeController.text.trim());
      if (ok) {
        // marcar como logueado localmente
        final sp = await SharedPreferences.getInstance();
        await sp.setBool('loggedIn', true);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Teléfono verificado ✅')));
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Código incorrecto ❌')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error al verificar: $e'),
            backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendCode() async {
    if (_userId == null) return;

    setState(() => _loading = true);
    try {
      // obtener teléfono desde firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();
      final phone = doc.data()?['phone'] as String?;
      if (phone == null) throw 'No se encontró número telefónico';

      await _phoneService.resendOTP(phone);

      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Código reenviado ✅')));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error al reenviar: $e'),
            backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _loading = false);
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
              const Text('Verificación de teléfono',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (_phoneMasked != null)
                Text('Se envió un SMS a $_phoneMasked',
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center),
              const SizedBox(height: 20),
              TextField(
                controller: _codeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Código SMS',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: _verifyCode,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: azulPrincipal,
                              minimumSize: const Size(double.infinity, 48)),
                          child: const Text('Verificar código',
                              style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _resendCode,
                            style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white),
                                minimumSize: const Size(double.infinity, 48)),
                            child: const Text('Reenviar código',
                                style: TextStyle(color: Colors.white)),
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
