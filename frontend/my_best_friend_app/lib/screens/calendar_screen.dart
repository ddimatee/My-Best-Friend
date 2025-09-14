import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Calendario', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
    );
  }
}
