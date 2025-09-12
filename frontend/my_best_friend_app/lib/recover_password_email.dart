import 'package:flutter/material.dart';
import 'register_screen_1.dart';
import 'recover_password_code.dart';
import 'services/auth_service.dart';
import 'widgets/snackbars.dart';

class RecoverPasswordEmailScreen extends StatefulWidget {
  const RecoverPasswordEmailScreen({Key? key}) : super(key: key);

  @override
  State<RecoverPasswordEmailScreen> createState() => _RecoverPasswordEmailScreenState();
}

class _RecoverPasswordEmailScreenState extends State<RecoverPasswordEmailScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _continue() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await AuthService.requestPasswordReset(_emailCtrl.text);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecoverPasswordCodeScreen(email: _emailCtrl.text.trim()),
        ),
      );
    } catch (e) {
  showErrorSnackBar(context, e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Recupera tú\ncontraseña',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(blurRadius: 3, color: Colors.black26, offset: Offset(0, 2)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Escribe tu correo para\nenviar un código de\nverificación',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        shadows: [
                          Shadow(blurRadius: 1, color: Colors.black26, offset: Offset(0, 1)),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.05),

                    // Label
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 12, bottom: 8),
                        child: Text(
                          'Correo electrónico',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    // Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Correo electrónico',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.04),

                    // Continue button
                    SizedBox(
                      width: size.width * 0.6,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _continue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 6,
                        ),
                        child: Text(_loading ? 'Enviando...' : 'Continuar',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),

                // Bottom image + footer
                Column(
                  children: [
                    SizedBox(
                      height: size.height * 0.18,
                      child: Image.asset('assets/images/perro.png', fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '¿No tienes una cuenta?',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen1()));
                      },
                      child: const Text(
                        'Regístrate',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                          decorationThickness: 2,
                        ),
                      ),
                    ),
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
