import 'package:flutter/material.dart';

class Splash2 extends StatefulWidget {
  const Splash2({super.key});

  @override
  State<Splash2> createState() => _Splash2State();
}

class _Splash2State extends State<Splash2> {
  @override
  void initState() {
    super.initState();
    // Cambia automáticamente a Splash3 después de 2.5 segundos
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/splash3');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'fondodeapp.jpg',
            fit: BoxFit.cover,
          ),
          Center(
            child: Image.asset(
              'splash_logo2',
              width: 200,
              height: 200,
            ),
          ),
        ],
      ),
    );
  }
}
