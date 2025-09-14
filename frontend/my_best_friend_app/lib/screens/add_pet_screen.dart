import 'package:flutter/material.dart';

class AddPetScreen extends StatelessWidget {
  const AddPetScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar mascota'), backgroundColor: const Color(0xFF4CAF50), elevation: 0),
      backgroundColor: const Color(0xFF4CAF50),
      body: const Center(
        child: Text('Formulario de nueva mascota (pendiente)',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
