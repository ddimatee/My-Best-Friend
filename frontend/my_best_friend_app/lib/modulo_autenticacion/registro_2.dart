import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Registro 2/3: celular, ¿cómo llegaste?, contraseña
// import removido (formulario mascota) - ya no se navega ahí directamente
import '../modulo_general/componentes/avisos.dart';
import '../providers/auth_provider.dart';
import 'inicio_sesion.dart';

class RegisterScreen2 extends StatefulWidget {
  final String nombre;
  final String apellido;
  final String correo;

  const RegisterScreen2({
    Key? key,
    required this.nombre,
    required this.apellido,
    required this.correo,
  }) : super(key: key);

  @override
  _RegisterScreen2State createState() => _RegisterScreen2State();
}

class _RegisterScreen2State extends State<RegisterScreen2> {
  final celularController = TextEditingController();
  final comoLlegasteController = TextEditingController();
  final contrasenaController = TextEditingController();
  bool _isLoading = false;

  String? _validarCelular(String value) {
    if (value.isEmpty) return 'Celular requerido';
    if (!RegExp(r'^\d{10}$').hasMatch(value)) return 'Debe tener 10 dígitos';
    return null;
  }

  String? _validarPassword(String value) {
    if (value.isEmpty) return 'Contraseña requerida';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    final hasUpper = RegExp(r'[A-Z]').hasMatch(value);
    final hasLower = RegExp(r'[a-z]').hasMatch(value);
    final hasNum = RegExp(r'[0-9]').hasMatch(value);
    if (!hasUpper || !hasLower || !hasNum) return 'Incluye mayúscula, minúscula y número';
    return null;
  }

  Future<void> continuarRegistro() async {
    final celularError = _validarCelular(celularController.text.trim());
    final passError = _validarPassword(contrasenaController.text);
    if (celularError != null) {
      showErrorSnackBar(context, celularError);
      return;
    }
    if (passError != null) {
      showErrorSnackBar(context, passError);
      return;
    }

    setState(() { _isLoading = true; });
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final ok = await auth.registrarUsuario(
        nombre: widget.nombre.trim(),
        apellido: widget.apellido.trim(),
        correo: widget.correo.trim(),
        celular: celularController.text.trim(),
        password: contrasenaController.text,
      );

      if (ok) {
        showSuccessSnackBar(context, 'Registro exitoso. Inicia sesión.');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
        );
      } else {
        showErrorSnackBar(context, auth.errorMessage ?? 'Error al registrar');
      }
    } catch (e) {
      showErrorSnackBar(context, 'Error: $e');
    } finally {
      if (mounted) setState(() { _isLoading = false; });
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
                
                Container(
                  margin: EdgeInsets.only(bottom: size.height * 0.05),
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
                      SizedBox(
                        width: size.width * 0.35,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : continuarRegistro,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text(
                                  'Registrar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: size.height * 0.025),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 16, bottom: 8),
                            child: Text(
                              'Número de celular',
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
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 0,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: celularController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                prefixIcon: Icon(Icons.phone_outlined, color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Container(
                      margin: EdgeInsets.only(bottom: size.height * 0.025),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 16, bottom: 8),
                            child: Text(
                              '¿Cómo llegaste a esta aplicación?',
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
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 0,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: comoLlegasteController,
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                prefixIcon: Icon(Icons.explore_outlined, color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Container(
                      margin: EdgeInsets.only(bottom: size.height * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 16, bottom: 8),
                            child: Text(
                              'Contraseña',
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
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 0,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: contrasenaController,
                              obscureText: true,
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Usa entre 8 y 20 caracteres, que sean\nnúmeros, letras y símbolos, ¡asegúrate de\nque sea difícil!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
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
                
                const Spacer(),
                
                Column(
                  children: [
                    Container(
                      height: size.height * 0.15,
                      margin: EdgeInsets.only(bottom: size.height * 0.02),
                      child: Image.asset(
                        'assets/images/perro.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    
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
