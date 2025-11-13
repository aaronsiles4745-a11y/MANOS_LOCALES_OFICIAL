import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/phone_verification_service.dart';
import '../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();
  final _phone = TextEditingController();
  bool _accepted = false;
  bool _loading = false;

  final AuthService _authService = AuthService();
  final PhoneVerificationService _phoneService = PhoneVerificationService();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar los términos')),
      );
      return;
    }

    if (_pass.text != _pass2.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // ✅ Formatear número
      String phoneNumber = _phone.text.trim();
      if (!phoneNumber.startsWith('+54')) {
        if (phoneNumber.startsWith('0')) phoneNumber = phoneNumber.substring(1);
        phoneNumber = '+54$phoneNumber';
      }

      // 🔐 Crear usuario
      final UserModel? newUser = await _authService.signUp(
        email: _email.text.trim(),
        password: _pass.text.trim(),
        name: _name.text.trim(),
        phone: phoneNumber,
      );

      if (newUser == null) throw 'Error al crear usuario';

      // ✉️ Enviar correo de verificación
      await _authService.sendEmailVerification();

      // 📲 Enviar SMS de verificación
      await _phoneService.sendVerificationCode(
        userId: newUser.userId,
        phone: phoneNumber,
      );

      // 💾 Guardar userId localmente
      final sp = await SharedPreferences.getInstance();
      await sp.setString('userId', newUser.userId);
      await sp.setBool('loggedIn', false); // aún no logueado

      if (!mounted) return;

      // 🚀 Ir a verificación de email (de ahí pasa a teléfono)
      Navigator.pushReplacementNamed(context, '/verify-email');
    } catch (e) {
      String msg = e.toString();
      if (msg.contains('email address is already in use')) {
        msg =
            'Este correo ya está registrado. Iniciá sesión o usá otro correo.';
      } else if (msg.contains('network')) {
        msg = 'Error de conexión. Verificá tu internet.';
      } else if (msg.contains('password')) {
        msg = 'La contraseña es demasiado débil.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrarse: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final azulPrincipal = const Color(0xFF1976D2);
    final azulClaro = const Color(0xFF64B5F6);
    final fondoOscuro = const Color(0xFF0A0E21);

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
                  // LOGO
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
                    'CREAR CUENTA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // CAMPOS
                  _buildInput(_name, 'Nombre de usuario'),
                  const SizedBox(height: 12),
                  _buildInput(_email, 'Email',
                      inputType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  _buildInput(_pass, 'Contraseña', obscure: true),
                  const SizedBox(height: 12),
                  _buildInput(_pass2, 'Repetir contraseña', obscure: true),
                  const SizedBox(height: 12),
                  _buildInput(_phone, 'Número de teléfono',
                      inputType: TextInputType.phone),

                  const SizedBox(height: 16),

                  // TÉRMINOS
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _accepted,
                        activeColor: azulPrincipal,
                        onChanged: (v) =>
                            setState(() => _accepted = v ?? false),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/terms'),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                              children: [
                                const TextSpan(
                                    text: 'Al crear una cuenta, acepta los '),
                                TextSpan(
                                  text: 'términos y condiciones',
                                  style: TextStyle(
                                    color: azulClaro,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const TextSpan(text: ' de la empresa.'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // BOTÓN
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
                            onPressed: _submit,
                            child: const Text(
                              'Registrarse',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                  const SizedBox(height: 18),

                  // LINK LOGIN
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.white70),
                        children: [
                          const TextSpan(text: '¿Ya tienes una cuenta? '),
                          TextSpan(
                            text: 'Iniciar sesión',
                            style: TextStyle(
                              color: azulClaro,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
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

  // Campo de texto reutilizable
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
        if (label.toLowerCase().contains('email') &&
            !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
          return 'Email inválido';
        }
        if (label.toLowerCase().contains('contraseña') && v.length < 6) {
          return 'Mínimo 6 caracteres';
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
