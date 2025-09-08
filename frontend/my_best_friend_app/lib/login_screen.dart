import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final nombreController = TextEditingController();
  final contrasenaController = TextEditingController();
  bool recordar = false;

  // Placeholder login function
  Future<String?> loginUsuario(String nombre, String contrasena) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return null;
  }

  Future<void> iniciarSesion() async {
    final token = await loginUsuario(nombreController.text, contrasenaController.text);
    if (token != null) {
      // Navegar a la pantalla principal o guardar el token
    } else {
      // Mostrar error
    } 
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50), // Verde exacto de la imagen
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: size.height - MediaQuery.of(context).padding.top,
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.08,
              vertical: size.height * 0.02,
            ),
            child: Column(
              children: [
                // Botón "¿Olvidaste tu contraseña?" en la parte superior derecha
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      '¿Olvidaste tu\ncontraseña?',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
                
                SizedBox(height: size.height * 0.08),
                
                // Título "Inicia sesión"
                const Text(
                  'Inicia sesión',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                SizedBox(height: size.height * 0.06),
                
                // Campo "Correo Electrónico"
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: nombreController,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Correo Electrónico',
                      hintStyle: TextStyle(color: Color.fromARGB(255, 5, 5, 5)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
                
                SizedBox(height: size.height * 0.025),
                
                // Campo de contraseña
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: contrasenaController,
                    obscureText: true,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Contraseña',
                      hintStyle: TextStyle(color: Color.fromARGB(255, 5, 5, 5)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
                
                SizedBox(height: size.height * 0.025),
                
                // Checkbox "Recordar"
                Row(
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: Checkbox(
                        value: recordar,
                        onChanged: (val) => setState(() => recordar = val ?? false),
                        fillColor: MaterialStateProperty.all(Colors.white),
                        checkColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Recordar',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: size.height * 0.04),
                
                // Botón "Continuar"
                SizedBox(
                  width: size.width * 0.6,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: iniciarSesion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Ingresar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Imagen del perro
                Container(
                  height: size.height * 0.2,
                  child: Image.asset(
                    'assets/images/perro.png',
                    fit: BoxFit.contain,
                  ),
                ),
                
                SizedBox(height: size.height * 0.02),
                
                // Texto "¿No tienes una cuenta?"
                const Text(
                  '¿No tienes una cuenta?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                
                // Botón "Regístrate"
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Regístrate',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
                
                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
