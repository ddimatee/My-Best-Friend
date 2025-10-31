import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ComentariosSoportePantalla extends StatefulWidget {
  const ComentariosSoportePantalla({Key? key}) : super(key: key);

  @override
  State<ComentariosSoportePantalla> createState() => _ComentariosSoportePantallaState();
}

class _ComentariosSoportePantallaState extends State<ComentariosSoportePantalla> {
  final TextEditingController _comentarioController = TextEditingController();
  String _tipoSolicitud = 'Soporte técnico';

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color green = const Color(0xFF4CAF50);
    
    return Scaffold(
      backgroundColor: green,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Comentarios y Soporte',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Opciones de contacto rápido
              const Text(
                'Contacto rápido',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildContactOption(
                      'Preguntas\nFrecuentes',
                      Icons.help_outline,
                      () => _abrirPreguntasFrecuentes(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildContactOption(
                      'Llamar\nSoporte',
                      Icons.phone_outlined,
                      () => _llamarSoporte(),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Formulario de comentarios
              const Text(
                'Enviar comentario o solicitud',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              // Tipo de solicitud
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.category_outlined, color: Colors.grey),
                    const SizedBox(width: 12),
                    const Text(
                      'Tipo de solicitud:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    DropdownButton<String>(
                      value: _tipoSolicitud,
                      underline: Container(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _tipoSolicitud = newValue!;
                        });
                      },
                      items: <String>[
                        'Soporte técnico',
                        'Sugerencia',
                        'Reporte de error',
                        'Solicitud de función',
                        'Otro'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Campo de comentario
              TextFormField(
                controller: _comentarioController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'Describe tu comentario o problema',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  hintText: 'Cuéntanos qué necesitas o qué problema has encontrado...',
                ),
              ),
              
              const Spacer(),
              
              // Información de contacto
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Información de contacto',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Email: soporte@mybestfriend.com\nTeléfono: +57 322 419 2641\nHorario: Lun-Vie 9:00 AM - 6:00 PM',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Botón Enviar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _enviarComentario,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Enviar Comentario',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactOption(String titulo, IconData icono, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(
              icono,
              size: 32,
              color: const Color(0xFF4CAF50),
            ),
            const SizedBox(height: 8),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirPreguntasFrecuentes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preguntas Frecuentes'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Cómo registro una nueva mascota?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Ve al menú principal y selecciona "Agregar mascota".'),
              SizedBox(height: 16),
              Text(
                '¿Cómo configuro recordatorios?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Ve a Configuración > Notificaciones > Recordatorios.'),
              SizedBox(height: 16),
              Text(
                '¿Puedo sincronizar con veterinario?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Esta función estará disponible en próximas actualizaciones.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _llamarSoporte() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de llamada próximamente disponible'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _enviarComentario() {
    if (_comentarioController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor escribe tu comentario'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    _guardarSoporte();
  }

  Future<void> _guardarSoporte() async {
    final mensaje = _comentarioController.text.trim();
    final tipo = _tipoSolicitud;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final scaffold = ScaffoldMessenger.of(context);
    try {
      scaffold.showSnackBar(const SnackBar(content: Text('Enviando...'), duration: Duration(seconds: 1)));

      // Recuperar token guardado por ApiService (usa clave auth_token)
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // Usar misma lógica que ApiService: base termina en /api
      const String override = String.fromEnvironment('API_BASE', defaultValue: '');
      String baseApi;
      if (override.isNotEmpty) {
        baseApi = '$override/api';
      } else {
        baseApi = 'http://localhost:3000/api';
      }
      final uri = Uri.parse('$baseApi/soporte');
      final resp = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'tipo': tipo,
          'mensaje': mensaje,
          'metadata': {
            'plataforma': Theme.of(context).platform.name,
            'lenguaje': 'es'
          }
        }),
      );

      if (resp.statusCode == 201) {
        scaffold.showSnackBar(const SnackBar(
          content: Text('Comentario enviado. ¡Gracias!'),
          backgroundColor: Color(0xFF4CAF50),
        ));
        _comentarioController.clear();
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        String msg = 'Error al enviar';
        try {
          final data = jsonDecode(resp.body);
          msg = data['error'] ?? data['mensaje'] ?? msg;
        } catch (_) {}
        scaffold.showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      scaffold.showSnackBar(SnackBar(
        content: Text('Error de red: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    }
  }
}