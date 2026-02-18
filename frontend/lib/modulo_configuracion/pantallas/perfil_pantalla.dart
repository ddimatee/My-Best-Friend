import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../providers/auth_provider.dart';
import '../../../services/api_service.dart';

class PerfilPantalla extends StatefulWidget {
  const PerfilPantalla({Key? key}) : super(key: key);

  @override
  State<PerfilPantalla> createState() => _PerfilPantallaState();
}

class _PerfilPantallaState extends State<PerfilPantalla> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  File? _nuevaFotoFile;
  bool _guardando = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Cargar datos desde AuthProvider si existen
    // Se difiere a post frame para asegurar que el provider esté montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final u = auth.user;
      if (u != null) {
        final nombre = '${u['nombre'] ?? ''} ${u['apellido'] ?? ''}'.trim();
        _nombreController.text = nombre.isEmpty ? 'Sin nombre' : nombre;
        _emailController.text = u['correo'] ?? '';
        // No tienes teléfono en el modelo? Podrías agregarlo; por ahora dejar vacío o placeholder.
        _telefonoController.text = u['celular'] ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
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
          'Perfil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          
          // Avatar del usuario
          _buildAvatar(green),
          
          const SizedBox(height: 30),
          
          // Formulario
          Expanded(
            child: Container(
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
                  children: [
                    // Campo Nombre
                    _buildTextField(
                      controller: _nombreController,
                      label: 'Nombre completo',
                      icon: Icons.person_outline,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Campo Email
                    _buildTextField(
                      controller: _emailController,
                      label: 'Correo electrónico',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Campo Teléfono
                    _buildTextField(
                      controller: _telefonoController,
                      label: 'Teléfono',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    
                    const Spacer(),
                    
                    // Botón Guardar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _guardando ? null : _guardarCambios,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _guardando
                            ? const SizedBox(height:20,width:20,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white))
                            : const Text(
                                'Guardar Cambios',
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
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
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
      ),
    );
  }

  void _guardarCambios() {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;
    setState(() { _guardando = true; });
    () async {
      try {
        // Separar nombre y apellido (simple: último token como apellido)
        final nombreCompleto = _nombreController.text.trim();
        String nombre = nombreCompleto;
        String apellido = '';
        if (nombreCompleto.contains(' ')) {
          final partes = nombreCompleto.split(' ');
            if (partes.length > 1) {
              apellido = partes.removeLast();
              nombre = partes.join(' ');
            }
        }
        final api = ApiService();
        // Actualizar campos básicos
        final resp = await api.actualizarPerfil(
          id: user['_id'],
          nombre: nombre,
          apellido: apellido.isEmpty ? user['apellido'] : apellido,
          correo: _emailController.text.trim(),
          celular: _telefonoController.text.trim(),
        );
        if (!(resp['success'] ?? false)) {
          throw resp['message'] ?? 'Error actualizando perfil';
        }
        Map<String,dynamic>? usuarioActualizado = resp['data']?['usuario'] ?? resp['data'];
        // Subir foto si hay nueva
        if (_nuevaFotoFile != null) {
          final bytes = await _nuevaFotoFile!.readAsBytes();
            final up = await api.subirFotoPerfilUsuario(
              id: user['_id'],
              bytes: bytes,
              filename: _nuevaFotoFile!.path.split('/').last,
            );
            if (up['success'] ?? false) {
              usuarioActualizado = up['data']?['usuario'] ?? up['data'] ?? usuarioActualizado;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Foto no subida: ${up['message']}')));
            }
        }
        // Refrescar auth provider (reemplazar user)
        if (usuarioActualizado != null) {
          auth.mergeUserData(usuarioActualizado);
        } else {
          await auth.obtenerPerfil();
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() { _guardando = false; });
      }
    }();
  }

  Widget _buildAvatar(Color green) {
    final auth = context.watch<AuthProvider>();
    final tieneFotoRemota = auth.user?['fotoPerfil'] != null && (auth.user!['fotoPerfil'] as String).isNotEmpty;
    ImageProvider? foto;
    if (_nuevaFotoFile != null && !kIsWeb) {
      foto = Image.file(_nuevaFotoFile!, fit: BoxFit.cover).image;
    } else if (tieneFotoRemota) {
      foto = NetworkImage(_resolveFotoUrl(auth.user!['fotoPerfil']));
    }
    return Stack(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: foto,
            child: foto == null ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: GestureDetector(
            onTap: _seleccionarFoto,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0,1),
                  ),
                ],
              ),
              child: Icon(Icons.camera_alt, size: 22, color: green),
            ),
          ),
        )
      ],
    );
  }

  Future<void> _seleccionarFoto() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 85);
      if (picked != null) {
        setState(() {
          _nuevaFotoFile = kIsWeb ? null : File(picked.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error seleccionando imagen: $e')));
    }
  }

  String _resolveFotoUrl(String path) {
    if (path.startsWith('http')) return path;
    // Base API sin /api
    final base = ApiService.baseUrl.replaceFirst('/api', '');
    return '$base$path';
  }
}