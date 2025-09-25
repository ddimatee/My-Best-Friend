import 'package:flutter/material.dart';

// Wrapper en español para pantallas de funcionalidades aún no implementadas.
class PlaceholderFuncionPantalla extends StatelessWidget {
  final String title;
  const PlaceholderFuncionPantalla({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Pantalla en construcción',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
