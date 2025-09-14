import 'package:flutter/material.dart';
import 'main_menu.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Best Friend',
      theme: ThemeData(primarySwatch: Colors.green),
      home: MainMenu(),
    );
  }
} 