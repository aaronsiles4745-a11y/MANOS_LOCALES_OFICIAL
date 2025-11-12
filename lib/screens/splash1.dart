import 'package:flutter/material.dart';

class Splash1 extends StatefulWidget {
  const Splash1({super.key});

  @override
  State<Splash1> createState() => _Splash1State();
}

class _Splash1State extends State<Splash1> {
  @override
  void initState() {
    super.initState();
    // Cambia automáticamente a Splash2 después de 2.5 segundos
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/splash2');
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
              'splash_logo1',
              width: 200,
              height: 200,
            ),
          ),
        ],
      ),
    );
  }
}
