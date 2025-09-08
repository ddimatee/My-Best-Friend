import 'package:flutter/material.dart';
import 'package:my_best_friend_app/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final correoController = TextEditingController();
  final contraseniaController = TextEditingController();
  bool recordar = false;

  Future<void> iniciarSesion() async {
    final token = await loginUsuario(correoController.text, contraseniaController.text);
    if (token != null) {
      // Navegar a la pantalla principal o guardar el token
    } else {
      // Mostrar error
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[600],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text('Inicia sesión', style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {}, // Navegar a recuperación
                child: Text('¿Olvidaste tu contraseña?', style: TextStyle(color: Colors.white)),
              ),
            ),
            TextField(
              controller: correoController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            TextField(
              controller: contraseniaController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Contraseña'),
            ),
            Row(
              children: [
                Checkbox(
                  value: recordar,
                  onChanged: (val) => setState(() => recordar = val ?? false),
                ),
                Text('Recordar', style: TextStyle(color: Colors.white)),
              ],
            ),
            ElevatedButton(
              onPressed: iniciarSesion,
              child: Text('Continuar'),
            ),
            Spacer(),
            Image.asset('assets/images/perro.png'), // Asegúrate de tener esta imagen en tu carpeta assets
            Text('¿No tienes una cuenta?', style: TextStyle(color: Colors.white)),
            TextButton(
              onPressed: () {}, // Navegar a registro
              child: Text('Regístrate', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
