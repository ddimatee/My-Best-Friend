import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'servicios/dueno_service.dart';
import 'modelos/dueno_model.dart';
import 'editar_dueno_pantalla.dart';

class DuenoModuloPantalla extends StatefulWidget {
  const DuenoModuloPantalla({Key? key}) : super(key: key);

  @override
  State<DuenoModuloPantalla> createState() => _DuenoModuloPantallaState();
}

class _DuenoModuloPantallaState extends State<DuenoModuloPantalla> {
  final Color _greenColor = const Color(0xFF4CAF50);
  final DuenoService _duenoService = DuenoService();
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
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : dueno == null
              ? _buildErrorState()
              : _buildDuenoInfo(),
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _BottomItem(
              icon: Icons.pets,
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            _BottomItem(
              icon: Icons.calendar_month,
              selected: false,
              onTap: () {},
            ),
            _BottomItem(
              icon: Icons.settings,
              selected: false,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.white70,
          ),
          SizedBox(height: 20),
          Text(
            'No se pudo cargar la información del dueño',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDuenoInfo() {
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
                  dueno!.nombreCompleto,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Subtítulo "Propietario"
                Text(
                  'Propietario',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 30),
                
                // Información de contacto
                _buildInfoSection(),
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

  Widget _buildInfoSection() {
    return Column(
      children: [
        _buildInfoItem(
          icon: Icons.phone,
          title: 'Teléfono',
          value: dueno!.telefono,
        ),
        const SizedBox(height: 20),
        _buildInfoItem(
          icon: Icons.email,
          title: 'Correo electrónico',
          value: dueno!.email,
        ),
        const SizedBox(height: 20),
        _buildInfoItem(
          icon: Icons.location_on,
          title: 'Dirección',
          value: dueno!.direccion,
        ),
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

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _BottomItem({required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: selected
              ? const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))]
              : null,
        ),
        child: Icon(icon, size: 28, color: Colors.black),
      ),
    );
  }
}