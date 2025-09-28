import 'package:flutter/material.dart';
import 'recuperar_contrasena_restaurar.dart';

class RecoverPasswordCodeScreen extends StatefulWidget {
  final String email;
  const RecoverPasswordCodeScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<RecoverPasswordCodeScreen> createState() => _RecoverPasswordCodeScreenState();
}

class _RecoverPasswordCodeScreenState extends State<RecoverPasswordCodeScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;

  void _goBack() => Navigator.pop(context);

  Future<void> _continue() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecoverPasswordResetScreen(email: widget.email, code: _codeCtrl.text.trim()),
        ),
      );
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
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: _goBack,
                    color: Colors.black,
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Se enviará un codigo de\nverificación al correo\nregistrado',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 12, bottom: 8),
                        child: Text(
                          'Escribe el código',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
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
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _codeCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          counterText: '',
                          hintText: '000000',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                        child: Text(_loading ? 'Verificando...' : 'Continuar',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: size.height * 0.18,
                      child: Image.asset('assets/images/perro.png', fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '¿Ya tienes una cuenta?',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
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
