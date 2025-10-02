import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../modulo_autenticacion/inicio_sesion.dart';
import '../../providers/auth_provider.dart';
// import 'package:intl/intl.dart'; // ya no se usa tras quitar fechas
// import 'dart:async'; // removido timer
import '../../services/api_service.dart';

class CuentaSesionPantalla extends StatefulWidget {
  const CuentaSesionPantalla({Key? key}) : super(key: key);

  @override
  State<CuentaSesionPantalla> createState() => _CuentaSesionPantallaState();
}

class _CuentaSesionPantallaState extends State<CuentaSesionPantalla> {
  bool _sesionesActivas = false;
  // Timer removido

  @override
  void initState() {
    super.initState();
    // Cargar preferencia mantener sesión del provider
    Future.microtask(() {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      setState(() { _sesionesActivas = auth.mantenerSesion; });
    });
  }

  @override
  void dispose() {
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
          'Cuenta y Sesión',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        // acciones removidas (refresh)
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
              // Información de la cuenta
              const Text(
                'Información de la cuenta',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              Builder(builder: (context) {
                final auth = Provider.of<AuthProvider>(context, listen: true);
                final nombre = auth.user != null
                    ? '${auth.user!['nombre'] ?? ''} ${auth.user!['apellido'] ?? ''}'.trim()
                    : 'No disponible';
                final email = auth.user != null ? (auth.user!['correo'] ?? 'No definido') : 'No definido';
                return Column(
                  children: [
                    _buildInfoTile(
                      'Usuario',
                      nombre.isEmpty ? 'Sin nombre' : nombre,
                      Icons.person_outline,
                    ),
                    _buildInfoTile(
                      'Email',
                      email,
                      Icons.email_outlined,
                    ),
                  ],
                );
              }),
              
              // Se quitaron: Fecha de registro y Última actividad
              
              const SizedBox(height: 24),
              
              // Seguridad de la sesión
              const Text(
                'Seguridad de sesión',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              Builder(builder: (context) {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                return _buildSwitchTile(
                  'Mantener sesión activa',
                  'Recordar mi sesión en este dispositivo',
                  _sesionesActivas,
                  Icons.security_outlined,
                  (value) async {
                    setState(() => _sesionesActivas = value);
                    await auth.setMantenerSesion(value);
                  },
                );
              }),
              
              const SizedBox(height: 16),
              
              const SizedBox(height: 24),
              
              // Gestión de cuenta
              const Text(
                'Gestión de cuenta',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _cerrarSesion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cerrar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _eliminarCuenta,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Eliminar Cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
            ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String titulo, String valor, IconData icono) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icono,
            color: Colors.grey.shade600,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
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
      ),
    );
  }

  Widget _buildSwitchTile(
    String titulo,
    String descripcion,
    bool valor,
    IconData icono,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icono,
            color: Colors.grey.shade600,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: valor,
            onChanged: onChanged,
            activeColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  // _buildActionTile eliminado (ya no se usa)

  // Eliminado descargar datos

  void _cerrarSesion() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
            ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // cierra diálogo
              await auth.cerrarSesion(context: context);
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _eliminarCuenta() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    if (user == null) return;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          bool loading = false;
          Future<void> eliminar() async {
            setStateDialog(() { loading = true; });
            final api = ApiService();
            final id = user['_id'];
            final resp = await api.eliminarCuenta(id);
            setStateDialog(() { loading = false; });
            if (resp['success'] == true || resp['message']?.toString().contains('correctamente') == true) {
              if (mounted) {
                await auth.cerrarSesion(context: context);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(resp['message'] ?? resp['error'] ?? 'Error al eliminar'), backgroundColor: Colors.red),
              );
            }
          }
          return AlertDialog(
            title: const Text('Eliminar Cuenta'),
            content: const Text('¿Estás seguro? Esta acción eliminará tus mascotas y no se puede deshacer.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: loading ? null : eliminar,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: loading ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)) : const Text('Eliminar'),
              )
            ],
          );
        }
      ),
    );
  }
}