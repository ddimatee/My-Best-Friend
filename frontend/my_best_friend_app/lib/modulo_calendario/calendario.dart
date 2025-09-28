import 'package:flutter/material.dart';

// Wrapper en español para Calendario.
class CalendarioPantalla extends StatelessWidget {
  const CalendarioPantalla({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Calendario', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
    );
  }
}
