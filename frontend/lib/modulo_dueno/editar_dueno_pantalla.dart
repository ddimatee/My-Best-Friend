import 'package:flutter/material.dart';
import 'servicios/dueno_service.dart';
import 'modelos/dueno_model.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class EditarDuenoPantalla extends StatefulWidget {
  final DuenoModel dueno;

  const EditarDuenoPantalla({
    Key? key,
    required this.dueno,
  }) : super(key: key);

  @override
  State<EditarDuenoPantalla> createState() => _EditarDuenoPantallaState();
}

class _EditarDuenoPantallaState extends State<EditarDuenoPantalla> {
  final Color _greenColor = const Color(0xFF4CAF50);
  final DuenoService _duenoService = DuenoService();
  final ApiService _apiService = ApiService();
  
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;
  // Dirección eliminada del flujo de edición unificada
  
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.dueno.nombre);
    _apellidoController = TextEditingController(text: widget.dueno.apellido);
    _telefonoController = TextEditingController(text: widget.dueno.telefono);
    _emailController = TextEditingController(text: widget.dueno.email);
  // dirección ya no se edita
    _sincronizarConAuth();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_validarFormulario()) return;

    setState(() {
      _guardando = true;
    });

    try {
      // Actualizar Dueno local (foto, etc) para consistencia
      final duenoActualizado = widget.dueno.copyWith(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        telefono: _telefonoController.text.trim(),
        email: _emailController.text.trim(),
      );
      await _duenoService.actualizarDueno(duenoActualizado); // persistencia local (foto futura)

      // Actualizar backend + estado global
      final auth = context.read<AuthProvider>();
      final u = auth.user;
      if (u != null && u['_id'] != null) {
        final resp = await _apiService.actualizarPerfil(
          id: u['_id'].toString(),
          nombre: _nombreController.text.trim(),
          apellido: _apellidoController.text.trim(),
          celular: _telefonoController.text.trim(),
          correo: _emailController.text.trim(),
        );
        if (resp['success']) {
          auth.updateUserProfile(
            nombre: _nombreController.text.trim(),
            apellido: _apellidoController.text.trim(),
            celular: _telefonoController.text.trim(),
            correo: _emailController.text.trim(),
          );
        } else {
          throw Exception(resp['message'] ?? 'No se pudo actualizar perfil');
        }
      } else {
        // Fallback local si no hay id (no debería pasar luego de login correcto)
        auth.updateUserProfile(
          nombre: _nombreController.text.trim(),
          apellido: _apellidoController.text.trim(),
          celular: _telefonoController.text.trim(),
          correo: _emailController.text.trim(),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Información actualizada correctamente'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );

      Navigator.pop(context, true); // Retornar true para indicar que se guardaron cambios
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _guardando = false;
      });
    }
  }

  bool _validarFormulario() {
    if (_nombreController.text.trim().isEmpty) {
      _mostrarError('El nombre es requerido');
      return false;
    }
    if (_apellidoController.text.trim().isEmpty) {
      _mostrarError('El apellido es requerido');
      return false;
    }
    if (_emailController.text.trim().isEmpty) {
      _mostrarError('El email es requerido');
      return false;
    }
    return true;
  }

  // Asegura que si el DuenoModel llegó con valores vacíos pero AuthProvider ya tiene
  // la información del usuario autenticado, se muestren esos datos existentes.
  void _sincronizarConAuth() {
    try {
      final auth = context.read<AuthProvider>();
      final u = auth.user;
      if (u == null) return;

      String? nombre = (u['nombre'] ?? u['Nombre'])?.toString();
      String? apellido = (u['apellido'] ?? u['Apellido'])?.toString();
      String? correo = (u['correo'] ?? u['email'] ?? u['Email'])?.toString();
      String? celular = (u['celular'] ?? u['telefono'] ?? u['tel'] ?? u['Telefono'])?.toString();

      if ((_nombreController.text.isEmpty || _nombreController.text == 'Usuario') && nombre != null && nombre.isNotEmpty) {
        _nombreController.text = nombre;
      }
      if (_apellidoController.text.isEmpty && apellido != null && apellido.isNotEmpty) {
        _apellidoController.text = apellido;
      }
      if (_telefonoController.text.isEmpty && celular != null && celular.isNotEmpty) {
        _telefonoController.text = celular;
      }
      if (_emailController.text.isEmpty && correo != null && correo.isNotEmpty) {
        _emailController.text = correo;
      }
      setState(() {}); // refrescar si hubo cambios
    } catch (_) {
      // Silencio: si algo falla no bloquea la pantalla
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _greenColor,
      appBar: AppBar(
        backgroundColor: _greenColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar información',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Formulario dentro de tarjeta blanca
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nombreController,
                    label: 'Nombre',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _apellidoController,
                    label: 'Apellido',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _telefonoController,
                    label: 'Teléfono',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Correo electrónico',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  // Campo dirección removido
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Botón guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardarCambios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB74D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: _guardando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Guardar cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _greenColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _greenColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}