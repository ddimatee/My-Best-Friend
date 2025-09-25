import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_best_friend_app/pantallas/inicio_sesion.dart';

void main() {
  testWidgets('Login screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    expect(find.text('Inicia sesión'), findsOneWidget);
  // El copy exacto del botón superior es con salto de línea
  expect(find.text('¿Olvidaste tu\ncontraseña?'), findsOneWidget);
  expect(find.text('Ingresar'), findsOneWidget);
    expect(find.text('¿No tienes una cuenta?'), findsOneWidget);
    expect(find.text('Regístrate'), findsOneWidget);
  });
}