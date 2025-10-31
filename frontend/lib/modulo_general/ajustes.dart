import 'package:flutter/material.dart';

// Wrapper en español para Ajustes.
class AjustesPantalla extends StatelessWidget {
  const AjustesPantalla({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Ajustes', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
    );
  }
}
