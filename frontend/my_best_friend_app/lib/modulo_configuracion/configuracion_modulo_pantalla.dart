import 'package:flutter/material.dart';
import 'pantallas/perfil_pantalla.dart';
import 'pantallas/contrasena_pantalla.dart';
import 'pantallas/notificaciones_pantalla.dart';
import 'pantallas/comentarios_soporte_pantalla.dart';
import 'pantallas/cuenta_sesion_pantalla.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

/// Widget del módulo de configuración pensado para incrustarse dentro del
/// `MenuPrincipal` (NO usa un Scaffold propio para evitar pantalla verde vacía).
class ConfiguracionModuloPantalla extends StatelessWidget {
  const ConfiguracionModuloPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    // Colores aproximados al mockup
    const Color panelFondo = Color(0xFFE0E0E0); // gris claro grande
    final Color itemColor = Colors.grey.shade400; // filas
    final Color textoTitulo = Colors.grey.shade900;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 100), // espacio inferior para la barra
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _UserHeaderCard(),
            const SizedBox(height: 12),
            // Panel gris con secciones
            Container(
              decoration: BoxDecoration(
                color: panelFondo,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle('Mis configuraciones', textoTitulo),
                  _ConfigItem(
                    label: 'Perfil',
                    color: itemColor,
                    onTap: () => _push(context, const PerfilPantalla()),
                  ),
                  _ConfigItem(
                    label: 'Contraseña',
                    color: itemColor,
                    onTap: () => _push(context, const ContrasenaPantalla()),
                  ),
                  _ConfigItem(
                    label: 'Notificaciones',
                    color: itemColor,
                    onTap: () => _push(context, const NotificacionesPantalla()),
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle('Soporte y Otros', textoTitulo),
                  _ConfigItem(
                    label: 'Comentarios y Soporte',
                    color: itemColor,
                    onTap: () => _push(context, const ComentariosSoportePantalla()),
                  ),
                  _ConfigItem(
                    label: 'Cuenta y Sesión',
                    color: itemColor,
                    onTap: () => _push(context, const CuentaSesionPantalla()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }
}

// ----------------- Widgets internos -----------------

class _UserHeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: true);
    final u = auth.user;
    final nombre = u != null
        ? ('${u['nombre'] ?? ''} ${u['apellido'] ?? ''}').trim()
        : 'Usuario';
    final correo = u != null ? (u['correo'] ?? 'correo no disponible') : 'correo no disponible';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400, width: 2),
              color: Colors.grey.shade200,
            ),
            child: Icon(Icons.person, size: 34, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre.isEmpty ? 'Usuario' : nombre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  correo,
                  style: const TextStyle(fontSize: 13.5, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionTitle(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15.5,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _ConfigItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _ConfigItem({
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward, size: 20, color: Colors.black87),
            ],
          ),
        ),
      ),
    );
  }
}
