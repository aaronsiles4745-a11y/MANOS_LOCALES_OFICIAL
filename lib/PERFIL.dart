import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/profile_screen.dart';
import 'firebase_options.dart'; // <- se genera automÃ¡ticamente
import 'services/user_service.dart';

final _userService = UserService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
    Firebase.app();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Manos Locales',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      // Arranca directamente en la pantalla de perfil
      home: const InitialScreen(),
      routes: {
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}

Future<void> _signInAnonAndEnsureProfile() async {
  final cred = await FirebaseAuth.instance.signInAnonymously();
  await _userService.ensureUserDocument(cred.user!);
}

/// Esta pantalla verifica si hay un usuario logueado y redirige al perfil.
class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return ProfileScreen();
        } else {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  final cred = await FirebaseAuth.instance.signInAnonymously();
                  await UserService().ensureUserDocument(cred.user!);
                },
                child: const Text("Entrar anónimamente"),
              ),
            ),
          );
        }
      },
    );
  }
}
