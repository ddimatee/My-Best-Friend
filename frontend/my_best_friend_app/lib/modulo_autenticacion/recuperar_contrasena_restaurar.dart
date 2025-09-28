import 'package:flutter/material.dart';
import 'inicio_sesion.dart';
import 'servicios/autenticacion_servicio.dart' show AuthService;
import '../modulo_general/componentes/avisos.dart';

class RecoverPasswordResetScreen extends StatefulWidget {
  final String email;
  final String code;
  const RecoverPasswordResetScreen({Key? key, required this.email, required this.code}) : super(key: key);

  @override
  State<RecoverPasswordResetScreen> createState() => _RecoverPasswordResetScreenState();
}

class _RecoverPasswordResetScreenState extends State<RecoverPasswordResetScreen> {
  final _pass1 = TextEditingController();
  final _pass2 = TextEditingController();
  bool _loading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;

  Future<void> _continue() async {
    if (_loading) return;
    if (_pass1.text.trim() != _pass2.text.trim()) {
      showErrorSnackBar(context, 'Las contraseñas no coinciden');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.resetPassword(widget.email, widget.code, _pass1.text);
      if (!mounted) return;
      showSuccessSnackBar(context, 'Contraseña actualizada');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
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
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Recupera tú\ncontraseña',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 12, bottom: 8),
                        child: Text(
                          'Nueva contraseña',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: Offset(0, 4)),
                        ],
                      ),
                      child: TextField(
                        controller: _pass1,
                        obscureText: _obscure1,
                        decoration: InputDecoration(
                          hintText: 'Nueva contraseña',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                            onPressed: () => setState(() => _obscure1 = !_obscure1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 12, bottom: 8),
                        child: Text(
                          'Confirma contraseña',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: Offset(0, 4)),
                        ],
                      ),
                      child: TextField(
                        controller: _pass2,
                        obscureText: _obscure2,
                        decoration: InputDecoration(
                          hintText: 'Confirma contraseña',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                            onPressed: () => setState(() => _obscure2 = !_obscure2),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.04),
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
                        child: Text(_loading ? 'Guardando...' : 'Continuar',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
