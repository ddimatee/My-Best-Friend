import 'package:flutter/material.dart';
import 'login_screen.dart'; // Asegúrate de que el nombre coincida

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Best Friend',
      theme: ThemeData(primarySwatch: Colors.green),
      home: LoginScreen(),
    );
  }
} 