import 'package:flutter/material.dart';

class RegisterScreen3 extends StatefulWidget {
  final String nombre;
  final String apellido;
  final String correo;
  final String celular;
  final String comoLlegaste;
  final String contrasena;

  const RegisterScreen3({
    Key? key,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.celular,
    required this.comoLlegaste,
    required this.contrasena,
  }) : super(key: key);

  @override
  _RegisterScreen3State createState() => _RegisterScreen3State();
}

class _RegisterScreen3State extends State<RegisterScreen3> {
  final codigoController = TextEditingController();

  Future<void> verificarCodigo() async {
    if (codigoController.text.isNotEmpty) {
      // Aquí iría la lógica para verificar el código con el backend
      // Por ahora simulamos una verificación exitosa
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mostrar mensaje de éxito y navegar a la pantalla principal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Registro exitoso!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navegar de vuelta al login o a la pantalla principal
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa el código de verificación'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
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
                SizedBox(height: size.height * 0.02),
                
                // Botón de regresar mejorado
                Container(
                  margin: EdgeInsets.only(bottom: size.height * 0.08),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                spreadRadius: 0,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF4CAF50),
                            size: 24,
                          ),
                        ),
                      ),
                      Container(), // Espaciador
                    ],
                  ),
                ),
                
                // Título mejorado y centrado
                Container(
                  margin: EdgeInsets.only(bottom: size.height * 0.08),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Se enviará un código de\nverificación al correo\nregistrado',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.white30,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Campo "Código" mejorado
                Container(
                  margin: EdgeInsets.only(bottom: size.height * 0.04),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16, bottom: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Código de verificación',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              shadows: [
                                Shadow(
                                  blurRadius: 1,
                                  color: Colors.white30,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 15,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: codigoController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            prefixIcon: Icon(Icons.verified_outlined, color: Colors.grey),
                            hintText: '000000',
                            hintStyle: TextStyle(color: Colors.grey, letterSpacing: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Botón "Continuar" mejorado
                Container(
                  margin: EdgeInsets.only(bottom: size.height * 0.04),
                  child: SizedBox(
                    width: size.width * 0.7,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: verificarCodigo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Continuar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Footer mejorado
                Column(
                  children: [
                    // Imagen del perro
                    Container(
                      height: size.height * 0.15,
                      margin: EdgeInsets.only(bottom: size.height * 0.02),
                      child: Image.asset(
                        'assets/images/perro.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    // Texto "¿Ya tienes una cuenta?"
                    Container(
                      margin: EdgeInsets.only(bottom: 8),
                      child: Text(
                        '¿Ya tienes una cuenta?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          shadows: [
                            Shadow(
                              blurRadius: 1,
                              color: Colors.black26,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    TextButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      ),
                      child: const Text(
                        'Inicia sesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                          decorationThickness: 2,
                          shadows: [
                            Shadow(
                              blurRadius: 1,
                              color: Colors.black26,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
