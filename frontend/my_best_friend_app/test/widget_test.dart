import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_best_friend_app/login_screen.dart';

void main() {
  testWidgets('Login screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    expect(find.text('Inicia sesión'), findsOneWidget);
    expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
    expect(find.text('¿No tienes una cuenta?'), findsOneWidget);
    expect(find.text('Regístrate'), findsOneWidget);
  });
}