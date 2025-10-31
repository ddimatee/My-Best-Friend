import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/mascotas_provider.dart';
import '../menu_principal.dart'; // Para navegar directamente a la pestaña Calendario

/// Tipo de resultado general de búsqueda.
class ResultadoBusqueda {
  final String id; // puede ser ruta simbólica
  final String titulo;
  final String descripcion;
  final IconData icono;
  final VoidCallback? onTap; // acción directa
  ResultadoBusqueda({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    this.onTap,
  });
}

/// Fuente de datos general. (Simulación sin backend.)
class BuscadorGlobal {
  static final BuscadorGlobal _i = BuscadorGlobal._internal();
  factory BuscadorGlobal() => _i;
  BuscadorGlobal._internal();

  // Uso de MascotasProvider en lugar de repositorio legacy

  // Catálogo estático de secciones / pantallas clave
  List<ResultadoBusqueda> _catalogoBase(BuildContext context) => [
        ResultadoBusqueda(
          id: 'mod:calendario',
          titulo: 'Calendario',
          descripcion: 'Ver eventos y recordatorios',
          icono: Icons.calendar_month,
          // Abrir directamente el menú principal posicionándose en la pestaña Calendario (índice 1)
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MenuPrincipal(initialTab: 1),
            ),
          ),
        ),
        ResultadoBusqueda(
          id: 'mod:album',
          titulo: 'Álbum',
          descripcion: 'Fotos y recuerdos',
          icono: Icons.photo_library_outlined,
          onTap: () => Navigator.pushNamed(context, '/album'),
        ),
        ResultadoBusqueda(
          id: 'mod:eventos',
          titulo: 'Eventos',
          descripcion: 'Gestionar eventos',
          icono: Icons.event_note,
          onTap: () => Navigator.pushNamed(context, '/eventos'),
        ),
        ResultadoBusqueda(
          id: 'conf:perfil',
          titulo: 'Perfil',
          descripcion: 'Ver / editar perfil de usuario',
          icono: Icons.person_outline,
          onTap: () => Navigator.pushNamed(context, '/config/perfil'),
        ),
        ResultadoBusqueda(
          id: 'conf:notificaciones',
          titulo: 'Notificaciones',
          descripcion: 'Configurar recordatorios',
          icono: Icons.notifications_active_outlined,
          onTap: () => Navigator.pushNamed(context, '/config/notificaciones'),
        ),
        ResultadoBusqueda(
          id: 'conf:cuenta',
            titulo: 'Cuenta y Sesión',
            descripcion: 'Gestionar acceso y seguridad',
            icono: Icons.manage_accounts_outlined,
            onTap: () => Navigator.pushNamed(context, '/config/cuenta'),
        ),
        ResultadoBusqueda(
          id: 'conf:soporte',
          titulo: 'Comentarios y Soporte',
          descripcion: 'Envíanos tu retroalimentación',
          icono: Icons.support_agent,
          onTap: () => Navigator.pushNamed(context, '/config/soporte'),
        ),
      ];

  List<ResultadoBusqueda> buscar(BuildContext context, String query, {bool incluirOcultasMascotas = true}) {
    final q = query.trim().toLowerCase();
    final base = _catalogoBase(context);

    // Mascotas
    final prov = context.read<MascotasProvider>();
    final lista = prov.mascotas.where((m) {
      if (q.isEmpty) return true;
      final nombre = (m['nombre'] ?? '').toString().toLowerCase();
      return nombre.contains(q);
    }).where((m) => incluirOcultasMascotas || !(m['oculto'] == true));
    final mascotas = lista.map(
      (m) => ResultadoBusqueda(
        id: 'pet:${m['_id'] ?? m['id']}',
        titulo: (m['nombre'] ?? '').toString(),
        descripcion: (m['oculto'] == true) ? 'Mascota oculta' : 'Mascota visible',
        icono: Icons.pets,
        onTap: () => Navigator.pushNamed(context, '/menu'),
      ),
    );

    if (q.isEmpty) {
      return [
        ...mascotas,
        ...base,
      ];
    }

    return [
      // Filtro en base y mascotas
      ...mascotas.where((r) => r.titulo.toLowerCase().contains(q)),
      ...base.where((r) =>
          r.titulo.toLowerCase().contains(q) || r.descripcion.toLowerCase().contains(q)),
    ];
  }
}
