import 'package:flutter/material.dart';
import 'onboarding_screens.dart';

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
      home: OnboardingScreens(),
    );
  }
} 