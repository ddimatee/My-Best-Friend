import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Ajustes', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
    );
  }
}
