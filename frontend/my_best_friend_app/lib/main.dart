import 'package:flutter/material.dart';
import 'pantallas/introduccion.dart';

// Punto de entrada de la aplicación My Best Friend.
// Arranca en la pantalla de inicio de sesión y utiliza el tema verde de la app.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Best Friend',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
      ),
      home: OnboardingScreens(),
    );
  }
}
