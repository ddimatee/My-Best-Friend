import 'package:flutter/material.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'servicios/dueno_service.dart'; // Queda para potencial persistencia futura
import 'modelos/dueno_model.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'editar_dueno_pantalla.dart';
import '../modulo_general/widgets/bottom_nav_global.dart';

class DuenoModuloPantalla extends StatefulWidget {
  const DuenoModuloPantalla({Key? key}) : super(key: key);

  @override
  State<DuenoModuloPantalla> createState() => _DuenoModuloPantallaState();
}

class _DuenoModuloPantallaState extends State<DuenoModuloPantalla> {
  final Color _greenColor = const Color(0xFF4CAF50);
  final DuenoService _duenoService = DuenoService();
  // Mantengo dueno por compatibilidad (foto, etc), pero datos básicos vienen de AuthProvider
  DuenoModel? dueno;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDueno();
  }

  Future<void> _cargarDueno() async {
    try {
      final duenoObtenido = await _duenoService.obtenerDueno();
      setState(() {
        dueno = duenoObtenido;
        _cargando = false;
      });
    } catch (e) {
      print('Error al cargar dueño: $e');
      setState(() {
        _cargando = false;
      });
    }
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
      ),
    body: _cargando
      ? const Center(child: CircularProgressIndicator(color: Colors.white))
      : _buildDuenoInfo(),
      bottomNavigationBar: const BottomNavGlobal(selectedIndex: 0),
    );
  }

  // Eliminado método de error (no se usa tras unificación)

  Widget _buildDuenoInfo() {
    final auth = Provider.of<AuthProvider>(context, listen: true);
    final u = auth.user;
    final nombre = u != null ? (u['nombre'] ?? '') : '';
    final apellido = u != null ? (u['apellido'] ?? '') : '';
    final nombreCompleto = ('$nombre $apellido').trim().isEmpty ? 'Usuario' : ('$nombre $apellido').trim();
  final telefono = (u?['celular'] ?? '').toString();
  final email = (u?['correo'] ?? '').toString();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          
          // Tarjeta principal con información del dueño
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(30),
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
                // Foto de perfil
                _buildProfilePhoto(),
                
                const SizedBox(height: 20),
                
                // Nombre completo
                Text(
                  nombreCompleto,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Builder(builder: (context){
                  final auth = Provider.of<AuthProvider>(context, listen: true);
                  final u = auth.user;
                  final bool esCuidador = (u?['cuidaConAlguien'] == true || (u?['rol']?.toString().toLowerCase() == 'cuidador'));
                  final rolTexto = esCuidador ? 'Cuidador' : 'Dueño';
                  return Text(
                    rolTexto,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  );
                }),
                
                const SizedBox(height: 30),
                
                // Información de contacto
                _buildInfoSection(telefono: telefono, email: email),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Botón de editar (opcional para futuras mejoras)
          _buildEditButton(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfilePhoto() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: dueno!.tieneFotoPerfil
          ? ClipOval(
              child: _buildImageWidget(dueno!.fotoPerfil!),
            )
          : Icon(
              Icons.person,
              size: 50,
              color: Colors.grey.shade500,
            ),
    );
  }

  Widget _buildImageWidget(String rutaImagen) {
    if (kIsWeb) {
      return Image.network(
        rutaImagen,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.person,
            size: 50,
            color: Colors.grey.shade500,
          );
        },
      );
    } else if (kIsWeb) {
      return const Icon(Icons.person, size: 50, color: Colors.grey);
    } else {
      return Image.file(
        File(rutaImagen),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.person,
            size: 50,
            color: Colors.grey.shade500,
          );
        },
      );
    }
  }

  Widget _buildInfoSection({required String telefono, required String email}) {
    return Column(
      children: [
        if (telefono.isNotEmpty)
          _buildInfoItem(
            icon: Icons.phone,
            title: 'Teléfono',
            value: telefono,
          ),
        const SizedBox(height: 20),
        _buildInfoItem(
          icon: Icons.email,
          title: 'Correo electrónico',
          value: email.isEmpty ? 'No definido' : email,
        ),
        const SizedBox(height: 20),
        // Dirección eliminada según requerimiento (no se muestra)
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 24,
          color: _greenColor,
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton.icon(
        onPressed: () async {
          if (dueno != null) {
            final resultado = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => EditarDuenoPantalla(dueno: dueno!),
              ),
            );
            
            // Si se guardaron cambios, recargar la información
            if (resultado == true) {
              _cargarDueno();
            }
          }
        },
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text(
          'Editar información',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _greenColor.withOpacity(0.8),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
        ),
      ),
    );
  }

}

// _BottomItem eliminado (se usa BottomNavGlobal)