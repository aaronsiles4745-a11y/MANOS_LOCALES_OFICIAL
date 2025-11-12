import 'package:flutter/material.dart';

class Splash3 extends StatefulWidget {
  const Splash3({super.key});

  @override
  State<Splash3> createState() => _Splash3State();
}

class _Splash3State extends State<Splash3> {
  @override
  void initState() {
    super.initState();
    // Después de 3 segundos va al home (o al login si tenés uno)
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/');
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
              'splash_logo3',
              width: 220,
              height: 220,
            ),
          ),
        ],
      ),
    );
  }
}
